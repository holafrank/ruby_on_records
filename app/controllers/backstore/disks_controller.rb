class Backstore::DisksController < ApplicationController
  # skip_before_action :require_login, only: [:index, :show]
  before_action :set_disk, only: %i[ show edit update destroy ]

  load_and_authorize_resource

  # GET /disks or /disks.json
  def index
    # Acá también haría falta filtrador y buscador para facilitar tareas de administración
    case params[:filter]
    when "new"
      @disks = :new_disks
    when "used"
      @disks = :used_disks
    else
      @disks = Disk.all
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
    @genres = Genre.all.order(:genre_name)
  end

  # GET /disks/1/edit
  def edit
    @genres = Genre.all.order(:genre_name)
  end

  # POST /disks or /disks.json
  def create
    @disk = Disk.new(disk_params)
    @genres = Genre.all

    respond_to do |format|
      if valid_stock? && @disk.save
        format.html { redirect_to @disk, notice: "Disk was successfully created." }
        format.json { render :show, status: :created, location: @disk }
      else
        @genres = Genre.all.order(:genre_name)
        render :new, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /disks/1 or /disks/1.json
  def update
    respond_to do |format|
      if valid_stock? && @disk.update(disk_params)
        format.html { redirect_to @disk, notice: "Disk was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @disk }
      else
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
          format.html { redirect_to backstore_disks_path, notice: "Disco dado de #{message}.", status: :see_other }
          format.json { head :no_content }
        end
      else
        flash[:error] = "No se pudo dar de #{message} al disco: #{@disk.errors.full_messages.join(', ')}"
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

    # Si el disco está usado, entonces ese ejemplar es único.
    def valid_stock?
      if @disk.state == "Usado"
        @disk.stock == 1
      else
        @disk.has_stock?
      end
    end
end
