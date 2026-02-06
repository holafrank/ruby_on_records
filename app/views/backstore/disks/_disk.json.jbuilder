json.extract! disk, :id, :title, :artist, :year, :description, :price, :stock, :format, :state, :created_at, :updated_at
json.url disk_url(disk, format: :json)
