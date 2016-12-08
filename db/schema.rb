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

ActiveRecord::Schema.define(version: 20161208142449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachinary_files", force: :cascade do |t|
    t.string   "attachinariable_type"
    t.integer  "attachinariable_id"
    t.string   "scope"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent", using: :btree
  end

  create_table "bank_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.integer  "bank_id"
    t.index ["bank_id"], name: "index_bank_users_on_bank_id", using: :btree
    t.index ["email"], name: "index_bank_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_bank_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "banks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loans", force: :cascade do |t|
    t.string   "status"
    t.string   "category"
    t.string   "purpose"
    t.string   "description"
    t.integer  "interest_rate",          default: 15
    t.datetime "start_date"
    t.datetime "final_date"
    t.integer  "bank_id"
    t.integer  "user_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "requested_amount_cents", default: 0,  null: false
    t.integer  "proposed_amount_cents",  default: 0,  null: false
    t.integer  "agreed_amount_cents",    default: 0,  null: false
    t.integer  "duration_months",        default: 3
    t.string   "decline_reason"
    t.index ["bank_id"], name: "index_loans_on_bank_id", using: :btree
    t.index ["user_id"], name: "index_loans_on_user_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.boolean  "read",       default: false
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "payments", force: :cascade do |t|
    t.datetime "due_date"
    t.boolean  "paid",         default: false
    t.datetime "paid_date"
    t.integer  "loan_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "amount_cents", default: 0,     null: false
    t.index ["loan_id"], name: "index_payments_on_loan_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "encrypted_password",     default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "mobile_number",                           null: false
    t.string   "gender"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "postcode"
    t.datetime "date_of_birth"
    t.string   "employment"
    t.string   "photo_id"
    t.string   "credit_score",           default: "0.98"
    t.boolean  "details_completed"
    t.boolean  "facebook_account"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.datetime "token_expiry"
    t.string   "title"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "admin",                  default: false,  null: false
    t.index ["mobile_number"], name: "index_users_on_mobile_number", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "bank_users", "banks"
  add_foreign_key "loans", "banks"
  add_foreign_key "loans", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "payments", "loans"
end
