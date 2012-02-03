require 'spec_helper'

describe RightnowOms::Cart do
  it { should belong_to :shopper }
  it { should have_many :cart_items }

  describe '#total' do
    context 'with no items' do
      subject { RightnowOms::Cart.new }

      its(:total) { should == 0 }
    end

    context 'with items' do
      let(:product) { Product.create(name: 'for_test', price: 10.55) }
      subject { RightnowOms::Cart.create }

      before { subject.cart_items.create(cartable: product, name: product.name, price: product.price, quantity: 1) }

      its(:total) { should == 10.55 }
    end
  end
end
