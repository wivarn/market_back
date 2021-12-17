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

ActiveRecord::Schema.define(version: 2021_12_16_082448) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "account_active_session_keys", primary_key: ["account_id", "session_id"], force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "session_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "last_use", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["account_id"], name: "index_account_active_session_keys_on_account_id"
  end

  create_table "account_authentication_audit_logs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "message", null: false
    t.jsonb "metadata"
    t.index ["account_id", "at"], name: "audit_account_at_idx"
    t.index ["account_id"], name: "index_account_authentication_audit_logs_on_account_id"
    t.index ["at"], name: "audit_at_idx"
  end

  create_table "account_jwt_refresh_keys", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "key", null: false
    t.datetime "deadline", default: -> { "(CURRENT_TIMESTAMP + ((14 || ' days'::text))::interval)" }, null: false
    t.index ["account_id"], name: "account_jwt_rk_account_id_idx"
    t.index ["account_id"], name: "index_account_jwt_refresh_keys_on_account_id"
  end

  create_table "account_lockouts", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
    t.datetime "email_last_sent"
  end

  create_table "account_login_change_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "login", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_login_failures", force: :cascade do |t|
    t.integer "number", default: 1, null: false
  end

  create_table "account_otp_keys", force: :cascade do |t|
    t.string "key", null: false
    t.integer "num_failures", default: 0, null: false
    t.datetime "last_use", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "account_password_hashes", force: :cascade do |t|
    t.string "password_hash", null: false
  end

  create_table "account_password_reset_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "account_previous_password_hashes", force: :cascade do |t|
    t.bigint "account_id"
    t.string "password_hash", null: false
    t.index ["account_id"], name: "index_account_previous_password_hashes_on_account_id"
  end

  create_table "account_recovery_codes", primary_key: ["id", "code"], force: :cascade do |t|
    t.bigint "id", null: false
    t.string "code", null: false
  end

  create_table "account_verification_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "requested_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.citext "email", null: false
    t.string "status", default: "unverified", null: false
    t.string "given_name", null: false
    t.string "family_name", null: false
    t.string "picture"
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true, where: "((status)::text = ANY ((ARRAY['unverified'::character varying, 'verified'::character varying])::text[]))"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "street1", null: false
    t.string "street2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip", null: false
    t.string "country", null: false
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cart_id", "listing_id"], name: "index_cart_items_on_cart_id_and_listing_id", unique: true
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.string "checkout_session_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buyer_id", "seller_id"], name: "index_carts_on_buyer_id_and_seller_id", unique: true
    t.index ["buyer_id"], name: "index_carts_on_buyer_id"
  end

  create_table "email_settings", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "marketing", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_email_settings_on_account_id", unique: true
  end

  create_table "listing_templates", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "category"
    t.string "subcategory"
    t.string "tags", array: true
    t.string "title"
    t.string "grading_company"
    t.decimal "condition", precision: 3, scale: 1
    t.text "description"
    t.decimal "price", precision: 12, scale: 4
    t.decimal "domestic_shipping", precision: 12, scale: 4
    t.decimal "international_shipping", precision: 12, scale: 4
    t.decimal "combined_shipping", precision: 12, scale: 4
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "accept_offers", default: false, null: false
    t.index ["account_id"], name: "index_listing_templates_on_account_id", unique: true
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.jsonb "photos"
    t.string "category", null: false
    t.string "subcategory", null: false
    t.string "tags", default: [], array: true
    t.string "title", null: false
    t.string "grading_company"
    t.decimal "condition", precision: 3, scale: 1, default: "0.0"
    t.text "description"
    t.string "currency", limit: 3, null: false
    t.decimal "price", precision: 12, scale: 4, default: "0.0"
    t.decimal "domestic_shipping", precision: 12, scale: 4, default: "0.0"
    t.decimal "international_shipping", precision: 12, scale: 4
    t.decimal "combined_shipping", precision: 12, scale: 4
    t.string "shipping_country", limit: 3, null: false
    t.string "aasm_state", default: "draft", null: false
    t.datetime "reserved_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "offered_at"
    t.boolean "accept_offers", default: false, null: false
    t.index ["aasm_state"], name: "index_listings_on_aasm_state"
    t.index ["account_id"], name: "index_listings_on_account_id"
    t.index ["category"], name: "index_listings_on_category"
    t.index ["condition"], name: "index_listings_on_condition"
    t.index ["currency"], name: "index_listings_on_currency"
    t.index ["grading_company"], name: "index_listings_on_grading_company"
    t.index ["price"], name: "index_listings_on_price"
    t.index ["subcategory"], name: "index_listings_on_subcategory"
    t.index ["title"], name: "index_listings_on_title"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "recipient_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "offers", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "buyer_id", null: false
    t.string "aasm_state", default: "active", null: false
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.datetime "cancelled_at"
    t.boolean "counter", default: false, null: false
    t.decimal "amount", precision: 12, scale: 4, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "expired_at"
    t.datetime "paid_at"
    t.datetime "last_reminder_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["aasm_state"], name: "index_offers_on_aasm_state"
    t.index ["buyer_id"], name: "index_offers_on_buyer_id"
    t.index ["listing_id"], name: "index_offers_on_listing_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "listing_id", null: false
    t.decimal "shipping", precision: 12, scale: 4, default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["listing_id"], name: "index_order_items_on_listing_id", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.string "aasm_state", default: "reserved", null: false
    t.datetime "reserved_at"
    t.datetime "shipped_at"
    t.datetime "received_at"
    t.string "tracking"
    t.decimal "total", precision: 12, scale: 4
    t.string "currency", limit: 3
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "payment_intent_id"
    t.datetime "pending_shipment_at"
    t.datetime "cancelled_at"
    t.boolean "recommend"
    t.text "feedback"
    t.datetime "feedback_at"
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["seller_id"], name: "index_orders_on_seller_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "stripe_id"
    t.string "currency", limit: 3, default: "USD", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_payments_on_account_id", unique: true
  end

  create_table "refunds", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "refund_id", null: false
    t.decimal "amount", precision: 12, scale: 4, null: false
    t.string "status", null: false
    t.string "reason", null: false
    t.string "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_refunds_on_order_id"
    t.index ["refund_id"], name: "index_refunds_on_refund_id"
  end

  add_foreign_key "account_active_session_keys", "accounts"
  add_foreign_key "account_authentication_audit_logs", "accounts"
  add_foreign_key "account_jwt_refresh_keys", "accounts"
  add_foreign_key "account_lockouts", "accounts", column: "id"
  add_foreign_key "account_login_change_keys", "accounts", column: "id"
  add_foreign_key "account_login_failures", "accounts", column: "id"
  add_foreign_key "account_otp_keys", "accounts", column: "id"
  add_foreign_key "account_password_hashes", "accounts", column: "id"
  add_foreign_key "account_password_reset_keys", "accounts", column: "id"
  add_foreign_key "account_previous_password_hashes", "accounts"
  add_foreign_key "account_recovery_codes", "accounts", column: "id"
  add_foreign_key "account_verification_keys", "accounts", column: "id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "listings"
  add_foreign_key "carts", "accounts", column: "buyer_id"
  add_foreign_key "carts", "accounts", column: "seller_id"
  add_foreign_key "email_settings", "accounts"
  add_foreign_key "listing_templates", "accounts"
  add_foreign_key "listings", "accounts"
  add_foreign_key "messages", "accounts", column: "recipient_id"
  add_foreign_key "messages", "accounts", column: "sender_id"
  add_foreign_key "offers", "accounts", column: "buyer_id"
  add_foreign_key "offers", "listings"
  add_foreign_key "order_items", "listings"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "accounts", column: "buyer_id"
  add_foreign_key "orders", "accounts", column: "seller_id"
  add_foreign_key "payments", "accounts"
  add_foreign_key "refunds", "orders"
end
