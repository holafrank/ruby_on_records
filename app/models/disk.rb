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
  content_type: { in: [ "image/png", "image/jpeg" ] },
  size: { less_than: 2.megabytes }

  validates :audio_sample,
    content_type: { in: [ "audio/mpeg", "audio/ogg", "audio/flac" ] },
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
  validates :price, presence: true, numericality: { greater_than: 0 }

  # :stock ::= Cantidad disponible
  validates :stock, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # :format ::= CD o Vinilo
  validates :format, presence: true, inclusion: { in: %w[CD Vinilo] }

  # :state ::= Nuevo o usado
  validates :state, presence: true, inclusion: { in: %w[Nuevo Usado] }

  validate :valid_stock_for_used_disk


  # === Scopes === #

  scope :has_stock, -> { where("stock > ?", 0) }

  scope :not_deleted, -> { where(logic_delete: false) }

  scope :available, -> { has_stock.not_deleted }

  scope :available_ordered, -> { available.order(:title) }

  scope :outlet, ->(limit = 10, stock_limit = 10) { where(stock: 1..stock_limit).not_deleted.order(stock: :desc).order("RANDOM()").limit(limit) }

  scope :new_arrivals, ->(limit = 10) { available.order(created_at: :desc).limit(limit) }

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

  # === Scopes - Filtros === #

  scope :state_filter, ->(state) { where(state: state) if state.present? && %w[Nuevo Usado].include?(state) }

  scope :format_filter, ->(format) { where(format: format) if format.present? && %w[CD Vinilo].include?(format) }

  scope :artist_filter, ->(artist) { where("LOWER(artist) LIKE ?", "%#{sanitize_sql_like(artist.downcase)}%") if artist.present? && !artist.blank? }

  scope :title_filter, ->(title) { where("LOWER(title) LIKE ?", "%#{sanitize_sql_like(title.downcase)}%") if title.present? && !title.blank? }

  scope :genre_filter, ->(genre_id) { joins(:genres).where(genres: { id: genre_id }) if genre_id.present? }

  scope :price_filter, ->(min_price, max_price) {
    if min_price.present? && max_price.present?
      where(price: min_price..max_price) unless min_price > max_price
    elsif min_price.present? && !max_price.present?
      where(price: min_price..)
    elsif max_price.present? && !min_price.present?
      where("price < ?", max_price)
    end
  }

  scope :date_filter, ->(year_from, year_to) {
    y_from = year_from if year_from.present?
    y_to = year_to if year_to.present?

    if y_from.present? && y_to.present?
      if y_to >= y_from
        where(year: y_from..y_to)
      end
    elsif y_from.present? && !y_to.present?
      where(year: y_from..)
    end
  }


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
    Sale.all_sales_with_disk(id)
  end

  def total_amount_sold
    valid_sales_containing_disk().sum("items.amount")
  end

  def valid_sales_containing_disk
    Sale.valid_sales_with_disk(id)
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

  def remove_audio_sample!
    if audio_sample.attached?
      self.audio_sample.purge
      true
    else
      return false
    end
  end

  private

  def valid_stock_for_used_disk
    if state == "Usado" && stock != 1
      errors.add(:stock, "Si el disco está usado, entonces ese ejemplar es único")
    end
  end

  def audio_only_for_used_disks
    if audio_sample.attached? && state != "Usado"
      errors.add(:audio_sample, "Sólo los discos usados tienen permitido tener un audio adjuntado")
    end
  end

  def at_least_one_genre
    if genres.empty?
      errors.add(:genres, "Un disco debe tener al menos un género")
    end
  end

end
