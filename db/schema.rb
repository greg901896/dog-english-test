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

ActiveRecord::Schema[8.1].define(version: 2026_02_08_031639) do
  create_table "favorites", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "vocabulary_id", null: false
    t.index ["user_id", "vocabulary_id"], name: "index_favorites_on_user_id_and_vocabulary_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
    t.index ["vocabulary_id"], name: "index_favorites_on_vocabulary_id"
  end

  create_table "quiz_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.string "quiz_mode", default: "input", null: false
    t.datetime "updated_at", null: false
    t.string "user_answer"
    t.bigint "user_id", null: false
    t.bigint "vocabulary_id", null: false
    t.index ["user_id"], name: "index_quiz_records_on_user_id"
    t.index ["vocabulary_id"], name: "index_quiz_records_on_vocabulary_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "username", default: "", null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "vocabularies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category"
    t.string "chinese", null: false
    t.datetime "created_at", null: false
    t.integer "difficulty", default: 1
    t.string "english", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_vocabularies_on_category"
    t.index ["english"], name: "index_vocabularies_on_english", unique: true
  end

  add_foreign_key "favorites", "users"
  add_foreign_key "favorites", "vocabularies"
  add_foreign_key "quiz_records", "users"
  add_foreign_key "quiz_records", "vocabularies"
end
