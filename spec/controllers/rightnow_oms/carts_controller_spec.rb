require 'spec_helper'

describe RightnowOms::CartsController do
  describe '#show' do
    context 'GET json' do
      let(:format) { :json }

      before(:each) do
        get :show, format: :json, use_route: :rightnow_oms
      end

      it { should respond_with :ok }
      it { should respond_with_content_type /json/ }
    end
  end

  describe 'DELETE destroy' do
    let(:cart) { FactoryGirl.create(:cart) }

    before do
      RightnowOms::Cart.should_receive(:find_by_id).and_return(cart)
      cart.should_receive(:destroy)

      delete :destroy, format: :json, use_route: :rightnow_oms
    end

    it { should respond_with :ok }
    it { should respond_with_content_type /json/ }
  end
end
