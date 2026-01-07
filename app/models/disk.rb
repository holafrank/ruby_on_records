class Disk < ApplicationRecord
  # === Relaciones === #

  # Un mismo Disco puede estar presente en varios Items de varias Ventas
  has_many :items

  # Un Disco puede pertenecer a varios Géneros, por lo menos a uno.
  has_and_belongs_to_many :genres

  validate :at_least_one_genre

  # A has_and_belongs_to_many association creates a direct many-to-many relationship with another model, with no intervening model.
  # This association indicates that each instance of the declaring model refers to zero or more instances of another model.
  # You'd use has_and_belongs_to_many when:
  # * The association is simple and does not require additional attributes or behaviors on the join table.
  # * You do not need validations, callbacks, or extra methods on the join table.
  # https://guides.rubyonrails.org/association_basics.html#has-and-belongs-to-many

  # === Active Storage === #

  has_one_attached :cover, dependent: :destroy
  has_one_attached :audio_sample, dependent: :destroy

  # === Active Storage Validations === #
  # https://github.com/igorkasyanchuk/active_storage_validations

  validates :cover, attached: true,
  content_type: { in: [ "image/png", "image/jpeg" ], message: "must be a JPEG or PNG" },
  size: { less_than: 2.megabytes, message: "size cannot be larger than 2 megabytes" }# ,
  # dimension: { width: { min: 300, max: 1000 }, height: { min: 300, max: 1000 }, message: "height or width is out of bounds" },
  # aspect_ratio: :square
  # Quiero lograr esto ^ pero no lo estoy pudiendo hacer...
  # No se por qué no anda

  validates :audio_sample, content_type: [ "audio/mpeg", "audio/ogg", "audio/flac" ]
  validates :audio_sample, size: { less_than_or_equal_to: 30.megabytes }
  validates :audio_sample, duration: { less_than_or_equal_to: 30.seconds }

  # === Validadores === #

  # :title ::= Titulo del disco
  validates :title, presence: true

  # :artist ::= Artista o banda
  validates :artist, presence: true

  # :year ::= Año de lanzamiento
  validates :year, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1870,
    less_than_or_equal_to: Date.current.year
  }

  # :description ::= Texto descriptivo
  validates :description, presence: true, length: { minimum: 10 }

  # :price ::= Precio unitario
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # :stock ::= Cantidad disponible
  validates :stock, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # :format ::= CD o Vinilo
  validates :format, presence: true, inclusion: { in: %w[CD Vinilo],
    message: "No trabajamos con formato '%{value}'" }

  # :state ::= Nuevo o usado
  validates :state, presence: true, inclusion: { in: %w[Nuevo Usado],
    message: "No trabajamos discos en estado '%{value}'" }


  # === Scopes === #

  # Agregar en todos que ADEMAS el stock sea mayor a cero
  # Porque sino implicaría usar la variable de instancia has_stock? miles de veces


  scope :has_stock, -> { where("stock > ?", 0) }

  scope :new_disks, -> { where(state: "Nuevo").has_stock }

  scope :used_disks, -> { where(state: "Usado").has_stock }

  scope :top_sold, ->(limit = 10) {
    joins(items: :sale)
      .where(sales: { cancelled: false })
      .has_stock
      .group(:id)
      .select("disks.*, SUM(items.amount) as total_sold")
      .order("total_sold DESC")
      .limit(limit)
  }

  scope :outlet, ->(limit = 10, stock_limit = 10) { where(stock: 1..stock_limit).order(stock: :desc).limit(limit) }

  scope :new_arrivals, ->(limit = 10) { where("stock > ?", 0).order(created_at: :desc).limit(limit) }

  # === Métodos de instancia === #

  def created_at_local_time
    self.created_at - Time.parse("03:00:00").seconds_since_midnight.seconds
  end

  def sales_containing_disk
    Sale.joins(:items)
            .where(items: { disk_id: id })
            .distinct
  end

  def total_amount_sold
    valid_sales_containing_disk().sum("items.amount")
  end

  def valid_sales_containing_disk
    Sale.joins(:items)
            .where(items: { disk_id: id })
            .where(cancelled: false)
            .distinct
  end

  def title_with_details
    "#{title} - #{artist} | $#{price} | Stock: #{stock}"
  end

  def has_stock?
    self.stock > 0
  end

  private

  def at_least_one_genre
    if genres.empty?
      errors.add(:genres, "Un disco debe tener al menos un género.")
    end
  end
end
