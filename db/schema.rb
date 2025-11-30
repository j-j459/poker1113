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

ActiveRecord::Schema.define(version: 2025_11_28_132000) do

  create_table "answers", force: :cascade do |t|
    t.text "content"
    t.integer "user_id", null: false
    t.integer "question_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "chases", force: :cascade do |t|
    t.text "body"
    t.string "ace"
    t.string "king"
    t.string "five"
    t.string "four"
    t.string "three"
    t.string "two"
    t.string "one"
    t.float "queen"
    t.float "jack"
    t.float "ten"
    t.float "nine"
    t.float "eight"
    t.float "seven"
    t.string "six"
    t.string "aa"
    t.string "bb"
    t.string "cc"
    t.string "dd"
    t.string "ee"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "content"
    t.integer "user_id", null: false
    t.integer "chase_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chase_id"], name: "index_comments_on_chase_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "game_actions", force: :cascade do |t|
    t.integer "game_session_id", null: false
    t.integer "player_id", null: false
    t.string "action_type"
    t.integer "amount", default: 0
    t.string "game_phase"
    t.integer "round_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_session_id"], name: "index_game_actions_on_game_session_id"
    t.index ["player_id"], name: "index_game_actions_on_player_id"
  end

  create_table "game_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "status", default: "waiting"
    t.integer "pot", default: 0
    t.integer "current_bet", default: 0
    t.integer "dealer_position", default: 0
    t.integer "small_blind", default: 10
    t.integer "big_blind", default: 20
    t.integer "current_player_position"
    t.string "community_cards", default: "[]"
    t.string "game_phase", default: "preflop"
    t.integer "round_number", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "deck"
    t.string "game_mode"
    t.integer "starting_chips"
    t.index ["user_id"], name: "index_game_sessions_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "chase_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chase_id"], name: "index_likes_on_chase_id"
    t.index ["user_id", "chase_id"], name: "index_likes_on_user_id_and_chase_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "game_session_id", null: false
    t.string "player_type", default: "human"
    t.string "name"
    t.integer "chips", default: 1000
    t.integer "position"
    t.boolean "is_active", default: true
    t.boolean "is_folded", default: false
    t.string "hand_cards"
    t.integer "current_bet", default: 0
    t.integer "total_bet", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_session_id"], name: "index_players_on_game_session_id"
  end

  create_table "question_tags", force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_question_tags_on_question_id"
    t.index ["tag_id"], name: "index_question_tags_on_tag_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "user_id", null: false
    t.integer "views_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "best_answer_id"
    t.index ["best_answer_id"], name: "index_questions_on_best_answer_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "follow_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["follow_id"], name: "index_relationships_on_follow_id"
    t.index ["user_id", "follow_id"], name: "index_relationships_on_user_id_and_follow_id", unique: true
    t.index ["user_id"], name: "index_relationships_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "questions_count", default: 0, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "profile"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "votable_type", null: false
    t.integer "votable_id", null: false
    t.integer "value", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "votable_id", "votable_type"], name: "index_votes_on_user_and_votable", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable"
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "comments", "chases"
  add_foreign_key "comments", "users"
  add_foreign_key "game_actions", "game_sessions"
  add_foreign_key "game_actions", "players"
  add_foreign_key "game_sessions", "users"
  add_foreign_key "likes", "chases"
  add_foreign_key "likes", "users"
  add_foreign_key "players", "game_sessions"
  add_foreign_key "question_tags", "questions"
  add_foreign_key "question_tags", "tags"
  add_foreign_key "questions", "answers", column: "best_answer_id"
  add_foreign_key "questions", "users"
  add_foreign_key "relationships", "users"
  add_foreign_key "relationships", "users", column: "follow_id"
  add_foreign_key "votes", "users"
end
