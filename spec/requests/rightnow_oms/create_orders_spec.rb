require 'spec_helper'

feature 'Creating orders' do
  before do
    @cart = FactoryGirl.create(:cart)
    @cart_item = FactoryGirl.create(:cart_item, cart: @cart)
  end

  let(:order_hash) { fake_order_hash }

  scenario 'create an order' do
    page.set_rack_session(cart_id: @cart.id)
    page.visit '/orders/new'

    %W(
      province city district street neighborhood room
      receiver mobile tel payment_mode remarks vbrk
    ).each do |attr|
      page.fill_in "order[#{attr}]", with: order_hash[attr.to_sym]
    end
    page.click_button 'Create Order'

    order_hash.each do |k, v|
      page.should have_content(v) unless k == 'line_items'
    end

    page.should have_content(@cart_item.name)
    page.should have_content(@cart_item.price)
    page.should have_content(@cart_item.quantity)
    page.should have_content(@cart_item.total_price)
  end
end
