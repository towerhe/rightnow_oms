require 'spec_helper'

describe RightnowOms::CartItemsController do
  let(:product) { FactoryGirl.build(:product) }

  describe "POST create" do
    let(:cart) { FactoryGirl.create(:cart) }
    let(:cart_item) { FactoryGirl.build(:cart_item, cart: cart) }

    context "in json" do
      before do
        RightnowOms::Cart.should_receive(:find_by_id).and_return(cart)
        controller.should_receive(:find_cartable).and_return(product)
        cart.should_receive(:add_item).with(product).and_return(cart_item)
      end

      let(:format) { :json }

      context "with valid params" do
        before do
          cart_item.should_receive(:save).and_return(true)

          post :create, format: format, use_route: :rightnow_oms
        end

        it { should respond_with :created }
        it { should respond_with_content_type /json/ }
      end

      context "with invalid params" do
        before do
          cart_item.should_receive(:save).and_return(false)

          post :create, format: format, use_route: :rightnow_oms
        end

        it { should respond_with :unprocessable_entity }
      end
    end
  end
end
