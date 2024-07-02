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

ActiveRecord::Schema[7.1].define(version: 2024_07_02_140249) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "otps", primary_key: "phone_no", id: :string, force: :cascade do |t|
    t.string "otp"
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_no"], name: "index_otps_on_phone_no", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "firstname"
    t.string "surname"
    t.string "phone_no"
    t.string "country_code", limit: 4
    t.string "country"
    t.string "state"
    t.string "city"
    t.string "photo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
