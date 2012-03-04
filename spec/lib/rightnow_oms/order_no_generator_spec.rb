require 'spec_helper'

module RightnowOms
  describe OrderNoGenerator do
    describe '#generate' do
      before do
        @order =  Order.new_with_items(fake_order_hash(1))
        @order.save

        @generator = OrderNoGenerator.new(@order)
      end


      it 'generates a valid No' do
        @generator.generate.should == ('%s%06d' % [@order.created_at.strftime('%Y%m%d'), @order.id])
      end
    end
  end
end
