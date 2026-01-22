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
          format.html {
            redirect_to backstore_user_path(@user), notice: "Usuario creado exitosamente ^-^"
          }
          format.json { render :show, status: :created, location: @user }
        else
          format.html {
            flash.now[:alert] = "Algo salió mal..."
            render :new, status: :unprocessable_entity
          }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      update_params = prepare_update_params()
      alert = ""
      notice = "Usuario actualizado."

      if password_has_changed(update_params)
        notice += " Contraseña modificada."
      elsif @user.errors.any? # quizás? de esta forma se si falló o simplemente no había intención
        # Cuando no hay intención de cambiar contraseña, aparece esto igual... Necesito otra forma.
        alert += " No se pudo cambiar contraseña: #{@user.errors.full_messages.join(', ')}"
      end
      if @user.errors.empty? && @user.update(update_params) # if @user.errors.empty && @user.update(update_params) ... else mostrar errores, puede incluir fallo en el cambio de la contraseña o no
        format.html { redirect_to backstore_user_path(@user), notice: notice, status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, alert: alert, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
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
          @user.errors.add(:base, "Las contraseñas no coinciden.")
          params.except!(:password, :password_confirmation)
        end

      else
        # Si no hay intención de cambiar la contraseña... borrarlos también
        params.except!(:password, :password_confirmation)
      end
      params
    end
end
