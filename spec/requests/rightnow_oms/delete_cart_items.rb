# -*- encoding: utf-8 -*-
require 'spec_helper'

feature 'delete cart items', js:true do
  describe "which is a singleton" do
    before(:all) do
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, cart: @cart, name: "product")
    end

    after(:all) { @cart.destroy }

    scenario 'delete cart item' do
      page.set_rack_session(current_cart_id: @cart.id)

      visit '/products'

      page.execute_script("$('.r-cart-items').css('display', 'block');")
      page.click_link('删除')

      page.find('#rightnow-oms').should_not have_content('product')
    end
  end

  context "which with children" do
    before(:all) do
      @cart = FactoryGirl.create(:cart)
      @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent")
      @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child")
    end

    after(:all) { @cart.destroy }

    scenario 'delete cart item' do
      page.set_rack_session(current_cart_id: @cart.id)

      visit '/products'

      page.execute_script("$('.r-cart-items').css('display', 'block');")
      page.click_link('删除')

      page.find('#rightnow-oms').should_not have_content('parent')
      page.find('#rightnow-oms').should_not have_content('child')
    end
  end
end
