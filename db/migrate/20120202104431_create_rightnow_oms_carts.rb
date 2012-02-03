class CreateRightnowOmsCarts < ActiveRecord::Migration
  def change
    create_table :rightnow_oms_carts do |t|
      t.string :state
      t.belongs_to :shopper, polymorphic: true

      t.timestamps
    end

    add_index :rightnow_oms_carts, :state
    add_index :rightnow_oms_carts, :shopper_id
    add_index :rightnow_oms_carts, :shopper_type
  end
end
