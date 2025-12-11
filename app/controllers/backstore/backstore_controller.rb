# app/controllers/backstore/base_controller.rb
class Backstore::BaseController < ApplicationController
  #before_action :authenticate_user!
  #before_action :require_backstore_access!
  #
  # Aún ni se si realmente necesito un "Dashboard"
  #
  # layout "backstore"  # Layout separado para backstore
  #
  # private
  #
  # def require_backstore_access!
  #   # Ajusta según tus roles
  #   unless current_user.admin? || current_user.manager? || current_user.employee?
  #     redirect_to root_path, alert: "Acceso restringido al personal autorizado"
  #   end
  # end
end
