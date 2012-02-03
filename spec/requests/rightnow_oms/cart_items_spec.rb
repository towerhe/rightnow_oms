require 'spec_helper'

describe 'CartItems' do
  describe "POST /cart/cart_items" do
    context "with json request" do
      before do
        @product = FactoryGirl.create(:product)

        post cart_cart_items_path, format: format, cart_item: {
                                     cartable_id: product.id,
                                     cartable_type: product.class,
                                     quantity: 1
                                   }
      end

      let(:format) { :json }
      let(:product) { @product }

      subject { JSON.parse(response.body)["cart_item"] }

      specify { response.status.should == 201 }
      specify { subject["name"].should == product.name }
      specify { subject["price"].should == product.price.to_s }
      specify { subject["quantity"].should == 1 }
      specify { subject["total_price"].should == (product.price * 1).to_s }
    end
  end
end
