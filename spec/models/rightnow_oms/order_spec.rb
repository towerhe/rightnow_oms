require 'spec_helper'

module RightnowOms
  describe Order do
    describe 'db columns' do
      %W(
        province city district street neighborhood room
        receiver mobile tel
        payment_mode remarks vbrk
        user_id
      ).each do |column|
        it { should have_db_column column.to_sym }
      end
    end

    describe 'db indexes' do
      it { should have_db_index :user_id }
    end

    describe 'attributes' do
      it { should have_many :order_items }
    end

    describe 'validations' do
      %W(
        province city district neighborhood room
        receiver payment_mode order_items user_id
      ).each do |attr|
        it { should validate_presence_of attr.to_sym }
      end

      describe 'validates mobile and tel' do
        subject { Order.new(mobile: mobile, tel: tel) }
        let(:mobile) { nil }
        let(:tel)    { nil }

        context 'missing both' do
          it { should have(1).error_on(:base) }
        end

        context 'when mobile exists' do
          let(:mobile) { Faker::PhoneNumber.phone_number }

          it { should have(0).error_on(:base) }
        end

        context 'when tel exists' do
          let(:tel)    { Faker::PhoneNumber.phone_number }
          
          it { should have(0).error_on(:base) }
        end

        context 'when both exist' do
          let(:mobile) { Faker::PhoneNumber.phone_number }
          let(:tel)    { Faker::PhoneNumber.phone_number }

          it { should have(0).error_on(:base) }
        end
      end
    end
  end

  describe '.new_with_items' do
    let(:order_hash) { fake_order_hash }
    let(:order_items_hashes) { 2.times.inject([]) { |c| c << fake_order_item_hash } }

    subject { Order.new_with_items(order_hash, order_items_hashes) }

    its(:order_items) { should have(2).items }

    context 'with child order items' do
      let(:order_items_hashes) do
        parent = fake_order_item_hash
        parent[:children] = [fake_order_item_hash]

        [parent]
      end

      its(:order_items) { should have(1).item }
      specify { subject.order_items.first.children.should have(1).item }
    end
  end

  describe '#delivery_address' do
    subject { FactoryGirl.build(:order, province: 'Beijing', city: 'Beijing', district: 'Haidian', street: '17 of Daliushu Rd', neighborhood: 'Fuhai Center', room: '5#1804') }
    
    its(:delivery_address) { should == 'BeijingBeijingHaidian17 of Daliushu RdFuhai Center5#1804' }
  end
end
