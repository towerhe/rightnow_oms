require 'spec_helper'

module RightnowOms
  describe OrdersController do
    describe 'POST create' do

      shared_examples 'creating an order with params' do
        context 'with valid params' do
          before do
            order.should_receive(:save).and_return(true)

            post :create, params
          end

          it { should assign_to :order }
          it { should redirect_to order }
        end

        context 'with invalid params' do
          before do
            order.should_receive(:save).and_return(false)

            post :create, params
          end

          it { should assign_to :order }
          it { should redirect_to ::RightnowOms.config.new_order_url }
        end
      end

      let(:order) { FactoryGirl.build(:order) }

      context 'when given a cart' do
        let(:cart) { FactoryGirl.build(:cart) }
        let(:params) { {} }
        
        before do
          Cart.should_receive(:find_by_id).and_return(cart)
          Order.should_receive(:new_with_items).and_return(order)
        end

        it_behaves_like 'creating an order with params'
      end

      context 'when given order items' do
        let(:order_items) { [{ name: Faker::Product.name, price: rand(100) + 1, quantity: rand(5) }] }
        let(:params) {{ order: { order_items: order_items }}}

        before do
          Order.should_receive(:new_with_items).and_return(order)
        end

        it_behaves_like 'creating an order with params'
      end
    end
  end
end
