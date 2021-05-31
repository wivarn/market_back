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

ActiveRecord::Schema.define(version: 2021_05_10_023055) do

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

  create_table "account_jwt_refresh_keys", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "key", null: false
    t.datetime "deadline", default: -> { "(CURRENT_TIMESTAMP + ((14 || ' days'::text))::interval)" }, null: false
    t.index ["account_id"], name: "account_jwt_rk_account_id_idx"
    t.index ["account_id"], name: "index_account_jwt_refresh_keys_on_account_id"
  end

  create_table "account_login_change_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "login", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_password_hashes", force: :cascade do |t|
    t.string "password_hash", null: false
  end

  create_table "account_password_reset_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "account_remember_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", default: -> { "(CURRENT_TIMESTAMP + ((14 || ' days'::text))::interval)" }, null: false
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
    t.index ["email"], name: "index_accounts_on_email", unique: true, where: "((status)::text = ANY ((ARRAY['unverified'::character varying, 'verified'::character varying])::text[]))"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "photos", null: false, array: true
    t.string "title", null: false
    t.string "condition", null: false
    t.text "description"
    t.string "currency", limit: 3, null: false
    t.decimal "price", precision: 12, scale: 4, null: false
    t.decimal "domestic_shipping", precision: 12, scale: 4, null: false
    t.decimal "international_shipping", precision: 12, scale: 4
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_listings_on_account_id"
    t.index ["currency"], name: "index_listings_on_currency"
    t.index ["price"], name: "index_listings_on_price"
    t.index ["status"], name: "index_listings_on_status"
  end

  add_foreign_key "account_active_session_keys", "accounts"
  add_foreign_key "account_jwt_refresh_keys", "accounts"
  add_foreign_key "account_login_change_keys", "accounts", column: "id"
  add_foreign_key "account_password_hashes", "accounts", column: "id"
  add_foreign_key "account_password_reset_keys", "accounts", column: "id"
  add_foreign_key "account_remember_keys", "accounts", column: "id"
  add_foreign_key "account_verification_keys", "accounts", column: "id"
end
