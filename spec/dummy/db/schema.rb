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

ActiveRecord::Schema.define(:version => 20120203045059) do

  create_table "products", :force => true do |t|
    t.string   "name"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rightnow_oms_cart_items", :force => true do |t|
    t.integer  "cartable_id"
    t.string   "cartable_type"
    t.integer  "cart_id"
    t.string   "name"
    t.decimal  "price",         :precision => 10, :scale => 2
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rightnow_oms_cart_items", ["cart_id"], :name => "index_rightnow_oms_cart_items_on_cart_id"
  add_index "rightnow_oms_cart_items", ["cartable_id"], :name => "index_rightnow_oms_cart_items_on_cartable_id"
  add_index "rightnow_oms_cart_items", ["cartable_type"], :name => "index_rightnow_oms_cart_items_on_cartable_type"
  add_index "rightnow_oms_cart_items", ["name"], :name => "index_rightnow_oms_cart_items_on_name"

  create_table "rightnow_oms_carts", :force => true do |t|
    t.string   "state"
    t.integer  "shopper_id"
    t.string   "shopper_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rightnow_oms_carts", ["shopper_id"], :name => "index_rightnow_oms_carts_on_shopper_id"
  add_index "rightnow_oms_carts", ["shopper_type"], :name => "index_rightnow_oms_carts_on_shopper_type"
  add_index "rightnow_oms_carts", ["state"], :name => "index_rightnow_oms_carts_on_state"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
