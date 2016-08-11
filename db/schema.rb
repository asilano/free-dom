# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160809114619) do

  create_table "chats", force: true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.string   "non_ply_name"
    t.integer  "turn"
    t.integer  "turn_player_id"
    t.text     "statement"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: true do |t|
    t.string   "name"
    t.integer  "max_players"
    t.datetime "end_time"
    t.datetime "created_at"
  end

  create_table "journals", force: true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.text     "event"
    t.datetime "created_at"
    t.integer  "order"
    t.boolean  "modified",   default: false
    t.boolean  "hidden"
  end

  add_index "journals", ["game_id"], name: "index_journals_on_game_id"
  add_index "journals", ["player_id"], name: "index_journals_on_player_id"

  create_table "old_scores", force: true do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.integer "score"
    t.float   "result_elo"
    t.float   "score_elo"
  end

  create_table "players", force: true do |t|
    t.integer  "game_id"
    t.integer  "seat"
    t.integer  "score"
    t.integer  "user_id"
    t.boolean  "lock"
    t.datetime "last_emailed", default: '2011-01-01 00:00:00'
  end

  create_table "rankings", force: true do |t|
    t.integer  "user_id"
    t.integer  "num_played",           default: 0
    t.integer  "num_won",              default: 0
    t.float    "total_normalised_pos", default: 0.0
    t.integer  "total_score",          default: 0
    t.float    "result_elo",           default: 1600.0
    t.float    "score_elo",            default: 1600.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_num_won",         default: 0
    t.float    "last_total_norm_pos",  default: 0.0
    t.integer  "last_total_score",     default: 0
    t.float    "last_result_elo",      default: 1600.0
    t.float    "last_score_elo",       default: 1600.0
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "settings", force: true do |t|
    t.integer "user_id"
    t.integer "player_id"
    t.boolean "automoat",          default: true
    t.boolean "autocrat_victory",  default: true
    t.integer "update_interval",   default: 60
    t.boolean "autobaron",         default: true
    t.boolean "autotorture_curse", default: false
    t.boolean "automountebank",    default: true
    t.boolean "autotreasury",      default: true
    t.integer "autoduchess",       default: 0
    t.integer "autofoolsgold",     default: 1
    t.boolean "autooracle",        default: true
    t.boolean "autoscheme",        default: true
    t.integer "autotunnel",        default: 1
    t.boolean "autobrigand",       default: true
    t.integer "autoigg",           default: 0
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.boolean  "contact_me",      default: false
    t.datetime "last_completed"
    t.boolean  "pbem",            default: false
    t.boolean  "admin",           default: false
  end

end
