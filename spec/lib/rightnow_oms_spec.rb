require 'spec_helper'

describe RightnowOms do
  describe '.config' do
    subject { RightnowOms.config }

    it { should be_a Confstruct::Configuration }
  end

  describe '.configure' do
    before { @new_order_url = RightnowOms.config.new_order_url }

    after do
      RightnowOms.configure do
        new_order_url { @new_order_url }
      end
    end

    it 'sets the new order url' do
      RightnowOms.configure do
        new_order_url '/another/orders/new'
      end

      RightnowOms.config.new_order_url.should == '/another/orders/new'
    end
  end
end

