class Client < ApplicationRecord
  # === Relaciones === #

  # Un Cliente puede tener varias Ventas a su nombre
  has_many :sales

  # === Validadores === #

  # :name ::= Nombre del cliente
  validates :name, presence: true

  # :contact ::= Contacto del cliente, puede ser un teléfono, e-mail, dirección o red social cualquiera.
  validates :contact, presence: true


  def client_with_details
    "#{name} | Contacto: #{contact}"
  end
end
