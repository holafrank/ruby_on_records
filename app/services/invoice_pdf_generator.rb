require "action_view"
include ActionView::Helpers::NumberHelper

class InvoicePdfGenerator
  def initialize(sale)
    @sale = sale
    @items = sale.items.includes(:disk)
  end

  def generate
    pdf = Prawn::Document.new(page_size: "A5", margin: [ 30, 30, 30, 30 ])

    # === Titulo === #
    pdf.font "app/assets/fonts/dejavu-sans.bold.ttf" do
      pdf.text "★ RUBY ON RECORDS ★", size: 18, align: :center, color: "b92621"
    end

    # === Detalles === #
    pdf.font "app/assets/fonts/dejavu-sans.book.ttf" do
      pdf.text "Factura ##{@sale.id}", size: 12, align: :center
      pdf.move_down 20
      pdf.text "Fecha: #{@sale.created_at_local_time.strftime("%d-%m-%Y, %H:%M")}", size: 8, align: :left

      pdf.move_down 2


      pdf.stroke_horizontal_rule
      pdf.move_down 10
    end

    # === Productos === #
    pdf.font "app/assets/fonts/dejavu-sans.bold.ttf" do
      pdf.text "PRODUCTOS", size: 11
      pdf.move_down 5
    end
    # === Lista de productos === #
    pdf.font "app/assets/fonts/dejavu-sans.book.ttf" do
      @items.each do |item|
        disk = item.disk
        subtotal = item.amount * disk.price

        pdf.text "✧ #{disk.title} - #{disk.artist}", size: 10
        pdf.indent(20) do
          pdf.text "Cantidad: #{item.amount} × #{number_to_currency(disk.price, locale: :es)} = #{number_to_currency(subtotal, locale: :es)}", size: 9
        end
        pdf.move_down 5
      end
      pdf.move_down 10
      pdf.stroke_horizontal_rule
      pdf.move_down 10
    end

    # === Total === #
    pdf.font "app/assets/fonts/dejavu-sans.bold.ttf" do
      pdf.text "TOTAL: #{number_to_currency(@sale.total, locale: :es)}", size: 14, align: :right, color: "b92621"
      pdf.move_down 20
    end

    # === Datos del cliente === #
    pdf.font "app/assets/fonts/dejavu-sans.bold.ttf" do
      pdf.text "DATOS DEL CLIENTE", size: 11
      pdf.move_down 5
    end

    pdf.font "app/assets/fonts/dejavu-sans.book.ttf" do
      pdf.text "Nombre: #{@sale.client.name}", size: 10
      pdf.text "Contacto: #{@sale.client.contact}", size: 10
      pdf.move_down 10
    end

    # === Datos del vendedor === #
    pdf.font "app/assets/fonts/dejavu-sans.bold.ttf" do
      pdf.text "DATOS DEL VENDEDOR", size: 11
      pdf.move_down 5
    end
    pdf.font "app/assets/fonts/dejavu-sans.book.ttf" do
      pdf.text "Nombre: #{@sale.user.full_name}", size: 10
      pdf.text "Correo electrónico: #{@sale.user.email}", size: 10
      pdf.move_down 20
    end

    # === Bye bye === #
    pdf.font "app/assets/fonts/dejavu-sans.book.ttf" do
      pdf.text "✧₊˚♬⋆♭ Ruby on Records ♫⋆♪˚₊✧", size: 10, align: :center, color: "b92621"
      pdf.move_down 5
      pdf.text "¡Gracias por su compra!", size: 10, align: :center
    end

      pdf.render
  end
end
