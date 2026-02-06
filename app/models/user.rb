class User < ApplicationRecord
  # === Autenticación === #
  has_secure_password

  # === Roles === #
  # 0 = empleado (por defecto), 1 = gerente, 2 = admin
  enum :role, { employee: 0, manager: 1, admin: 2 }, default: :employee

  # === Relaciones === #

  # Un Usuario Vendedor puede haberse encargado de varias Ventas
  has_many :sales

  # === Validadores === #

  # :full_name ::= Nombre completo de un usuario
  validates :full_name, presence: true, format: { with:  /\A[\p{L}\s]+\z/u,
      message: ": Sólo se permiten ingresar letras para el nombre" }

  # :email ::= Correo electrónico de un usuario
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
      message: ": Formato de correo electrónico incorrecto" }

  validates :password, length: { minimum: 8, message: ": La contraseña debe tener como mínimo 8 coaracteres" }, if: -> { password.present? || password_confirmation.present? }

  # === Métodos de instancia === #

  def get_role
    case role
    when "admin"
      "Administrador"
    when "manager"
      "Gerente"
    when "employee"
      "Empleado"
    else
      "Sin rol establecido"
    end
  end

  def toggle_suspension
    if suspended?
      update!(suspended: false)
    else
      update!(suspended: true)
    end
  end

  # === Métodos de Autorización === #

  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def employee?
    role == "employee"
  end

  def suspended?
    suspended
  end
end
