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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120301170223) do

  create_table "cards", :force => true do |t|
    t.integer "game_id"
    t.integer "player_id"
    t.integer "pile_id"
    t.string  "location"
    t.integer "position"
    t.string  "type"
    t.boolean "revealed",  :default => false
    t.boolean "peeked",    :default => false
    t.text    "state"
  end

  add_index "cards", ["game_id"], :name => "index_cards_on_game_id"
  add_index "cards", ["pile_id"], :name => "index_cards_on_pile_id"
  add_index "cards", ["player_id"], :name => "index_cards_on_player_id"

  create_table "chats", :force => true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.string   "non_ply_name"
    t.integer  "turn"
    t.integer  "turn_player_id"
    t.text     "statement"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.string   "name"
    t.integer  "max_players"
    t.string   "state",       :default => "waiting"
    t.text     "facts"
    t.datetime "end_time"
    t.integer  "turn_count"
  end

  create_table "histories", :force => true do |t|
    t.integer  "game_id"
    t.text     "event"
    t.datetime "created_at"
    t.string   "css_class"
  end

  create_table "old_scores", :force => true do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.integer "score"
    t.float   "result_elo"
    t.float   "score_elo"
  end

  create_table "pending_actions", :force => true do |t|
    t.integer "game_id"
    t.integer "parent_id"
    t.integer "player_id"
    t.string  "expected_action"
    t.string  "text"
    t.boolean "emailed",         :default => false
  end

  add_index "pending_actions", ["game_id"], :name => "index_pending_actions_on_game_id"
  add_index "pending_actions", ["player_id"], :name => "index_pending_actions_on_player_id"

  create_table "piles", :force => true do |t|
    t.integer "game_id"
    t.string  "card_type"
    t.integer "position"
    t.text    "state"
  end

  add_index "piles", ["game_id", "card_type"], :name => "index_piles_on_game_id_and_card_type", :unique => true

  create_table "player_states", :force => true do |t|
    t.integer  "player_id"
    t.boolean  "outpost_queued",    :default => false
    t.boolean  "outpost_prevent",   :default => false
    t.integer  "pirate_coins",      :default => 0
    t.text     "gained_last_turn"
    t.boolean  "bought_victory",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "played_treasure"
    t.boolean  "played_crossroads", :default => false
  end

  create_table "players", :force => true do |t|
    t.integer  "game_id"
    t.integer  "cash"
    t.integer  "seat"
    t.integer  "score"
    t.integer  "user_id"
    t.boolean  "lock"
    t.datetime "last_emailed", :default => '2011-01-01 00:00:00'
  end

  create_table "rankings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "num_played",           :default => 0
    t.integer  "num_won",              :default => 0
    t.float    "total_normalised_pos", :default => 0.0
    t.integer  "total_score",          :default => 0
    t.float    "result_elo",           :default => 1600.0
    t.float    "score_elo",            :default => 1600.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_num_won",         :default => 0
    t.float    "last_total_norm_pos",  :default => 0.0
    t.integer  "last_total_score",     :default => 0
    t.float    "last_result_elo",      :default => 1600.0
    t.float    "last_score_elo",       :default => 1600.0
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.integer "user_id"
    t.integer "player_id"
    t.boolean "automoat",          :default => true
    t.boolean "autocrat_victory",  :default => true
    t.integer "update_interval",   :default => 60
    t.boolean "autobaron",         :default => true
    t.boolean "autotorture_curse", :default => false
    t.boolean "automountebank",    :default => true
    t.boolean "autotreasury",      :default => true
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.boolean  "contact_me",      :default => false
    t.datetime "last_completed"
    t.boolean  "pbem",            :default => false
  end

end
