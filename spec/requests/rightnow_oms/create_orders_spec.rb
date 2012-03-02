require 'spec_helper'

feature 'Creating orders' do
  describe "when filled in the attributes" do
    before do
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, cart: @cart)
    end

    let(:order_hash) { fake_order_hash }

    scenario 'create an order' do
      page.set_rack_session(current_cart_id: @cart.id)
      page.visit '/orders/new'

      %W(
      province city district street neighborhood room
      receiver mobile tel required_arrival_time payment_mode remarks vbrk
      ).each do |attr|
        page.fill_in "order[#{attr}]", with: order_hash[attr.to_sym]
      end
      page.click_button 'Create Order'

      order_hash.each do |k, v|
        page.should have_content(v) unless k.to_s == 'line_items' || k.to_s == 'user_id'
      end

      page.should have_content(@cart_item.name)
      page.should have_content(@cart_item.price)
      page.should have_content(@cart_item.quantity)
      page.should have_content(@cart_item.total)
    end
  end

  describe "when posted the arrtibutes" do
    let(:order_hash) { fake_order_hash(2) }

    scenario "creates an order and redirects to the order's show page" do
      post "/rightnow_oms/orders", order: order_hash
      follow_redirect!

      response.should render_template("orders")
    end
  end
end
