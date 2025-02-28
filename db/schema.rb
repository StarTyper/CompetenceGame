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

ActiveRecord::Schema[7.1].define(version: 2025_02_27_095019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "categorygerman", null: false
    t.boolean "positive", null: false
    t.string "namegerman", null: false
    t.string "nameenglish"
    t.text "explanationgerman"
    t.text "explanationenglish"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id", null: false
    t.string "groupgerman", null: false
    t.string "groupenglish", null: false
    t.string "categoryenglish", null: false
    t.index ["client_id"], name: "index_cards_on_client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_cards", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "card_id", null: false
    t.integer "pile", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_game_cards_on_card_id"
    t.index ["game_id"], name: "index_game_cards_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "user_id"
    t.string "name", null: false
    t.string "status", null: false
    t.text "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "count_positive", default: 10, null: false
    t.integer "count_negative", default: 5, null: false
    t.integer "pile", default: 0, null: false
    t.boolean "positive", default: true, null: false
    t.integer "group_positive", default: 0, null: false
    t.integer "group_negative", default: 0, null: false
    t.index ["client_id"], name: "index_games_on_client_id"
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: "guest"
    t.bigint "client_id"
    t.string "language", default: "german", null: false
    t.index ["client_id"], name: "index_users_on_client_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "cards", "clients"
  add_foreign_key "game_cards", "cards"
  add_foreign_key "game_cards", "games"
  add_foreign_key "games", "clients"
  add_foreign_key "games", "users"
  add_foreign_key "users", "clients"
end
