#-*- encoding: utf-8 -*-
require 'spec_helper'

feature "Manage my shopping cart", js: true do
  describe "which product with no children" do
    before(:all) do
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, cart: @cart)
    end

    after(:all) { @cart.destroy }

    scenario 'delete cart item' do
      page.set_rack_session(current_cart_id: @cart.id)
      visit '/rightnow_oms/cart'
      page.click_link('删除')

      page.find('.r-cart-items').should_not have_content(@cart_item.name)
    end
  end


  describe "which product with children" do
    before(:all) do
      @cart = FactoryGirl.create(:cart)
      @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent")
      @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child")
    end

    after(:all) { @cart.destroy }

    scenario 'delete cart item' do
      page.set_rack_session(current_cart_id: @cart.id)
      visit '/rightnow_oms/cart'

      page.click_link('删除')

      page.find('.r-cart-items').should_not have_content('parent')
      page.find('.r-cart-items').should_not have_content('child')
    end
  end

  describe 'clean up the cart' do
    before(:all) do
      @cart = FactoryGirl.create(:cart)
      @cart_item1 = FactoryGirl.create(:cart_item, cart: @cart, name: "test1", price: 10)
      @cart_item2 = FactoryGirl.create(:cart_item, cart: @cart, name: "test2", price: 10)
    end

    after(:all) { @cart.destroy }

    scenario 'clean all the cart items' do
      page.set_rack_session(current_cart_id: @cart.id)
      visit '/rightnow_oms/cart'

      page.should have_content('test1')
      page.should have_content('test2')

      page.click_link('清空购物车')

      page.find('.r-cart-items').should_not have_content('test1')
      page.find('.r-cart-items').should_not have_content('test2')
    end
  end

  describe 'go on shopping' do
    before(:all) do
      @cart = FactoryGirl.create(:cart)
      @cart_item = FactoryGirl.create(:cart_item, cart: @cart, name: "product", price: 10)
    end

    after(:all) { @cart.destroy }

    scenario 'go on shopping' do
      page.set_rack_session(current_cart_id: @cart.id)
      visit '/rightnow_oms/cart'

      page.click_link('继续购物')

      page.find('#rightnow-oms').should have_cart(cartable_count: 1, total: 10)
      page.find('.r-cart-items dl').should have_cart_item({
        name: 'product', price: 10, quantity: 1
      })
    end
  end
end
