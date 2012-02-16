require 'spec_helper'

describe RightnowOms::Cart do
  it { should belong_to :shopper }
  it { should have_many :cart_items }

  subject { FactoryGirl.create(:cart) }

  describe '#cartable_count' do
    let(:cart) { FactoryGirl.create(:cart) }
    subject { cart }

    context 'no child' do
      before do
        FactoryGirl.create(:cart_item, name: 'first', quantity: 1, cart: cart)
        FactoryGirl.create(:cart_item, name: 'second', quantity: 2, cart: cart)
      end

      its(:cartable_count) { should == 3 }
    end

    context 'having children' do
      before do
        FactoryGirl.create(:cart_item, name: 'first', quantity: 1, cart: cart)
        parent = FactoryGirl.create(:cart_item, name: 'second-parent', quantity: 2, cart: cart)
        FactoryGirl.create(:cart_item, name: 'second-child', quantity: 2, parent: parent, cart: cart)
      end
      
      its(:cartable_count) { should == 3 }
    end
  end

  describe '#total' do
    context 'with no items' do
      subject { FactoryGirl.build(:cart) }

      its(:total) { should == 0 }
    end

    context 'with items' do
      context 'and no child' do
        before { FactoryGirl.create(:cart_item, cart: subject) }

        let(:product) { FactoryGirl.build(:product) }

        its(:total) { should == product.price }
      end

      context 'and having children' do
        before do
          parent = FactoryGirl.create(:cart_item, name: 'parent', price: 1.0, cart: subject)
          FactoryGirl.create(:cart_item, name: 'child', price: 2.0, parent: parent, cart: subject)
        end

        its(:total) { should == 3 }
      end
    end
  end

  describe "#add_item" do
    let(:product) { FactoryGirl.create(:product, price: 10) }

    context 'when product does not exist' do
      before { subject.add_item(product) }

      its(:total) { should == product.price }
      its(:cart_items) { should have(1).item }

      specify { subject.cart_items.first.cartable.should == product }
      specify { subject.cart_items.first.name.should == product.name }
      specify { subject.cart_items.first.price.should == product.price }
      specify { subject.cart_items.first.quantity.should == 1 }
      specify { subject.cart_items.first.total_price.should == product.price * 1 }
    end

    context 'when product exists' do
      before { 2.times { subject.add_item(product) } }

      its(:total) { should == product.price * 2 }
      its(:cart_items) { should have(1).item }

      specify { subject.cart_items.first.cartable.should == product }
      specify { subject.cart_items.first.name.should == product.name }
      specify { subject.cart_items.first.price.should == product.price }
      specify { subject.cart_items.first.quantity.should == 2 }
      specify { subject.cart_items.first.total_price.should == product.price * 2 }
    end

    context 'when adding two different products' do
      let(:another_product) { FactoryGirl.create(:product, name: 'another product for test', price: 10) }

      before do
        subject.add_item(product)
        subject.add_item(another_product)
      end

      its(:total) { should == product.price + another_product.price }
      its(:cart_items) { should have(2).items }
    end
  end
end
