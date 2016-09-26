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

ActiveRecord::Schema.define(version: 20160926191051) do

  create_table "pokemons", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "external_id"
    t.string   "pokemon_id"
    t.integer  "cp"
    t.integer  "stamina"
    t.integer  "stamina_max"
    t.string   "move_1"
    t.string   "move_2"
    t.string   "deployed_fort_id"
    t.string   "owner_name"
    t.boolean  "is_egg"
    t.float    "egg_km_walked_target",     limit: 24
    t.float    "egg_km_walked_start",      limit: 24
    t.integer  "origin"
    t.float    "height_m",                 limit: 24
    t.float    "weight_kg",                limit: 24
    t.integer  "individual_attack"
    t.integer  "individual_defense"
    t.integer  "individual_stamina"
    t.float    "cp_multiplier",            limit: 24
    t.string   "pokeball"
    t.string   "captured_cell_id"
    t.integer  "battles_attacked"
    t.integer  "battles_defended"
    t.string   "egg_incubator_id"
    t.float    "creation_time_ms",         limit: 24
    t.integer  "num_upgrades"
    t.float    "additional_cp_multiplier", limit: 24
    t.boolean  "favorite"
    t.string   "nickname"
    t.boolean  "from_fort"
    t.integer  "user_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["user_id"], name: "index_pokemons_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "password"
    t.string   "auth_service"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
