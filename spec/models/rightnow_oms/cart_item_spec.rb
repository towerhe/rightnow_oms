require 'spec_helper'

describe RightnowOms::CartItem do
  it { should belong_to :cartable }
  it { should belong_to :cart }
  it { should belong_to :parent }
  it { should have_many :children }
  
  it { should validate_presence_of :cartable }
  it { should validate_presence_of :cart }
  it { should validate_presence_of :name }
  it { should validate_presence_of :price }
  it { should validate_presence_of :quantity }

  it { should validate_numericality_of :price }
  it { should validate_numericality_of :quantity }

  it { should_not allow_value(-1).for(:price) }
  it { should_not allow_value(-1).for(:quantity) }
  it { should_not allow_value(0).for(:quantity) }

  it { should allow_value(Product.new).for(:cartable) }
  it { should_not allow_value(RightnowOms::Cart.new).for(:cartable) }

  describe "#total" do
    context 'without child' do
      subject { FactoryGirl.build(:cart_item, price: 10.55, quantity: 2) }

      its(:total) { should == 10.55 * 2 }
    end

    context 'with children' do
      before do
        @parent = FactoryGirl.create(:cart_item, name: 'parent', price: 40, quantity: 1)
        FactoryGirl.create(:cart_item, name: 'child', price: 20, quantity: 2, parent: @parent)
      end

      subject { @parent }

      its(:total) { should == 40 }
    end
  end

  describe ".find_by_cartable" do
    let(:cart_item) { FactoryGirl.create(:cart_item) }

    subject { RightnowOms::CartItem.find_by_cartable(cart_item.cartable) }

    it { should be }
  end

  describe ".as_api_response" do
    let(:cart_item) { FactoryGirl.create(:cart_item) }

    subject { cart_item.as_api_response(:default) }

    it { should have_key :id }
    it { should have_key :parent_id }
    it { should have_key :cartable_id }
    it { should have_key :cartable_type }
    it { should have_key :name }
    it { should have_key :original_price }
    it { should have_key :price }
    it { should have_key :quantity }
    it { should have_key :group }
  end
end
