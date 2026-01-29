class DisksController < ApplicationController
  # skip_before_action :require_login, only: [:index, :show]
  before_action :set_disk, only: %i[ show edit update destroy ]

  load_and_authorize_resource

  # GET /disks or /disks.json
  def index
    @disks = Disk.available
    @genres = Genre.ordered

    puts "#=#=#=#=#=#=#=#=#=#="
    puts "#=#=#=#=#=#=#=#=#=#="
    puts "#=#=#=#=#=#=#=#=#=#="
    puts "#=#=#=#=#=#=#=#=#=#="
    puts "#{params.inspect}"
    puts "#=#=#=#=#=#=#=#=#=#="
    puts "#=#=#=#=#=#=#=#=#=#="
    puts "#=#=#=#=#=#=#=#=#=#="
    puts "#=#=#=#=#=#=#=#=#=#="

    case params[:filter]
    when "new"
      @disks = @disks.state_filter("Nuevo")
    when "used"
      @disks = @disks.state_filter("Usado")
    else
      @disks = @disks.artist_filter(params[:artist])
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#{@disks}"
      puts "#{@disks.count}"
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      @disks = @disks.title_filter(params[:title])
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#{@disks}"
      puts "#{@disks.count}"
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      @disks = @disks.format_filter(params[:format])
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#{@disks}"
      puts "#{@disks.count}"
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      @disks = @disks.state_filter(params[:state])
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#{@disks}"
      puts "#{@disks.count}"
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      @disks = @disks.genre_filter(params[:genre])
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#{@disks}"
      puts "#{@disks.count}"
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      @disks = @disks.date_filter(params[:year_from], params[:year_to])
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#{@disks}"
      puts "#{@disks.count}"
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
      puts "#=#=#=#=#=#=#=#=#=#="
    end
  end

  # GET /disks/1 or /disks/1.json
  def show
    @recommended_disks = Disk.recommended(@disk, 10)
  end

  # GET /disks/new
  def new
    @disk = Disk.new
  end

  # GET /disks/1/edit
  def edit
  end

  # POST /disks or /disks.json
  def create
    @disk = Disk.new(disk_params)

    respond_to do |format|
      if @disk.save
        format.html { redirect_to @disk, notice: "Disk was successfully created." }
        format.json { render :show, status: :created, location: @disk }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @disk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /disks/1 or /disks/1.json
  def update
    respond_to do |format|
      if @disk.update(disk_params)
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
    @disk.destroy!

    respond_to do |format|
      format.html { redirect_to disks_path, notice: "Disk was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_disk
      @disk = Disk.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def disk_params
      params.require(:disk).permit(:title, :artist, :year, :description, :price, :stock, :format, :state, genre_ids: [])
    end

    def filter_params
      params.permit(:commit, :filter, :title, :artist, :format, :state, :year_from, :year_to, :price_min, :price_max, :genre)
    end
end
