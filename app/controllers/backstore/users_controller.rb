class Backstore::UsersController < ApplicationController

  before_action :set_user, only: %i[ show edit update destroy ]

  # load_and_authorize_resource
  # Dejando eso de arriba ^ se hacen todos los authorize! automaticamente, para TODOS los métodos del controlador
  # load_and_authorize_resource except: [:index] es otra forma, para exceptuar
  #

  # GET /users or /users.json
  def index
    authorize! :index, User # , :message => "No autorizo."
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
    authorize! :show, @user
  end

  # GET /users/new
  def new
    authorize! :new, @user
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize! :update, @user
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    authorize! :create, @user

    if user.save
      flash[:notice] = "Usuario creado exitosamente"
      respond_to do |format|
        if @user.save
          format.html { redirect_to @user, notice: "User was successfully created." }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
      redirect_to "/users/new"
    else
      # mensaje de error

      flash[:alert] = "Algo salió mal..."
      redirect_to "/users/new"
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    authorize! :update, @user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    authorize! :destroy, @user
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [ :full_name, :email, :password_digest ])
    end
end
