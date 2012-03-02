require 'spec_helper'

module RightnowOms
  describe OrderItem do
    describe 'db columns' do
      %W(id name price quantity parent_id tastes).each do |column|
        it { should have_db_column column }
      end
    end

    describe 'db index' do
      %W(order_id parent_id).each do |column|
        it { should have_db_index column }
      end
    end

    describe 'attributes' do
      it { should belong_to :order }
      it { should belong_to :parent }
      it { should have_many :children }
    end

    describe 'validations' do
      %W(name price quantity order).each do |attr|
        it { should validate_presence_of attr }
      end

      it { should validate_numericality_of :price }
      it { should_not allow_value(-1).for(:price) }

      it { should validate_numericality_of :quantity }
      it { should_not allow_value(0).for(:quantity) }
    end
  end

  describe '.total' do
    subject { Factory.build(:order_item, order: nil, price: 10, quantity: 2) }

    its(:total) { should == 20 }
  end
end
