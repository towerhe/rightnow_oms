require 'spec_helper'

module RightnowOms
  describe Order do
    describe 'db columns' do
      %W(
        province city district street neighborhood room
        receiver mobile tel
        payment_mode remarks vbrk
      ).each do |column|
        it { should have_db_column column }
      end
    end

    describe 'attributes' do
      it { should have_many :order_items }
    end

    describe 'validations' do
      %W(
        province city district neighborhood room
        receiver payment_mode
      ).each do |attr|
        it { should validate_presence_of attr }
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
end
