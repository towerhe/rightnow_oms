require 'spec_helper'

feature 'Search for orders' do
  background(:all) do
    old = RightnowOms::Order.create_with_items(fake_order_hash(1))
    sleep(1) # So the two orders have different created_at
    @order = RightnowOms::Order.create_with_items(fake_order_hash(1, tel: old.tel, mobile: old.mobile))
  end

  %W(tel mobile).each do |n|
    scenario "by #{n}" do
      get '/rightnow_oms/orders', q: { "#{n}_eq" => @order.send(n.to_sym) }, format: :json

      response.status.should == 200
      orders = JSON.parse(response.body)["orders"]

      orders.should have(2).items
      order = orders.first

      order["id"].should == @order.id
      order["#{n}"].should == @order.send(n.to_sym)
    end
  end
end
