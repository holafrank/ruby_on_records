class Backstore::DisksController < ApplicationController
  # skip_before_action :require_login, only: [:index, :show]
  before_action :set_disk, only: %i[ show edit update destroy ]

  load_and_authorize_resource

  # GET /disks or /disks.json
  def index
    @disks = Disk.all
    @genres = Genre.ordered

    errors ||= []

    @disks = @disks.artist_filter(params[:artist])
    @disks = @disks.title_filter(params[:title])
    @disks = @disks.format_filter(params[:format])
    @disks = @disks.state_filter(params[:state])
    @disks = @disks.genre_filter(params[:genre])

    # Notificar si los parámetros relativos a fecha de lanzamiento son válidos
    if invalid_date_params?
      errors << "El año de incio del rango no puede ser mayor al año final. "
    else
      @disks = @disks.date_filter(params[:year_from], params[:year_to])
    end

    # Notificar si los parámetros relativos a precios son válidos
    if invalid_price_params?
      errors << "El precio mínimo no puede ser mayor al precio máximo."
    else
      @disks = @disks.price_filter(params[:min_price], params[:max_price])
    end

    if errors.any?
      flash[:error] = "Parámetros inválidos:"
      flash[:alert] = errors.join()
    end
  end

  # GET /disks/1 or /disks/1.json
  def show
    @disk_sales = @disk.sales_containing_disk()
    @total_amount = @disk.total_amount_sold()
    @total_sold = @total_amount * @disk.price
  end

  # GET /disks/new
  def new
    @disk = Disk.new
    @genres = Genre.ordered
  end

  # GET /disks/1/edit
  def edit
    @genres = Genre.ordered
  end

  # POST /disks or /disks.json
  def create
    @disk = Disk.new(disk_params)
    @genres = Genre.ordered

    respond_to do |format|
      if valid_stock? && @disk.save
        flash[:notice] = "Disco creado exitosamente"
        format.html { redirect_to @disk }
        format.json { render :show, status: :created, location: @disk }
      else
        puts "-------------- DEBUG --------------"
        puts "-------------- NO SE CREÓ EL DISCO --------------"
        puts "-------------- DEBUG --------------"
        flash[:error] = "No se pudo crear el disco:"
        flash[:alert] = "#{@disk.errors.full_messages.join(', ')}"
        @genres = Genre.ordered
        render :new, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /disks/1 or /disks/1.json
  def update
    @genres = Genre.ordered
    respond_to do |format|
      if @disk.update(disk_params)
        flash[:notice] = "Disco editado exitosamente"
        format.html { redirect_to @disk, status: :see_other }
        format.json { render :show, status: :ok, location: @disk }
      else
        @genres = Genre.ordered
        flash[:error] = "No se pudo editar el disco:"
        flash[:alert] = "#{@disk.errors.full_messages.join(', ')}"
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @disk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /disks/1 or /disks/1.json
  def destroy
    ActiveRecord::Base.transaction do
      if @disk.deleted?
        @disk.restore_deleted_disk!
        message = "alta"
      else
        @disk.delete_disk!
        message = "baja"
      end
      if @disk.save
        respond_to do |format|
          flash[:notice] = "Disco dado de #{message}"
          format.html { redirect_to backstore_disks_path, status: :see_other }
          format.json { head :no_content }
        end
      else
        flash[:error] = "No se pudo dar de #{message} al disco:"
        flash[:alert] = "#{@disk.errors.full_messages.join(', ')}"
        redirect_to backstore_disks_path
        raise ActiveRecord::Rollback
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_disk
      @disk = Disk.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def disk_params
      params.require(:disk).permit(
        :title, :artist, :year, :description, :price, :stock, :format, :state, :cover,
        genre_ids: []
      )
    end

    def filter_params
      params.permit(:commit, :filter, :title, :artist, :format, :state, :year_from, :year_to, :price_min, :price_max, :genre)
    end

    def invalid_price_params?
      params[:min_price].present? && params[:max_price].present? && params[:min_price] > params[:max_price]
    end

    def invalid_date_params?
      params[:year_from].present? && params[:year_to].present? && params[:year_to] < params[:year_from]
    end

end
