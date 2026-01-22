class Backstore::InvoicesController < ApplicationController
  before_action :set_sale
  before_action :authorize_user

    def download
      if @sale.cancelled?
        flash[:error] = "No se pudo generar factura, la venta fue cancelada."
        redirect_to backstore_sale_path(@sale)
      else
        pdf_generator = InvoicePdfGenerator.new(@sale)
        pdf_content = pdf_generator.generate
        respond_to do |format|
          format.pdf do
            send_data pdf_content,
              filename: "factura_#{@sale.id}_#{Date.today}.pdf",
              type: "application/pdf",
              disposition: "attachment"
          end
        end
      end
  end

  def preview
    if @sale.cancelled?
      flash[:error] = "No se pudo generar factura, la venta fue cancelada."
      redirect_to backstore_sale_path(@sale)
    else
      pdf_generator = InvoicePdfGenerator.new(@sale)
      pdf_content = pdf_generator.generate
      respond_to do |format|
        format.pdf do
          send_data pdf_content,
            filename: "factura_#{@sale.id}_preview.pdf",
            type: "application/pdf",
            disposition: "inline"
        end
      end
    end
  end

  private

  def set_sale
    @sale = Sale.find(params[:id])
  end

  def authorize_user
    authorize! :read, @sale
  end
end
