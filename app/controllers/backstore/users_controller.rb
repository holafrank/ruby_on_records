class Backstore::UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  load_and_authorize_resource

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
    @user_sales = @user.sales
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
      @user = User.new(user_params)
      respond_to do |format|
        if @user.save
          flash[:notice] = "Usuario creado exitosamente"
          format.html { redirect_to backstore_user_path(@user) }
          format.json { render :show, status: :created, location: @user }
        else
          flash[:alert] = "No se pudo crear usuario: #{@user.errors.full_messages.join(', ')}"
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      update_params = prepare_update_params()
      password_has_changed(update_params)

      ActiveRecord::Base.transaction do
        if @user.errors.empty? && @user.update(update_params)
          flash[:notice] = "Usuario actualizado"
          format.html { redirect_to backstore_user_path(@user), status: :see_other }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    ActiveRecord::Base.transaction do
      @user.toggle_suspension
      if @user.save
        flash[:notice] = "Suspensión resuelta."
        redirect_to backstore_user_path(@user)
      else
        flash[:alert] = "No se pudo manejar la suspensión del usuario: #{@user.errors.full_messages.join(', ')}"
        redirect_to backstore_user_path(@user)
        raise ActiveRecord::Rollback
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    def user_params
      params.require(:user).permit(:full_name, :email, :role, :password, :password_confirmation)
    end

    def change_password?(params)
      params[:password].present? && params[:password_confirmation].present?
    end

    def passwords_match?(params)
      params[:password] == params[:password_confirmation]
    end

    def password_has_changed(params)
      change_password?(params) && passwords_match?(params)
    end

    def prepare_update_params
      params = user_params.to_h
      # Si hay intención de cambiar la contraseña
      if change_password?(params)

        if passwords_match?(params)
          return params
        else
          # Si falla validación, eliminar campos de contraseña y generar error
          @user.errors.add(:base, "No se pudo cambiar contraseña: Las contraseñas no coinciden.")
          params.except!(:password, :password_confirmation)
        end

      else
        # Si no hay intención de cambiar la contraseña... borrarlos también
        params.except!(:password, :password_confirmation)
      end
      params
    end
end
