class AddRequiredArrivalTimeToRightnowOmsOrders < ActiveRecord::Migration
  def change
    add_column :rightnow_oms_orders, :required_arrival_time, :timestamp

  end
end
