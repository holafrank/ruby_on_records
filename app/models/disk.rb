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
  has_many_attached :images, dependent: :destroy
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

  # validates :audio_sample,
  # validates :audio_sample,
  # validates :audio_sample,
  validates :audio_sample,
    content_type: [ "audio/mpeg", "audio/ogg", "audio/flac" ],
    size: { less_than_or_equal_to: 30.megabytes },
    duration: { less_than_or_equal_to: 30.seconds },
    if: -> { state == "Usado" && audio_sample.attached? }

  validate :audio_only_for_used_disks

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

  scope :state_filter, ->(state) { where(state: state) if state.present? && %w[Nuevo Usado].include?(state) }

  scope :like_search, ->(collumn, word) {
    if collumn.present? && %w[artist title].include?(collumn) && word.present? && !word.blank?
      word = sanitize_sql_like(word.downcase)
      query.where("LOWER(#{collumn}) LIKE ?", "%#{word}%")
    end
  }

  scope :recommended, ->(disk, limit = 10) {
    return none if disk.genre_ids.empty?
    joins(:genres)
      .where(genres: { id: disk.genre_ids })
      .where.not(id: disk.id)
      .has_stock
      .distinct
      .order("RANDOM()")
      .limit(limit)
  }

  scope :disk_filtering, ->(filters = {}) {
    query = all.has_stock # ¿ O self.has_stock ?

    # Filtro por "estado" del disco, puede ser "Nuevo" o "Usado".
    if filters[:state].present? && %w[Nuevo Usado].include?(filters[:state])
      query = query.where(state: filters[:state])
    end

    # Filtro por "formato" del disco, puede ser "CD" o "Vinilo".
    if filters[:format].present? && %w[CD Vinilo].include?(filters[:format])
      query.where(format: filters[:format])
    end

    # Filtro por "género" del disco.
    if filters[:genre].present? && !filters[:genre].blank?
      query.joins(:genres).where(genres: { genre_name: filters[:genre] })
    end

    # Filtro por "artista" del disco. Con "LIKE" puedo hacer búsquedas más flexibles y generalizadas que con igualdades exactas.
    if filters[:artist].present? && !filters[:artist].blank?
      artist = sanitize_sql_like(filters[:artist].downcase)
      query.where("LOWER(artist) LIKE ?", "%#{artist}%")
    end

    # Filtro por "título" del disco. Con "LIKE" puedo hacer búsquedas más flexibles y generalizadas que con igualdades exactas.
    if filters[:title].present? && !filters[:title].blank?
      title = sanitize_sql_like(filters[:title].downcase)
      query.where("LOWER(title) LIKE ?", "%#{title}%")
    end

    # Si se ingresa tanto year_from como year_to, quiere decir que el cliente busca un disco cuyo año de lanzamiento se encuentre
    # entre el year_from y el year_to
    # Quiero los discos que hayan sido estrenados en algún momento entre el año 1998 y 2002.
    # Entonces, 1998 <= x <= 2002
    if filters[:year_from].present? && filters[:year_to].present?
      query.where(year: Time.new(filters[:year_from])..Time.new(filters[:year_to])) unless filters[:year_to] > filters[:year_from]
    end

    # Si no se ingresa un year_to, quiere decir que el cliente busca un disco cuyo año de lanzamiento sea
    # year_from <= x
    # Quiero los discos que hayan sido estrenados en el año 1998 en adelante.
    # Entonces, 1998 <= x
    if filters[:year_from].present? && !filters[:year_to].present?
      query.where(year: Time.new(filters[:year_from])..)
    end

    # Tenemos price_min <= x <= price_max.
    if filters[:price_min].present? && filters[:price_max].present?
      query.where(price: filters[:price_min]..filters[:price_max]) unless filters[:price_min] > filters[:price_max]
    end

    # Si se ingresa un price_min, pero NO se ingresa un price_max, quiere decir que el cliente busca un disco cuyo precio sea
    # price_min <= x
    # Quiero los discos que cuesten como *mínimo* $10.000.
    # Entonces, 10.000 <= x
    if filters[:price_min].present? && !filters[:price_max].present?
      query.where(price: filters[:price_min]..)
    end

    # En cambio, si no se ingresa un price_min, quiere decir que el cliente busca un disco cuyo precio sea
    # price_max >= x
    # Quiero los discos que cuesten como *máximo* $10.000.
    # Entonces, 10.000 >= x
    if filters[:price_max].present? && !filters[:price_min].present?
      query.where("price < ?", filters[:price_max])
    end

    query
  }

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

  def audio_only_for_used_disks
    if audio_sample.attached? && state != "Usado"
      errors.add(:audio_sample, "Sólo los discos usados tienen permitido tener un audio adjuntado.")
    end
  end

  def at_least_one_genre
    if genres.empty?
      errors.add(:genres, "Un disco debe tener al menos un género.")
    end
  end
end
