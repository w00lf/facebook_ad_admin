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

ActiveRecord::Schema.define(version: 20181101090845) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "binom_campaigns", force: :cascade do |t|
    t.string "binom_identificator"
    t.string "facebook_campaign_identificator"
    t.string "name"
    t.bigint "facebook_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facebook_account_id"], name: "index_binom_campaigns_on_facebook_account_id"
  end

  create_table "facebook_accounts", force: :cascade do |t|
    t.string "name"
    t.string "api_token"
    t.string "api_secret"
    t.boolean "active", default: true, null: false
    t.bigint "facebook_group_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_identificator"
    t.index ["facebook_group_account_id"], name: "index_facebook_accounts_on_facebook_group_account_id"
  end

  create_table "facebook_group_accounts", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "import_results", force: :cascade do |t|
    t.text "error_type"
    t.text "error_text"
    t.bigint "facebook_account_id"
    t.text "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facebook_account_id"], name: "index_import_results_on_facebook_account_id"
  end

  create_table "parse_results", force: :cascade do |t|
    t.text "error_type"
    t.text "error_text"
    t.bigint "facebook_account_id"
    t.text "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facebook_account_id"], name: "index_parse_results_on_facebook_account_id"
  end

  add_foreign_key "binom_campaigns", "facebook_accounts"
  add_foreign_key "facebook_accounts", "facebook_group_accounts"
  add_foreign_key "import_results", "facebook_accounts", on_delete: :cascade
  add_foreign_key "parse_results", "facebook_accounts", on_delete: :cascade
end
