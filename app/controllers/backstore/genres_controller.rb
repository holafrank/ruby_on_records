
class Backstore::GenresController < ApplicationController
  before_action :set_genre, only: %i[ show edit update destroy ]

  load_and_authorize_resource except: [ :index, :show ]

  # GET /genres or /genres.json
  def index
    @genres = Genre.all
  end

  # GET /genres/1 or /genres/1.json
  def show
    @disks_of_this_genre = @genre.disks.order(:title).where("stock > 0")
  end

  # GET /genres/new
  def new
    @genre = Genre.new
  end

  # GET /genres/1/edit
  def edit
  end

  # POST /genres or /genres.json
  def create
    @genre = Genre.new(genre_params)

    respond_to do |format|
      if @genre.save
        format.html { redirect_to @genre, notice: "Genre was successfully created." }
        format.json { render :show, status: :created, location: @genre }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /genres/1 or /genres/1.json
  def update
    respond_to do |format|
      if @genre.update(genre_params)
        format.html { redirect_to @genre, notice: "Genre was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @genre }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /genres/1 or /genres/1.json
  def destroy
    @genre.destroy!

    respond_to do |format|
      format.html { redirect_to genres_path, notice: "Genre was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_genre
      @genre = Genre.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def genre_params
      params.expect(genre: [ :genre_name ])
    end
end
