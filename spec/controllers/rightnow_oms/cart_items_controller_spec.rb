require 'spec_helper'

describe RightnowOms::CartItemsController do
  let(:product) { FactoryGirl.build(:product) }

  describe "POST create" do
    context "when the cart is saved" do
      let(:cart) { FactoryGirl.create(:cart) }
      let(:cart_item) { FactoryGirl.build(:cart_item, cart: cart) }

      before do
        RightnowOms::Cart.should_receive(:find_by_id).and_return(cart)
        controller.should_receive(:find_cartable).and_return(product)
        cart.should_receive(:add_item).and_return(cart_item)
      end

      context "with valid params" do
        before do
          cart_item.should_receive(:save).and_return(true)

          post :create, format: :json, use_route: :rightnow_oms
        end

        it { should respond_with :created }
        it { should respond_with_content_type /json/ }
      end

      context "with invalid params" do
        before do
          cart_item.should_receive(:save).and_return(false)

          post :create, format: :json, use_route: :rightnow_oms
        end

        it { should respond_with :unprocessable_entity }
      end
    end

    context "when the cart is not saved" do
      let(:cart) { FactoryGirl.build(:cart) }
      let(:cart_item) { FactoryGirl.build(:cart_item) }

      before do
        RightnowOms::Cart.should_receive(:find_by_id).and_return(cart)
      end

      it 'saves the cart' do
        cart.should_receive(:new_record?).and_return(true)
        cart.should_receive(:save)
        controller.should_receive(:find_cartable).and_return(product)
        cart.should_receive(:add_item).and_return(cart_item)

        post :create, format: :json, use_route: :rightnow_oms
      end
    end
  end

  describe 'PUT update' do
    let(:cart_item) { FactoryGirl.build(:cart_item) }
    before { RightnowOms::CartItem.should_receive(:find).and_return(cart_item) }

    context 'with valid params' do
      before do
        cart_item.should_receive(:update_attributes).and_return(true)

        put :update, format: :json, use_route: :rightnow_oms
      end

      it { should respond_with :ok }
      it { should respond_with_content_type /json/ }
    end

    context 'with invalid params' do
      before do
        cart_item.should_receive(:update_attributes).and_return(false)

        put :update, format: :json, use_route: :rightnow_oms
      end

      it { should respond_with :unprocessable_entity }
      it { should respond_with_content_type /json/ }
    end
  end

  describe 'DELETE destroy' do
    let(:cart_item) { FactoryGirl.build(:cart_item) }

    before do
      RightnowOms::CartItem.should_receive(:find).and_return(cart_item)
      cart_item.should_receive(:destroy)

      delete :destroy, use_route: :rightnow_oms
    end

    it { should respond_with :ok }
  end
end
