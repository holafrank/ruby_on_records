class Sale < ApplicationRecord
  # === Relaciones === #

  # Una Venta es ejecutada por un Usuario Vendedor
  belongs_to :user
  # Una Venta es comprada por un Cliente
  belongs_to :client

  # The belongs_to association says that this model's table contains a column which represents a reference to another table.
  # This can be used to set up one-to-one or one-to-many relations, depending on the setup.
  # When used alone, belongs_to produces a one-directional one-to-one relationship.
  # Therefore each book in the above example "knows" its author, but the authors don't know about their books.
  # https://guides.rubyonrails.org/association_basics.html#belongs-to

  # Una Venta contiene varios Items
  has_many :items

  # === Nested Attributes === #
  accepts_nested_attributes_for :items, reject_if: :all_blank, allow_destroy: true

  # A has_many association (...) indicates a one-to-many relationship with another model.
  # You'll often find this association on the "other side" of a belongs_to association.
  # This association indicates that each instance of the model has zero or more instances of another model.
  # https://guides.rubyonrails.org/association_basics.html#has-many

  # === Validadores === #

  # :cancelled ::= Venta cancelada (True) o no (False)
  validates :cancelled, inclusion: { in: [ true, false ] }

  # :total ::= Total a pagar de una Venta
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # === Callbacks === #
  before_validation :set_defaults
  before_save :calculate_total
  after_save :calculate_total_reload

  scope :client_sales, ->(client) { where(client: client).order(:created_at) }

  def sale_contents
    items.includes(:disk)
  end

  def created_at_local_time
    self.created_at - Time.parse("03:00:00").seconds_since_midnight.seconds
  end

  def cancelled?
    self.cancelled
  end

  def stock_available?
    items.all? do |item|
      check = item.enough_stock?
      errors.add(:base, "La venta excede el stock disponible. El stock actual de '#{item.disk.title}' es de #{item.disk.stock} copia/s") unless check
      return check
    end
  end

  def group_items
    hash = Hash.new(0)
    items.each do |item|
      hash[item.disk] += item.amount
      puts " = = = = = DEBUG group_items = = = = ="
      puts " = = = = = DEBUG group_items = = = = ="
      puts " = = = = = #{hash} = = = = ="
      puts " = = = = = DEBUG group_items = = = = ="
      puts " = = = = = DEBUG group_items = = = = ="
    end
    return hash
  end

  def unify_items!
    grouped_items = group_items()

    puts " = = = = = DEBUG unify_items! = = = = ="
    puts " = = = = = DEBUG unify_items! = = = = ="
    puts " = = = = = #{grouped_items} = = = = ="
    puts " = = = = = DEBUG unify_items! = = = = ="
    puts " = = = = = DEBUG unify_items! = = = = ="

    items.destroy_all if persisted?
    items.clear

    grouped_items.each do |id, total_amount|
      puts " = = = = = DEBUG unify_items!grouped_items.each = = = = ="
      puts " = = = = = DEBUG unify_items!grouped_items.each = = = = ="
      puts " = = = = = disco: #{id} total: #{total_amount}= = = = ="
      puts " = = = = = DEBUG unify_items!grouped_items.each = = = = ="
      puts " = = = = = DEBUG unify_items!grouped_items.each = = = = ="
      items.build(
        disk: id,
        amount: total_amount
      )
    end
  end

  def decrease_items_stock
    items.each do |item|
      item.decrease_stock!
    end
  end

  def revert_stock
    items.each do |item|
      item.revert_stock!
    end
  end

  private
  def set_defaults
    self.total ||= 0
    self.cancelled ||= false
  end

  def calculate_total
    self.total = items.sum(&:price)
  end

  def calculate_total_reload
    update_column(:total, items.reload.sum(&:price))
  end
end
