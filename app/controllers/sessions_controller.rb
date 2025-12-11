class SessionsController < ApplicationController
  # skip_before_action :require_login, only: [:new, :create]
  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password]) # bcrypt hace lo suyo
      session[:user_id] = user.id
      flash[:notice] = "¡Bienvenidx! ^-^"
      redirect_to root_path
    else
      flash[:alert] = "Credenciales incorrectas. Intente de nuevo."
      render :new
    end
  end

  def new
    # Muestra el form para el login
  end

  def destroy
    if current_user.present?
      session[:user_id] = nil
      redirect_to root_path
    end
  end
end
