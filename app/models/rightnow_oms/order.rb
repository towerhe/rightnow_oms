module RightnowOms
  class Order < ActiveRecord::Base
    REQUIRED_ATTRS = %W(
      province city district neighborhood room
      receiver payment_mode order_items
    )

    has_many :order_items

    REQUIRED_ATTRS.each do |attr|
      validates attr, presence: true
    end
    #validates_associated :order_items

    validate :validates_mobile_and_tel

    def delivery_address
      "#{province}#{city}#{district}#{street}#{neighborhood}#{room}"
    end

    class << self
      def new_with_items(base, items)
        Order.new(base) do |o|
          items.each { |i| o.order_items.build(i.merge(order: o)) }
        end
      end
    end

    private
    def validates_mobile_and_tel
      errors[:base] = 'One of mobile and tel must be present.' unless self.mobile || self.tel
    end
  end
end
