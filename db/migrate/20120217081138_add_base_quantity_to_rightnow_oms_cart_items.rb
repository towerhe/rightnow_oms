class AddBaseQuantityToRightnowOmsCartItems < ActiveRecord::Migration
  def change
    add_column :rightnow_oms_cart_items, :base_quantity, :integer

  end
end
