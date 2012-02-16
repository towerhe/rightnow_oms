# -*- encoding: utf-8 -*-
require 'spec_helper'

feature "Add cart items to cart", js: true do
  describe "which is a singleton" do
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

        page.find('#rightnow-oms').should have_cart(cartable_count: 1, total: 3.0)
        page.find('#rightnow-oms').find('table').should have_cart_items([{
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

        page.find('#rightnow-oms').should have_cart(cartable_count: 2, total: 6.0)
        page.find('#rightnow-oms').find('table').should have_cart_items([{
          name: 'product', price: 3.0, quantity: 2, deletable: true
        }])
      end
    end
  end

  describe "when cartable does not exists and has children" do
    context "and adding cartable with children" do
      background(:all) do
        @parent_product = FactoryGirl.create(:product, name: 'parent', price: 1)
        @child_product  = FactoryGirl.create(:product, name: 'child', price: 2, parent: @parent_product)
      end

      after(:all) do
        Product.destroy_all
      end

      before { DatabaseCleaner.strategy = nil }
      after  { DatabaseCleaner.strategy = :truncation }

      scenario "not expanded" do
        visit '/products'
        find('button').click

        wrapper = page.find('#rightnow-oms')
        wrapper.should have_cart(cartable_count: 1, total: 3.0)
        table = wrapper.find('table')
        wrapper.find('.r-cart-bar').trigger('hover')
        table.should have_cart_item({
          name: 'parent', price: 1.0, quantity: 1
        })
        table.should_not have_cart_item({
          name: 'child', price: 2.0, quantity: 1
        })

        visit '/products'

        page.find('#rightnow-oms').should have_cart(cartable_count: 1, total: 3.0)
        table = page.find('#rightnow-oms table')
        page.find('.r-cart-bar').trigger('hover')
        table.should have_cart_item({
          name: 'parent', price: 1.0, quantity: 1
        })
        table.should_not have_cart_item({
          name: 'child', price: 2.0, quantity: 1
        })
      end

      context "and adding cartable with children" do
        background(:all) do
          @parent_product = FactoryGirl.create(:product, name: 'parent', price: 1)
          @child_product  = FactoryGirl.create(:product, name: 'child', price: 2, parent: @parent_product)
        end

        after(:all) do
          Product.destroy_all
        end

        before { DatabaseCleaner.strategy = nil }
        after  { DatabaseCleaner.strategy = :truncation }

        scenario 'expanded' do
          visit '/products'
          find('button').click

          table = page.find('#rightnow-oms table')
          page.execute_script("$('.r-cart-items').css('display', 'block');")
          find('td', text: 'parent').click

          table.should have_cart_item({
            name: 'parent', price: 1.0, quantity: 1
          })
          table.should have_cart_item({
            name: 'child', price: 2.0, quantity: 1
          })
        end
      end
    end
  end
end
