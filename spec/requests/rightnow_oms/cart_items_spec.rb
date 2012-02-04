require 'spec_helper'

describe 'CartItems' do
  describe "POST /cart/cart_items" do
    let(:product) { FactoryGirl.create(:product) }
    before do
      post cart_cart_items_path, format: :json, cart_item: {
        cartable_id: product.id,
        cartable_type: product.class,
        quantity: 1
      }
    end

    subject { JSON.parse(response.body)["cart_item"] }

    specify { response.status.should == 201 }
    specify { subject["name"].should == product.name }
    specify { subject["price"].should == product.price.to_s }
    specify { subject["quantity"].should == 1 }
    specify { subject["total_price"].should == (product.price * 1).to_s }
  end

  describe "PUT /cart/cart_items/{id}" do
    let(:cart_item) { FactoryGirl.create(:cart_item) }
    let(:quantity) { 2 }

    before do
      put cart_cart_item_path(cart_item), format: :json, cart_item: {
        quantity: quantity
      }
    end

    subject { JSON.parse(response.body)["cart_item"] }

    specify { response.status.should == 200 }
    specify { subject["quantity"].should == quantity }
  end

  describe "DELETE /cart/cart_items/{id}" do
    context "when a cart item exists in a cart" do
      let(:cart_item) { FactoryGirl.create(:cart_item) }

      before { delete cart_cart_item_path(cart_item), format: :json }

      subject { response }

      its(:status) { should == 200 }
      it "removes the cart item" do
        RightnowOms::CartItem.should_not be_exist(id: cart_item.id)
      end
    end
  end
end
