require 'spec_helper'

describe RightnowOms::ActsAsCartable do
  it 'introduces acts_as_cartable to ActiveRecord' do
    CartableModel.should respond_to :acts_as_cartable
  end

  it 'introduces acts_as_cartable? to ActiveRecord' do
    CartableModel.should respond_to :acts_as_cartable?
    CartableModel.should_not be_acts_as_cartable
  end

  describe 'CartableModel.acts_as_cartable' do
    context 'with default settings' do
      before { CartableModel.acts_as_cartable }
      subject { CartableModel.new }

      it { should respond_to :cartable_name }
      it { should respond_to :cartable_price }
      specify { expect { subject.cartable_name  }.to raise_error }
      specify { expect { subject.cartable_price }.to raise_error }
    end

    context 'with customized settings' do
      before { CartableModel.acts_as_cartable name: :my_name, price: :my_price }
      subject do
        cartable = CartableModel.new
        cartable.my_name  = 'Rightnow OMS'
        cartable.my_price = 0.0

        cartable
      end

      its(:cartable_name)  { should == 'Rightnow OMS' }
      its(:cartable_price) { should == 0.0 }
    end
  end
end
