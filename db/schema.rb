# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_21_223236) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "stock_captures", force: :cascade do |t|
    t.integer "error_count"
    t.integer "success_count"
    t.datetime "run_at"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_list_users", force: :cascade do |t|
    t.bigint "stock_list_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stock_lists", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_stock_lists_on_user_id"
  end

  create_table "stock_tickers", force: :cascade do |t|
    t.string "symbol"
    t.string "name"
    t.bigint "stock_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "min_threshold", precision: 18, scale: 4
    t.decimal "max_threshold", precision: 18, scale: 4
    t.index ["stock_list_id"], name: "index_stock_tickers_on_stock_list_id"
  end

  create_table "stock_value_errors", force: :cascade do |t|
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "friendly_message"
  end

  create_table "stock_values", force: :cascade do |t|
    t.string "symbol"
    t.datetime "timestamp"
    t.decimal "open", precision: 18, scale: 4
    t.decimal "high", precision: 18, scale: 4
    t.decimal "low", precision: 18, scale: 4
    t.decimal "close", precision: 18, scale: 4
    t.integer "volume"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "stock_value_error_id"
    t.bigint "stock_capture_id"
    t.index ["stock_capture_id"], name: "index_stock_values_on_stock_capture_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "stock_lists", "users"
  add_foreign_key "stock_tickers", "stock_lists"
end
