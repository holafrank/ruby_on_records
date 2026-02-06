class Item < ApplicationRecord
  # === Relaciones === #

  # Un Item pertenece a una Venta
  belongs_to :sale
  # Un Item es un Disco
  belongs_to :disk

  # === Validadores === #

  # :amount ::= Cantidad de un mismo producto comprado en una Venta
  validates :amount, presence: true, numericality: {
    only_integer: true,
    greater_than: 0, message: ": La cantidad vendida de un item debe ser mayor a cero"
  }

  def price
    disk.price * self.amount
  end

  def decrease_stock!
    disk.update!(stock: disk.stock - self.amount)
  end

  def revert_stock!
    disk.update!(stock: disk.stock + self.amount)
  end

  def enough_stock?
    if self.amount > disk.stock
      return false
    end
    return true
  end
end
