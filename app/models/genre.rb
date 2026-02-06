class Genre < ApplicationRecord
  # === Relaciones === #

  # Un Género puede pertenecer a varios Discos
  has_and_belongs_to_many :disks

  # === Validadores === #

  # :genre_name ::= nombre del género musical
  validates :genre_name, presence: true

  scope :ordered, -> { order(:genre_name) }
end
