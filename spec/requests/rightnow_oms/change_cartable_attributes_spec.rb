# -*- encoding: utf-8 -*-
require 'spec_helper'

feature "Change the cartable's attributes", js: true do
  describe "of price" do
    describe "which cartable is a singleton" do
      background(:all) do
        @cart  = FactoryGirl.create(:cart)
        @item1 = FactoryGirl.create(:cart_item, cart: @cart, group: 'booking', name: 'first')
        @item2 = FactoryGirl.create(:cart_item, cart: @cart, group: 'booking', name: 'second')
      end

      scenario "should change the price" do
        page.set_rack_session(cart_id: @cart.id)
        visit '/products'
        find('.descount').click

        page.execute_script("$('.r-cart-items').css('display', 'block');")

        page.find('#rightnow-oms').should have_cart_item({
          name: 'first', price: 11, quantity: 1, deletable: true
        })
        page.find('#rightnow-oms').should have_cart_item({
          name: 'second', price: 11, quantity: 1, deletable: true
        })

        page.find('#rightnow-oms').should have_content('22')
      end
    end

    describe "which cartable have children" do
      background(:all) do
        @cart   = FactoryGirl.create(:cart)
        @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", group: 'booking')
        @child  = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", group: 'booking')
      end

      scenario "should change the price" do
        page.set_rack_session(cart_id: @cart.id)
        visit '/products'
        find('.descount').click

        page.execute_script("$('.r-cart-items').css('display', 'block');")
        find('.r-cart-items li', text: 'parent').click

        page.find('#rightnow-oms').should have_cart_item({
          name: 'parent', price: 11, quantity: 1, deletable: true
        })
        page.find('#rightnow-oms').should have_cart_item({
          name: 'child', price: 11, quantity: 1, deletable: true
        })

        page.find('#rightnow-oms').should have_content('11')
      end
    end
  end

  describe "of quantity" do
    describe "when increase" do
      context 'single cart_item in carts/show page' do
        before(:all) do
          @cart   = FactoryGirl.create(:cart)
          @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 10)
          @child  = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 8)
        end

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
        context 'all cart_items in cart' do
          before(:all) do
            @cart     = FactoryGirl.create(:cart)
            @cartItem = FactoryGirl.create(:cart_item, cart: @cart, name: "single", price: 10, group: 'booking')
            @parent   = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 9, group: 'booking')
            @child    = FactoryGirl.create(:cart_item, cart: @cart, name: "child", price: 8, group: 'booking', parent: @parent)
          end

          after(:all) { @cart.destroy }

          scenario 'click the "加1" button' do
            page.set_rack_session(cart_id: @cart.id)
            visit '/products'

            find('.increase').click
            sleep 1.second

            page.execute_script("$('.r-cart-items').css('display', 'block');")
            find('.r-cart-items li', text: 'parent').click

            page.find('#rightnow-oms').should have_cart_item({
              name: 'single', price: 10, quantity: 2, deletable: true
            })
            page.find('#rightnow-oms').should have_cart_item({
              name: 'parent', price: 9, quantity: 2, deletable: true
            })
            page.find('#rightnow-oms').should have_cart_item({
              name: 'child', price: 8, quantity: 2, deletable: true
            })
          end
        end
      end
    end

    describe "when decrease" do
      context 'single cart_item in carts/show page' do
        before(:all) do
          @cart = FactoryGirl.create(:cart)
          @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 10)
          @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 7)
        end

        after(:all) { @cart.destroy }

        scenario 'click the "-"' do
          page.set_rack_session(cart_id: @cart.id)
          visit '/rightnow_oms/cart'
          find('li', text: 'parent').click

          page.click_link('+')
          sleep 1.seconds
          page.click_link('+')
          sleep 1.seconds
          page.click_link('-')
          sleep 1.seconds

          page.should have_content('2')
          page.should have_content('20')
          page.should have_content('parent')
          page.should have_content('14')
          page.should have_content('20')

        end
      end

      context 'all cart_items in cart' do
        before(:all) do
          @cart = FactoryGirl.create(:cart)
          @cartItem = FactoryGirl.create(:cart_item, cart: @cart, name: "single", price: 10, group: 'booking')
          @parent = FactoryGirl.create(:cart_item, cart: @cart, name: "parent", price: 10, group: 'booking')
          @child = FactoryGirl.create(:cart_item, cart: @cart, parent: @parent, name: "child", price: 8, group: 'booking')
        end

        after(:all) { @cart.destroy }

        scenario 'click the "减1" button' do
          page.set_rack_session(cart_id: @cart.id)
          visit '/products'

          find('.increase').click
          sleep 1.seconds
          find('.decrease').click
          sleep 1.seconds

          page.execute_script("$('.r-cart-items').css('display', 'block');")

          page.find('#rightnow-oms').should have_cart_item({
            name: 'single', price: 10, quantity: 1, deletable: true
          })

          RightnowOms::CartItem.all.should have(3).items
        end
      end
    end
  end
end
