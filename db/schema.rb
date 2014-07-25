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

ActiveRecord::Schema.define(version: 20140725220449) do

  create_table "abbo_items", force: true do |t|
    t.integer "object_id",   null: false
    t.string  "object_type", null: false
  end

  create_table "abbo_targets", force: true do |t|
    t.integer "target_id",   null: false
    t.string  "target_type", null: false
  end

  create_table "abbonements", force: true do |t|
    t.integer  "abbo_item_id",   null: false
    t.integer  "abbo_target_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "binlogs", force: true do |t|
    t.integer  "user_id"
    t.integer  "channel_id"
    t.string   "input"
    t.string   "output"
    t.datetime "created_at"
  end

  create_table "bots", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channels", force: true do |t|
    t.integer  "server_id"
    t.string   "name"
    t.string   "triggers"
    t.integer  "locale_id",   default: 1,     null: false
    t.integer  "timezone_id", default: 1,     null: false
    t.integer  "encoding_id", default: 1,     null: false
    t.boolean  "colors",      default: true
    t.boolean  "decorations", default: true
    t.boolean  "online",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "channels", ["encoding_id"], name: "channels_encoding_id_fk", using: :btree
  add_index "channels", ["locale_id"], name: "channels_locale_id_fk", using: :btree
  add_index "channels", ["name"], name: "channels_name_index", using: :btree
  add_index "channels", ["server_id"], name: "channels_server_index", using: :btree
  add_index "channels", ["timezone_id"], name: "channels_timezone_id_fk", using: :btree

  create_table "chanperms", force: true do |t|
    t.integer  "user_id",                     null: false
    t.integer  "channel_id",                  null: false
    t.integer  "permissions", default: 0,     null: false
    t.boolean  "online",      default: false, null: false
    t.datetime "created_at",                  null: false
  end

  add_index "chanperms", ["channel_id"], name: "chanperms_channel_id_fk", using: :btree
  add_index "chanperms", ["user_id"], name: "chanperms_user_index", using: :btree

  create_table "cvs_repo_perms", force: true do |t|
    t.integer "repo_id", null: false
    t.integer "user_id", null: false
  end

  create_table "cvs_repos", force: true do |t|
    t.string   "name",                      null: false
    t.string   "url",                       null: false
    t.string   "system"
    t.integer  "user_id",                   null: false
    t.boolean  "public",                    null: false
    t.boolean  "enabled",    default: true, null: false
    t.string   "pubkey"
    t.string   "username"
    t.string   "password"
    t.string   "revision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_confirmations", force: true do |t|
    t.integer  "user_id",  null: false
    t.string   "email",    null: false
    t.string   "code",     null: false
    t.datetime "valid_to", null: false
  end

  create_table "encodings", force: true do |t|
    t.string "iso", null: false
  end

  create_table "feeds", force: true do |t|
    t.integer  "user_id",                 null: false
    t.string   "name",                    null: false
    t.string   "url",                     null: false
    t.string   "title"
    t.string   "description"
    t.integer  "updates",     default: 0, null: false
    t.datetime "checked_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feeds", ["name"], name: "feeds_name_index", using: :btree
  add_index "feeds", ["user_id"], name: "feeds_user_id_fk", using: :btree

  create_table "locales", force: true do |t|
    t.string "iso", null: false
  end

  create_table "note_messages", force: true do |t|
    t.integer  "sender_id",   null: false
    t.integer  "receiver_id"
    t.string   "message",     null: false
    t.datetime "read_at"
    t.datetime "sent_at",     null: false
  end

  create_table "plugins", force: true do |t|
    t.integer  "bot_id",                 null: false
    t.string   "name",                   null: false
    t.integer  "revision",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_entries", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "age"
    t.string   "gender"
    t.date     "birthdate"
    t.string   "country"
    t.string   "about"
    t.string   "phone"
    t.string   "mobile"
    t.string   "icq"
    t.string   "skype"
    t.string   "jabber"
    t.string   "threema"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_entries", ["user_id"], name: "profile_user_index", using: :btree

  create_table "quotes", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "channel_id"
    t.text     "message",    null: false
    t.datetime "created_at"
  end

  create_table "server_nicks", force: true do |t|
    t.integer  "server_id",                                   null: false
    t.string   "nickname",                                    null: false
    t.string   "hostname",   default: "ricer2.gizmore.org",   null: false
    t.string   "username",   default: "ricer2",               null: false
    t.string   "realname",   default: "Ricer2 - ruby IRCbot", null: false
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "server_nicks", ["server_id"], name: "server_nicks_server_id_fk", using: :btree

  create_table "server_urls", force: true do |t|
    t.integer  "server_id",                   null: false
    t.string   "ip"
    t.string   "url",                         null: false
    t.boolean  "peer_verify", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "server_urls", ["server_id"], name: "server_urls_server_id_fk", using: :btree

  create_table "servers", force: true do |t|
    t.integer  "bot_id",                     null: false
    t.string   "connector",  default: "irc", null: false
    t.string   "triggers",   default: ",",   null: false
    t.integer  "throttle",   default: 3,     null: false
    t.float    "cooldown",   default: 0.8,   null: false
    t.boolean  "enabled",    default: true,  null: false
    t.boolean  "online",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.string "value"
  end

  create_table "survey_answers", force: true do |t|
    t.integer  "attempt_id"
    t.integer  "question_id"
    t.integer  "option_id"
    t.boolean  "correct"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_attempts", force: true do |t|
    t.integer "participant_id"
    t.string  "participant_type"
    t.integer "survey_id"
    t.boolean "winner"
    t.integer "score"
  end

  create_table "survey_options", force: true do |t|
    t.integer  "question_id"
    t.integer  "weight",      default: 0
    t.string   "text"
    t.boolean  "correct"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_questions", force: true do |t|
    t.integer  "survey_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_surveys", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "attempts_number", default: 0
    t.boolean  "finished",        default: false
    t.boolean  "active",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timezones", force: true do |t|
    t.string "iso", null: false
  end

  create_table "trigger_counters", force: true do |t|
    t.integer "plugin_id",             null: false
    t.integer "user_id",               null: false
    t.integer "calls",     default: 0, null: false
  end

  add_index "trigger_counters", ["plugin_id", "user_id"], name: "plugin_user_calls_index", unique: true, using: :btree
  add_index "trigger_counters", ["plugin_id"], name: "plugin_calls_index", using: :btree
  add_index "trigger_counters", ["user_id"], name: "trigger_counters_user_id_fk", using: :btree

  create_table "users", force: true do |t|
    t.integer  "server_id",                       null: false
    t.integer  "permissions",     default: 0,     null: false
    t.string   "nickname",                        null: false
    t.string   "hashed_password"
    t.string   "email"
    t.string   "message_type",    default: "n",   null: false
    t.string   "gender",          default: "m",   null: false
    t.integer  "locale_id",       default: 1,     null: false
    t.integer  "encoding_id",     default: 1,     null: false
    t.integer  "timezone_id",     default: 1,     null: false
    t.boolean  "online",          default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["encoding_id"], name: "users_encoding_id_fk", using: :btree
  add_index "users", ["locale_id"], name: "users_locale_id_fk", using: :btree
  add_index "users", ["nickname"], name: "users_nickname_index", using: :btree
  add_index "users", ["server_id"], name: "users_server_index", using: :btree
  add_index "users", ["timezone_id"], name: "users_timezone_id_fk", using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  add_foreign_key "channels", "encodings", name: "channels_encoding_id_fk"
  add_foreign_key "channels", "locales", name: "channels_locale_id_fk"
  add_foreign_key "channels", "servers", name: "channels_server_id_fk", dependent: :delete
  add_foreign_key "channels", "timezones", name: "channels_timezone_id_fk"

  add_foreign_key "chanperms", "channels", name: "chanperms_channel_id_fk", dependent: :delete
  add_foreign_key "chanperms", "users", name: "chanperms_user_id_fk", dependent: :delete

  add_foreign_key "feeds", "users", name: "feeds_user_id_fk"

  add_foreign_key "profile_entries", "users", name: "profile_entries_user_id_fk", dependent: :delete

  add_foreign_key "server_nicks", "servers", name: "server_nicks_server_id_fk", dependent: :delete

  add_foreign_key "server_urls", "servers", name: "server_urls_server_id_fk", dependent: :delete

  add_foreign_key "trigger_counters", "plugins", name: "trigger_counters_plugin_id_fk", dependent: :delete
  add_foreign_key "trigger_counters", "users", name: "trigger_counters_user_id_fk", dependent: :delete

  add_foreign_key "users", "encodings", name: "users_encoding_id_fk"
  add_foreign_key "users", "locales", name: "users_locale_id_fk"
  add_foreign_key "users", "servers", name: "users_server_id_fk", dependent: :delete
  add_foreign_key "users", "timezones", name: "users_timezone_id_fk"

end
