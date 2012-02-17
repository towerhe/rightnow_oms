require 'spec_helper'

module RightnowOms
  describe OrdersController do
    describe 'POST create' do
      let(:order) { FactoryGirl.build(:order) }
      let(:cart) { FactoryGirl.build(:cart) }
      
      before do
        Cart.should_receive(:find_by_id).and_return(cart)
        Order.should_receive(:new_with_items).and_return(order)
      end

      context 'with valid params' do
        before do
          order.should_receive(:save).and_return(true)

          post :create
        end

        it { should assign_to :order }
        it { should redirect_to order }
      end

      context 'with invalid params' do
        before do
          order.should_receive(:save).and_return(false)

          post :create
        end

        it { should assign_to :order }
        it { should redirect_to ::RightnowOms.config.new_order_url }
      end
    end
  end
end
