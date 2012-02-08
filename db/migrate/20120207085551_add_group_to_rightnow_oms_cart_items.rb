class AddGroupToRightnowOmsCartItems < ActiveRecord::Migration
  def change
    add_column :rightnow_oms_cart_items, :group, :string
  end
end
