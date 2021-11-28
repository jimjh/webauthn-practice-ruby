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

ActiveRecord::Schema.define(version: 2021_11_27_003322) do

  create_table "users", id: false, force: :cascade do |t|
    t.string "id", limit: 64, primary_key: true, null: false
    t.text "name", limit: 256
    t.text "display_name", limit: 256
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "credentials", force: :cascade do |t|
    t.binary "credential_id", limit: 1203, null: false
    t.binary "credential_public_key", null: false
    t.integer "sign_count", null: false
    t.string "aaguid", limit: 32
    t.string "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_credentials_on_user_id"
  end

  add_foreign_key :credentials, :users, column: :user_id, primary_key: :id, on_delete: :cascade
end
