require 'spec_helper'

module RightnowOms
  describe OrderNoGenerator do
    let(:order) do
      o =  Order.new_with_items(fake_order_hash, [fake_order_item_hash])
      o.save
      
      o
    end

    describe '#generate' do
      let(:generator) { OrderNoGenerator.new(order) }

      it 'generates a valid No' do
        generator.generate.should == ('%s%06d' % [order.created_at.strftime('%Y%m%d'), order.id])
      end
    end
  end
end
