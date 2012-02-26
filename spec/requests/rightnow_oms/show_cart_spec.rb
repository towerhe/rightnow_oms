# -*- encoding: utf-8 -*-
require 'spec_helper'

feature 'show cart_items in cart', js:true do
  describe "which cart_items are a singleton" do
    before(:all) do 
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, cart: @cart, name: "product", price: 3.1)
    end

    after(:all) { @cart.destroy }

    scenario 'show in cart' do
      page.set_rack_session(current_cart_id: @cart.id)
      visit '/products'

      page.execute_script("$('.r-cart-items').css('display', 'block');")
      page.click_link('查看我的购物车')

      page.should have_content('product')
      page.should have_content('3.1')
    end
  end

  describe "which cart_items with children" do
    before(:all) do 
      @cart = FactoryGirl.create(:cart)
      @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 3.1)
      @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 2.1)
    end

    after(:all) { @cart.destroy }

    scenario 'show in cart' do
      page.set_rack_session(current_cart_id: @cart.id)
      visit '/products'

      page.execute_script("$('.r-cart-items').css('display', 'block');")
      page.click_link('查看我的购物车')

      page.should have_content('parent')
      page.should have_content('3.1')
      page.find('.r-cart-items').should_not have_content('child')

      find('.r-cart-items li', text: 'parent').click

      page.should have_content('child')
      page.should have_content('2.1')
    end
  end
end
