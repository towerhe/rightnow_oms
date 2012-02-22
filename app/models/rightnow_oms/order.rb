module RightnowOms
  class Order < ActiveRecord::Base
    acts_as_api

    REQUIRED_ATTRS = %W(
      province city district neighborhood room
      receiver payment_mode order_items user_id
    )

    OPTIONAL_ATTRS = %W(
      street remarks vbrk mobile tel
    )

    has_many :order_items

    REQUIRED_ATTRS.each do |attr|
      validates attr, presence: true
    end

    validate :validates_mobile_and_tel

    api_accessible :default do |t|
      (REQUIRED_ATTRS + OPTIONAL_ATTRS).each do |attr|
        t.add attr.to_sym
      end
    end

    def order_no
      @generator ||= OrderNoGenerator.new(self)
      @generator.generate
    end

    def delivery_address
      "#{province}#{city}#{district}#{street}#{neighborhood}#{room}"
    end

    class << self
      def new_with_items(base, items)
        Order.new(base) do |o|
          items.each do |i|
            children = i.delete(:children)

            oi = o.order_items.build(i.merge(order: o))
            children.each { |c| oi.children.build(c.merge(order: o)) } if children
          end
        end
      end
    end

    private
    def validates_mobile_and_tel
      errors[:base] = 'One of mobile and tel must be present.' unless self.mobile || self.tel
    end
  end
end
