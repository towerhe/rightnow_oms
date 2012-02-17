# -*- encoding: utf-8 -*-
require 'spec_helper'

feature "Add cart items to cart", js: true do
  describe "which is a singleton" do
    context "when cartable does not exists" do
      background(:all) do
        DatabaseCleaner.strategy = nil
        FactoryGirl.create(:product, name: 'product', price: 3)
      end

      after(:all) do
        Product.destroy_all

        DatabaseCleaner.strategy = :truncation
      end

      scenario "add cartable to cart" do
        visit '/products'
        find('button').click

        visit '/products'

        page.find('#rightnow-oms').should have_cart(cartable_count: 1, total: 3.0)
        page.find('#rightnow-oms').find('dl').should have_cart_items([{
          name: 'product', price: 3.0, quantity: 1, deletable: true
        }])
      end
    end

    context "when cartable exists" do
      background(:all) do
        DatabaseCleaner.strategy = nil

        FactoryGirl.create(:product, name: 'product', price: 3)
      end

      after(:all) do
        Product.destroy_all

        DatabaseCleaner.strategy = :truncation
      end

      scenario "add cartable to cart" do
        visit '/products'
        find('button').click
        find('button').click

        visit '/products'

        page.find('#rightnow-oms').should have_cart(cartable_count: 2, total: 6.0)
        page.find('#rightnow-oms dl').should have_cart_items([{
          name: 'product', price: 3.0, quantity: 2, deletable: true
        }])
      end
    end
  end

  describe "and adding cartable with children" do
    background(:all) do
      DatabaseCleaner.strategy = nil

      @parent_product = FactoryGirl.create(:product, name: 'parent', price: 2)
      @child_product  = FactoryGirl.create(:product, name: 'child', price: 2, parent: @parent_product)
    end

    after(:all) do
      Product.destroy_all

      DatabaseCleaner.strategy = :truncation
    end

    scenario "not expanded" do
      visit '/products'
      find('button').click

      page.find('#rightnow-oms').should have_cart(cartable_count: 1, total: 2.0)
      page.find('.r-cart-items dl').should have_cart_item({
        name: 'parent', price: 2.0, quantity: 1, deletable: true
      })
      page.find('.r-cart-items dl').should_not have_cart_item({
        name: 'child', price: 2.0, quantity: 1
      })

      visit '/products'

      page.find('#rightnow-oms').should have_cart(cartable_count: 1, total: 2.0)
      page.find('.r-cart-items dl').should have_cart_item({
        name: 'parent', price: 2.0, quantity: 1, deletable: true
      })
      page.find('.r-cart-items dl').should_not have_cart_item({
        name: 'child', price: 2.0, quantity: 1
      })
    end
  end

  describe "and adding cartable with children" do
    background(:all) do
      DatabaseCleaner.strategy = nil

      @parent_product = FactoryGirl.create(:product, name: 'parent', price: 2)
      @child_product  = FactoryGirl.create(:product, name: 'child', price: 2, parent: @parent_product)
    end

    after(:all) do
      Product.destroy_all

      DatabaseCleaner.strategy = :truncation
    end

    scenario 'expanded' do
      visit '/products'
      find('button').click

      dl = page.find('#rightnow-oms dl')
      page.execute_script("$('.r-cart-items').css('display', 'block');")
      find('.r-cart-items li', text: 'parent').click

      dl.should have_cart_item({
        name: 'parent', price: 2.0, quantity: 1, deletable: true
      })
      dl.should have_cart_item({
        name: 'child', price: 2.0, quantity: 1
      })
    end
  end
end
