class AddUserIdToRightnowOmsOrders < ActiveRecord::Migration
  def change
    add_column :rightnow_oms_orders, :user_id, :integer
    add_index :rightnow_oms_orders, :user_id

  end
end
