json.extract! sale, :id, :cancelled, :total, :created_at, :updated_at
json.url sale_url(sale, format: :json)
