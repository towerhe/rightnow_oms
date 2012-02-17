class CreateRightnowOmsOrderItems < ActiveRecord::Migration
  def change
    create_table :rightnow_oms_order_items do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity
      t.integer :parent_id
      t.belongs_to :order

      t.timestamps
    end
    add_index :rightnow_oms_order_items, :parent_id
    add_index :rightnow_oms_order_items, :order_id
  end
end
