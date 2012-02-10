# -*- encoding: utf-8 -*-
require 'spec_helper'

feature "Add cart items to cart", js: true do
  context "when cartable does not exists" do
    background(:all) do
      FactoryGirl.create(:product, name: 'product', price: 3)
    end

    after(:all) { Product.destroy_all }

    before { DatabaseCleaner.strategy = nil }
    after  { DatabaseCleaner.strategy = :truncation }

    scenario "add cartable to cart" do
      visit '/products'
      find('button').click

      visit '/products'

      page.find('#cart-wrapper').should have_cart(cartable_count: 1, total: 3.0)
      page.find('#cart-wrapper').find('table').should have_cart_items([{
        name: 'product', price: 3.0, quantity: 1, deletable: true
      }])
    end
  end

  describe "when cartable exists" do
    background(:all) do
      FactoryGirl.create(:product, name: 'product', price: 3)
    end

    after(:all) { Product.destroy_all }

    before { DatabaseCleaner.strategy = nil }
    after  { DatabaseCleaner.strategy = :truncation }

    scenario "add cartable to cart" do
      visit '/products'
      find('button').click
      find('button').click

      visit '/products'

      page.find('#cart-wrapper').should have_cart(cartable_count: 2, total: 6.0)
      page.find('#cart-wrapper').find('table').should have_cart_items([{
        name: 'product', price: 3.0, quantity: 2, deletable: true
      }])
    end
  end

  describe "when cartable does not exists and has children" do
    background(:all) do
      @parent_product = FactoryGirl.create(:product, name: 'parent', price: 1)
      @child_product  = FactoryGirl.create(:product, name: 'child', price: 2, parent: @parent_product)
    end

    after(:all) do
      Product.destroy_all
    end

    before { DatabaseCleaner.strategy = nil }
    after  { DatabaseCleaner.strategy = :truncation }

    scenario "add cartable and its children to cart" do
      visit '/products'
      find('button').click

      page.find('#cart-wrapper').should have_cart(cartable_count: 2, total: 3.0)
      page.find('#cart-wrapper').find('table').should have_cart_items([{
        name: 'parent', price: 1.0, quantity: 1, deletable: true
      }, {
        name: 'child', price: 2.0, quantity: 1, deletable: false
      }])

      visit '/products'

      page.find('#cart-wrapper').should have_cart(cartable_count: 2, total: 3.0)
      page.find('#cart-wrapper').find('table').should have_cart_items([{
        name: 'parent', price: 1.0, quantity: 1, deletable: true
      }, {
        name: 'child', price: 2.0, quantity: 1, deletable: false
      }])
    end
  end
end
