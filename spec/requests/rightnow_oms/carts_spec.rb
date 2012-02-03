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
          RightnowOms::Cart.all.should have(1).item
        end

        its(:status) { should == 200 }
        its(:content_type) { should == "application/json" }
      end

      context "when a cart with items exists" do
        let(:product) { Product.create(name: 'for_test', price: 10.55) }
        let(:cart) { RightnowOms::Cart.create }

        before do
          cart.cart_items.create!(cartable: product, name: product.name, price: product.price, quantity: 1)
          page.set_rack_session(cart_id: cart.id)

          page.visit '/rightnow_oms/cart.json'
        end

        subject { JSON.parse(page.text)["cart"] }

        specify { subject["total"].should == "10.55" }
        specify { subject["cart_items"].should have(1).item }
        specify { subject["cart_items"].first["name"].should == product.name }
        specify { subject["cart_items"].first["price"].should == product.price.to_s }
        specify { subject["cart_items"].first["quantity"].should == 1 }
        specify { subject["cart_items"].first["total_price"].should == (product.price * 1).to_s }
      end
    end
  end
end
