class AddTastesToRightnowOmsOrderItems < ActiveRecord::Migration
  def change
    add_column :rightnow_oms_order_items, :tastes, :string

  end
end
