require 'spec_helper'

describe "Carts" do
  describe "GET /cart" do
    context "with json request" do
      let(:format) { 'json' }

      context "when no cart exists" do
        before { RightnowOms::Cart.destroy_all }

        it "creates a new cart" do
          get cart_path, format: format

          Cart.all.should have(1).item
        end
      end

      context "when a cart with items exists" do
      end
    end
  end
end
