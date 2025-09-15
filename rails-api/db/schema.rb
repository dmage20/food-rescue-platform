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

ActiveRecord::Schema[7.2].define(version: 2025_09_14_060821) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bundle_items", force: :cascade do |t|
    t.bigint "bundle_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bundle_id", "product_id"], name: "index_bundle_items_on_bundle_id_and_product_id", unique: true
    t.index ["bundle_id"], name: "index_bundle_items_on_bundle_id"
    t.index ["product_id"], name: "index_bundle_items_on_product_id"
  end

  create_table "bundles", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "total_original_price", precision: 10, scale: 2, null: false
    t.decimal "bundle_price", precision: 10, scale: 2, null: false
    t.integer "discount_percentage", null: false
    t.integer "available_quantity", default: 0, null: false
    t.datetime "expires_at", null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_bundles_on_expires_at"
    t.index ["merchant_id", "available_quantity"], name: "index_bundles_on_merchant_id_and_available_quantity"
    t.index ["merchant_id"], name: "index_bundles_on_merchant_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.decimal "preferred_radius", precision: 4, scale: 1, default: "5.0"
    t.json "dietary_preferences"
    t.json "favorite_categories"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.text "address", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.json "business_hours"
    t.text "pickup_instructions"
    t.string "specialty"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_merchants_on_email", unique: true
    t.index ["latitude", "longitude"], name: "index_merchants_on_latitude_and_longitude"
    t.index ["reset_password_token"], name: "index_merchants_on_reset_password_token", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "name", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price_at_purchase", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_order_items_on_item_type_and_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "merchant_id", null: false
    t.string "status", default: "pending", null: false
    t.string "confirmation_code", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.datetime "pickup_window_start", null: false
    t.datetime "pickup_window_end", null: false
    t.datetime "picked_up_at"
    t.text "special_instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_code"], name: "index_orders_on_confirmation_code", unique: true
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
    t.index ["pickup_window_start"], name: "index_orders_on_pickup_window_start"
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "category", null: false
    t.decimal "original_price", precision: 10, scale: 2, null: false
    t.decimal "discounted_price", precision: 10, scale: 2, null: false
    t.integer "discount_percentage", null: false
    t.integer "available_quantity", default: 0, null: false
    t.json "allergens"
    t.json "dietary_tags"
    t.datetime "expires_at", null: false
    t.json "images"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_products_on_category"
    t.index ["expires_at"], name: "index_products_on_expires_at"
    t.index ["merchant_id", "available_quantity"], name: "index_products_on_merchant_id_and_available_quantity"
    t.index ["merchant_id"], name: "index_products_on_merchant_id"
  end

  add_foreign_key "bundle_items", "bundles"
  add_foreign_key "bundle_items", "products"
  add_foreign_key "bundles", "merchants"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "merchants"
  add_foreign_key "products", "merchants"
end
