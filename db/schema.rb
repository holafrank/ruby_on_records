# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_30_222420) do
  create_table "clients", force: :cascade do |t|
    t.string "contact"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "disks", force: :cascade do |t|
    t.string "artist", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "format", null: false
    t.float "price", null: false
    t.string "state", null: false
    t.integer "stock", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
  end

  create_table "disks_genres", id: false, force: :cascade do |t|
    t.integer "disk_id", null: false
    t.integer "genre_id", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "genre_name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer "amount"
    t.datetime "created_at", null: false
    t.integer "disk_id", null: false
    t.integer "sale_id", null: false
    t.datetime "updated_at", null: false
    t.index ["disk_id"], name: "index_items_on_disk_id"
    t.index ["sale_id"], name: "index_items_on_sale_id"
  end

  create_table "sales", force: :cascade do |t|
    t.boolean "cancelled", default: false, null: false
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.float "total", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["client_id"], name: "index_sales_on_client_id"
    t.index ["user_id"], name: "index_sales_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "items", "disks"
  add_foreign_key "items", "sales"
  add_foreign_key "sales", "clients"
  add_foreign_key "sales", "users"
end
