class Backstore::SalesController < ApplicationController
  before_action :set_sale, only: %i[ show edit update destroy ]

  load_and_authorize_resource

  # GET /sales or /sales.json
  def index
    @sales = Sale.all.page(params[:page])
  end

  # GET /sales/1 or /sales/1.json
  def show
    @sale_content = @sale.sale_contents
  end

  # GET /sales/new
  def new
    @sale = Sale.new
    @sale.items.build
    @all_clients = Client.latest
    @available_disks = Disk.available_ordered
  end

  # GET /sales/1/edit
  def edit
    @all_clients = Client.latest
    @available_disks = Disk.available_ordered
  end

  # POST /sales or /sales.json
  def create
      @sale = Sale.new(sale_params)
      @sale.user = current_user
      if @sale.save
        @sale.decrease_items_stock
        flash[:notice] = "Venta creada exitosamente"
        redirect_to backstore_sale_path(@sale)
      else
        @all_clients = Client.latest
        @available_disks = Disk.available_ordered
        flash[:error] = "No se pudo concretar la venta"
        render :new, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /sales/1 or /sales/1.json
  def update
    # WIP !!!
    # NO ESTOY PUDIENDO MANEJAR EL EDIT DE LAS VENTAS
    # PARA ELIMINAR UN DISCO DE UNA VENTA YA EXISTENTE
    # PUEDO BAJAR Y SUBIRLE EL STOCK
    # PUEDO AGREGAR NUEVOS DISCOS
    # PERO ELIMINAR UNO QUE YA ESTÁ PERSISTIDO ES UN DOLOR DE CABEZA
    # CONSULTAR?

    ActiveRecord::Base.transaction do
      # @sale.destroy_all_items
      # if valid && @sale.update(sale_params)

      @sale.revert_items_stock
      if @sale.update(sale_params)
        puts " = = = = = = = "
        puts " = = = valid update !! = = = = "
        puts " = = = = = = = "


        puts " = = = = = = = "
        puts "Items después de update: #{@sale.items.map(&:disk_id).join(', ')}"
        puts " = = = = = = = "

        @sale.decrease_items_stock

        puts " = = = = = = = "
        puts "Items después de unify: #{@sale.items.map(&:disk_id).join(', ')}"
        puts " = = = = = = = "
        flash[:notice] = "Venta editada exitosamente"
        redirect_to backstore_sale_path(@sale)
      else
        puts " = = = = = = = "
        puts " = = = ERROR !! = = = = "
        puts " = = = #{@sale.errors.full_messages.join(', ')} !! = = = = "
        puts " = = = = = = = "
        @all_clients = Client.latest
        @available_disks = Disk.available_ordered
        flash[:error] = "No se pudo editar la venta:"
        flash[:alert] = "#{@sale.errors.full_messages.join(', ')}"
        redirect_to backstore_sale_path(@sale)
        raise ActiveRecord::Rollback
      end
    end
  end

  # DELETE /sales/1 or /sales/1.json
  def destroy
    # authorize! :destroy, @sale

    # Verificar que no esté ya cancelada
    if @sale.cancelled?
      flash[:warning] = "Esta venta ya está cancelada"
      redirect_to backstore_sale_path(@sale)
      return
    end

    ActiveRecord::Base.transaction do
      @sale.cancelled = true

      @sale.revert_items_stock
      @sale.total = 0.0

      if @sale.save
        flash[:notice] = "Venta cancelada exitosamente"
        redirect_to backstore_sale_path(@sale)
      else
        flash[:error] = "No se pudo cancelar la venta: #{@sale.errors.full_messages.join(', ')}"
        redirect_to backstore_sale_path(@sale)
        raise ActiveRecord::Rollback
      end
    end
  end

  def set_available_disks
    @available_disks = Disk.available_ordered
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
