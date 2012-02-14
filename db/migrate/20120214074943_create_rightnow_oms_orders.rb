class CreateRightnowOmsOrders < ActiveRecord::Migration
  def change
    create_table :rightnow_oms_orders do |t|
      t.string :province
      t.string :city
      t.string :district
      t.string :street
      t.string :neighborhood
      t.string :room
      t.string :receiver
      t.string :mobile
      t.string :tel
      t.string :payment_mode
      t.string :remarks
      t.string :vbrk

      t.timestamps
    end
  end
end
