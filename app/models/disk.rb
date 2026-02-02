class Disk < ApplicationRecord
  # === Relaciones === #

  # Un mismo Disco puede estar presente en varios Items de varias Ventas
  has_many :items

  # Un Disco puede pertenecer a varios Géneros, por lo menos a uno.
  has_and_belongs_to_many :genres
  validate :at_least_one_genre

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

  scope :available, -> { where("stock > ?", 0).where(logic_delete: false) }

  scope :available_ordered, -> { where("stock > ?", 0).where(logic_delete: false).order(:title) }

  scope :state_filter, ->(state) { where(state: state) if state.present? && %w[Nuevo Usado].include?(state) }

  scope :format_filter, ->(format) { where(format: format) if format.present? && %w[CD Vinilo].include?(format) }

  scope :artist_filter, ->(artist) { where("LOWER(artist) LIKE ?", "%#{sanitize_sql_like(artist.downcase)}%") if artist.present? && !artist.blank? }

  scope :title_filter, ->(title) { where("LOWER(title) LIKE ?", "%#{sanitize_sql_like(title.downcase)}%") if title.present? && !title.blank? }

  scope :genre_filter, ->(genre_id) { joins(:genres).where(genres: { id: genre_id }) if genre_id.present? }

  scope :price_filter, ->(min_price, max_price) {
    if min_price.present? && max_price.present?
      # Si se ingresa un price_min, pero NO se ingresa un price_max, quiere decir que el cliente busca un disco cuyo precio sea
      # price_min <= x
      # Quiero los discos que cuesten como *mínimo* $10.000.
      # Entonces, 10.000 <= x
      where(price: min_price..max_price) unless min_price > max_price
    elsif min_price.present? && !max_price.present?
      # En cambio, si no se ingresa un price_min, quiere decir que el cliente busca un disco cuyo precio sea
      # price_max >= x
      # Quiero los discos que cuesten como *máximo* $10.000.
      # Entonces, 10.000 >= x
      where(price: min_price..)
    elsif max_price.present? && !min_price.present?
      where("price < ?", max_price)
    end
  }

  scope :date_filter, ->(year_from, year_to) {
    y_from = year_from if year_from.present?
    y_to = year_to if year_to.present?

    if y_from.present? && y_to.present?

      if y_to > y_from
        where(year: y_from..y_to)
      end
      # Si se ingresa tanto year_from como year_to, quiere decir que el cliente busca un disco cuyo año de lanzamiento se encuentre
      # entre el year_from y el year_to
      # Quiero los discos que hayan sido estrenados en algún momento entre el año 1998 y 2002.
      # Entonces, 1998 <= x <= 2002
    elsif y_from.present? && !y_to.present?
      # Si no se ingresa un year_to, quiere decir que el cliente busca un disco cuyo año de lanzamiento sea
      # year_from <= x
      # Quiero los discos que hayan sido estrenados en el año 1998 en adelante.
      # Entonces, 1998 <= x

      where(year: y_from..)
    end
  }

  scope :recommended, ->(disk, limit = 10) {
    return none if disk.genre_ids.empty?
    joins(:genres)
      .where(genres: { id: disk.genre_ids })
      .where.not(id: disk.id)
      .available
      .distinct
      .order("RANDOM()")
      .limit(limit)
  }

  scope :top_sold, ->(limit = 10) {
    joins(items: :sale)
      .where(sales: { cancelled: false })
      .available
      .group(:id)
      .select("disks.*, SUM(items.amount) as total_sold")
      .order("total_sold DESC")
      .limit(limit)
  }

  scope :outlet, ->(limit = 10, stock_limit = 10) { where(stock: 1..stock_limit).order(stock: :desc).limit(limit) }

  scope :new_arrivals, ->(limit = 10) { where("stock > ?", 0).order(created_at: :desc).limit(limit) }

  # === Métodos de instancia === #

  def available?
    has_stock? && !deleted?
  end

  def created_at_local_time
    self.created_at - Time.parse("03:00:00").seconds_since_midnight.seconds
  end

  def deleted_at_local_time
    self.deleted_at - Time.parse("03:00:00").seconds_since_midnight.seconds
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

  def delete_disk!
    update!(logic_delete: true, deleted_at: Time.now(), stock: 0)
  end

  def restore_deleted_disk!
    update!(logic_delete: false, deleted_at: nil, stock: 1)
  end

  def deleted?
    self.logic_delete
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
