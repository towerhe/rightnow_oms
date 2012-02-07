class AddParentIdToRightnowOmsCartItems < ActiveRecord::Migration
  def change
    add_column :rightnow_oms_cart_items, :parent_id, :integer
  end
end
