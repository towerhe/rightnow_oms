# -*- encoding: utf-8 -*-
require 'spec_helper'

feature "Change the cartable's attributes", js: true do
  describe "of price" do
    describe "which cartable is a singleton" do
      background(:all) do
        @cart = FactoryGirl.create(:cart)
        @cart_item = FactoryGirl.create(:cart_item, cart: @cart, group: 'booking', quantity: 2)
      end

      scenario "should change the price" do
        page.set_rack_session(cart_id: @cart.id)
        visit '/products'

        find('.descount').click
        page.execute_script("$('.r-cart-items').css('display', 'block');")

        page.find('#rightnow-oms dl').should have_cart_item({
          name: @cart_item.name, price: 11, quantity: 2, deletable: true
        })
        #page.find('#rightnow-oms').should have_content('22')
      end
    end

    describe "which cartable have children" do
      background(:all) do
        @cart = FactoryGirl.create(:cart)
        @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", group: 'booking')
        @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", group: 'booking')
      end

      scenario "should change the price" do
        page.set_rack_session(cart_id: @cart.id)
        visit '/products'

        find('.descount').click
        page.execute_script("$('.r-cart-items').css('display', 'block');")
        find('.r-cart-items li', text: 'parent').click

        page.find('#rightnow-oms dl').should have_cart_item({
          name: 'parent', price: 11, quantity: 1, deletable: true
        })
        page.find('#rightnow-oms dl').should have_cart_item({
          name: 'child', price: 11, quantity: 1, deletable: true
        })
        #page.find('#rightnow-oms').should have_content('22')
      end
    end
  end

  describe "of quantity" do
    describe "when increase" do
      context 'single cart_item in carts/show page' do
        before(:all) do
          @cart = FactoryGirl.create(:cart)
          @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 10)
          @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 8)
        end

        after(:all) { @cart.destroy }

        scenario 'click the "+"' do
          page.set_rack_session(cart_id: @cart.id)
          visit '/rightnow_oms/cart'

          page.click_link('+')

          page.should have_content('2')
          page.should have_content('20')
          page.should have_content('parent')
          page.should_not have_content('child')
          page.should_not have_content('16')

          find('li', text: 'parent').click

          page.should have_content('child')
          page.should have_content('16')
        end
      end

      context 'all cart_items in cart' do
       # before(:all) do
          #@cart = FactoryGirl.create(:cart)
          #@cartItem = FactoryGirl.create(:cart_item, cart: @cart, price: 10, group: 'booking')
          #@parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 10, quantity: 3, group: 'booking')
          #@child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 8, quantity: 6, group: 'booking')
        #end

        #after(:all) { @cart.destroy }

        #scenario 'click the "+" button' do
          #page.set_rack_session(cart_id: @cart.id)
          #visit '/products'

          #find('.increase').click

          #page.should have_content('2')
          #page.should have_content('4')
          #page.should_not have_content('7')

          #find('li', text: 'parent').click

          #page.should have_content('7')
        #end
        
        context 'all cart_items in cart' do
          before(:all) do
            @cart = FactoryGirl.create(:cart)
            @cartItem = FactoryGirl.create(:cart_item, cart: @cart, price: 10, group: 'booking')
            @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 10, group: 'booking')
            @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 8, group: 'booking')
          end

          after(:all) { @cart.destroy }

          scenario 'click the "+" button' do
            page.set_rack_session(cart_id: @cart.id)
            visit '/products'

            find('.increase').click

            page.find('#rightnow-oms dl').should have_cart_items([{
              name: '@cartItem.name', price: 10, quantity: 2, deletable: true
            }])
            page.find('#rightnow-oms dl').should have_cart_items([{
              name: 'parent', price: 10, quantity: 2, deletable: true
            }])
            page.find('#rightnow-oms dl').should_not have_cart_items([{
              name: 'child', price: 8, quantity: 2, deletable: true
            }])

            find('.r-cart-items li', text: 'parent').click

            page.find('#rightnow-oms dl').should have_cart_items([{
              name: 'child', price: 8, quantity: 2, deletable: true
            }])
          end
        end
      end
    end

    describe "when decrease" do
      context 'single cart_item in carts/show page' do
        before(:all) do
          @cart = FactoryGirl.create(:cart)
          @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 10, quantity: 2)
          @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 10, quantity: 4)
        end

        after(:all) { @cart.destroy }

        scenario 'click the "-"' do
          page.set_rack_session(cart_id: @cart.id)
          visit '/rightnow_oms/cart'

          page.click_link('-')

          page.should have_content('1')
          page.should have_content('10')
          page.should have_content('parent')
        end
      end

      context 'all cart_items in cart' do
        before(:all) do
          @cart = FactoryGirl.create(:cart)
          @cartItem = FactoryGirl.create(:cart_item, cart: @cart, price: 10, group: 'booking')
          @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 10, quantity: 3, group: 'booking')
          @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 8, quantity: 6, group: 'booking')
        end

        after(:all) { @cart.destroy }

        scenario 'click the "-" button' do
          page.set_rack_session(cart_id: @cart.id)
          visit '/products'

          find('.decrease').click

          page.should_not have_content('@cartItem.name')
          page.should have_content('2')
          page.should_not have_content('5')

          find('li', text: 'parent').click

          page.should have_content('5')
        end
      end
    end
  end
end
