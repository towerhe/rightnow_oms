require 'spec_helper'

describe "Carts" do
  describe "GET /cart" do
    context "with json request" do
      let(:format) { :json }

      context "when no cart exists" do
        before do
          RightnowOms::Cart.destroy_all

          get cart_path, format: format
        end

        subject { response }

        it "creates a new cart" do
          RightnowOms::Cart.all.should have(1).items
        end

        its(:status) { should == 200 }
        its(:content_type) { should == "application/json" }
      end

      context "when a cart with items exists" do
        let(:product) { FactoryGirl.build(:product) }
        let(:cart) { FactoryGirl.create(:cart) }

        before do
          FactoryGirl.create(:cart_item, cart: cart)
          page.set_rack_session(cart_id: cart.id)

          visit '/rightnow_oms/cart.json'
        end

        subject { JSON.parse(page.text)["cart"] }

        specify { subject["id"].should be }
      end
    end
  end

  describe 'DELETE /cart' do
    before do
      cart_item = FactoryGirl.create(:cart_item)
      page.set_rack_session(cart_id: cart_item.cart.id)

      page.driver.submit :delete, cart_path, format: :json
    end

    it 'removes the cart items' do
      RightnowOms::CartItem.should_not be_exist
    end

    it 'removes the cart' do
      RightnowOms::Cart.should_not be_exist
    end
  end
end
