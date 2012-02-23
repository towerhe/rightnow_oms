# -*- encoding: utf-8 -*-
require 'spec_helper'

feature "Add cart items to cart", js: true do
  describe "which is a singleton" do
    context "when cartable does not exists" do
      background(:all) do
        FactoryGirl.create(:product, name: 'product', price: 3)
      end

      after(:all) do
        Product.destroy_all
      end

      scenario "add cartable to cart" do
        visit '/products'
        find('.buy-btn').click

        page.find('#rightnow-oms').should have_cart(cartable_count: 1, total: 3.0)
        page.find('#rightnow-oms').find('dl').should have_cart_items([{
          name: 'product', price: 3.0, quantity: 1, deletable: true
        }])

        RightnowOms::CartItem.all.should have(1).item
      end
    end

    context "when cartable exists" do
      background(:all) do
        FactoryGirl.create(:product, name: 'product', price: 3)
      end

      after(:all) do
        Product.destroy_all
      end

      scenario "add cartable to cart" do
        visit '/products'

        find('.buy-btn').click
        sleep 1.seconds
        find('.buy-btn').click
        sleep 1.seconds

        page.find('#rightnow-oms').should have_cart(cartable_count: 2, total: 6.0)
        page.find('#rightnow-oms dl').should have_cart_items([{
          name: 'product', price: 3.0, quantity: 2, deletable: true
        }])

        RightnowOms::CartItem.first.quantity.should == 2
      end
    end
  end

  describe "and adding cartable with children" do
    background(:all) do
      @parent_product = FactoryGirl.create(:product, name: 'parent', price: 2)
      @child_product  = FactoryGirl.create(:product, name: 'child', price: 2, parent: @parent_product)
    end

    after(:all) do
      Product.destroy_all
    end

    scenario "not expanded" do
      visit '/products'
      find('.buy-btn').click

      page.find('#rightnow-oms').should have_cart(cartable_count: 1, total: 2.0)
      page.find('.r-cart-items dl').should have_cart_item({
        name: 'parent', price: 2.0, quantity: 1, deletable: true
      })
      page.find('.r-cart-items dl').should_not have_cart_item({
        name: 'child', price: 2.0, quantity: 1
      })

      RightnowOms::CartItem.all.should have(2).items
    end
  end

  describe "and adding cartable with children" do
    background(:all) do
      @parent_product = FactoryGirl.create(:product, name: 'parent', price: 2)
      @child_product  = FactoryGirl.create(:product, name: 'child', price: 2, parent: @parent_product)
    end

    after(:all) do
      Product.destroy_all
    end

    scenario 'expanded' do
      visit '/products'
      find('.buy-btn').click

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

  describe "add the same cartable but not overlap" do
    describe "which has no children" do
      background(:all) do
        FactoryGirl.create(:product, name: 'product', price: 3)
      end

      scenario 'add as singleton' do
        visit '/products'

        find('.buy-btn').click
        sleep 1.seconds
        find('.buy-single').click
        sleep 1.seconds

        page.find('#rightnow-oms').should have_cart_items([{
          name: 'product', price: 3.0, quantity: 1, deletable: true
        }])
        RightnowOms::CartItem.all.should have(2).items
      end
    end

    describe "which has children" do
      background(:all) do
        @parent_product = FactoryGirl.create(:product, name: 'parent', price: 5)
        @child_product  = FactoryGirl.create(:product, name: 'child', price: 2, parent: @parent_product)
      end

      scenario 'add as singleton' do
        visit '/products'

        find('.buy-btn').click
        sleep 1.seconds
        find('.buy-single').click
        sleep 1.seconds

        page.find('#rightnow-oms').should have_cart_items([{
          name: 'product', price: 5.0, quantity: 1, deletable: true
        }])
        RightnowOms::CartItem.all.should have(4).items
      end
    end
  end

  describe "add two or more cartables at a time " do
    background(:all) do
      @product1 = FactoryGirl.create(:product, name: 'test1', group: "无厘头", price: 5)
      @product2 = FactoryGirl.create(:product, name: 'test2', group: "无厘头", price: 5)
      @product3 = FactoryGirl.create(:product, name: 'test3', group: "无厘头", price: 5)
      @product4 = FactoryGirl.create(:product, name: 'test4', group: "无厘头", price: 5)
    end

    scenario 'add to cart' do
      visit '/products'
      find('.group-btn').click

      page.find('#rightnow-oms').should have_cart_item({
        name: 'test1', price: @product1.price, quantity: 1, deletable: true
      })
      page.find('#rightnow-oms').should have_cart_item({
        name: 'test4', price: @product4.price, quantity: 1, deletable: true
      })
      page.find('#rightnow-oms').should have_cart(cartable_count: 4, total: 20.0)
      RightnowOms::CartItem.all.should have(4).items
    end
  end
end
