class Backstore::SalesController < ApplicationController
  before_action :set_sale, only: %i[ show edit update destroy ]

  load_and_authorize_resource

  # GET /sales or /sales.json
  def index
    @sales = Sale.all
  end

  # GET /sales/1 or /sales/1.json
  def show
    @sale_content = @sale.sale_contents
  end

  # GET /sales/new
  def new
    @sale = Sale.new
    @sale.items.build
    @all_clients = Client.all
    @available_disks = Disk.available_ordered
  end

  # GET /sales/1/edit
  def edit
    @all_clients = Client.all
    @available_disks = Disk.where("stock > 0").order(:title)
  end

  # POST /sales or /sales.json
  def create
    @sale = Sale.new(sale_params)
    @sale.user = current_user

    if @sale.save
      @sale.items.each { |item| item.decrease_stock() }
      redirect_to backstore_sale_path(@sale), notice: "Venta creada exitosamente."
    else
      @all_clients = Client.all
      @available_disks = Disk.where("stock > 0").order(:title)
      render :new, status: :unprocessable_entity
      render json: @sale.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sales/1 or /sales/1.json
  def update
    authorize! :update, @sale

    ActiveRecord::Base.transaction do
      @sale.items.each(&:revert_stock)

      if @sale.update(sale_params)
        @sale.items.each(&:decrease_stock)
        flash[:notice] = "¡Venta editada exitosamente! ^-^"
        redirect_to backstore_sale_path(@sale)
      else
        @all_clients = Client.all
        @available_disks = Disk.where("stock > 0").order(:title)
        flash[:error] = "No se pudo cancelar la venta: #{@sale.errors.full_messages.join(', ')}"
        redirect_to backstore_sale_path(@sale)
        raise ActiveRecord::Rollback  # Revertir la transacción
      end
    end
  end

  # DELETE /sales/1 or /sales/1.json
  def destroy
    authorize! :destroy, @sale

    # Verificar que no esté ya cancelada
    if @sale.cancelled?
      flash[:warning] = "Esta venta ya está cancelada"
      redirect_to backstore_sale_path(@sale)
      return
    end

    # Usar transacción para asegurar consistencia
    ActiveRecord::Base.transaction do
      @sale.cancelled = true

      @sale.items.each(&:revert_stock)
      @sale.total = 0.0

      if @sale.save
        flash[:notice] = "¡Venta cancelada exitosamente! ^-^"
        redirect_to backstore_sale_path(@sale)
      else
        flash[:error] = "No se pudo cancelar la venta: #{@sale.errors.full_messages.join(', ')}"
        redirect_to backstore_sale_path(@sale)
        raise ActiveRecord::Rollback  # Revertir la transacción
      end
    end
  end

  def set_available_disks
    @available_disks = Disk.where("stock > 0").order(:title)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sale
      @sale = Sale.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def sale_params
      params.require(:sale).permit(
        :client_id,
        items_attributes: [ :id, :disk_id, :amount, :_destroy ]
      )
    end
end
