module RightnowOms
  class Order < ActiveRecord::Base
    acts_as_api

    REQUIRED_ATTRS = %W(
      province city district neighborhood room
      receiver payment_mode order_items user_id
      required_arrival_time
    )

    OPTIONAL_ATTRS = %W(
      street remarks vbrk mobile tel
    )

    has_many :order_items

    REQUIRED_ATTRS.each do |attr|
      validates attr, presence: true
    end

    validate :validates_mobile_and_tel
    validates_datetime :required_arrival_time, after: lambda { Time.now + RightnowOms.config.shortest_delivery_period }

    api_accessible :default do |t|
      t.add :id
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
      def new_with_items(order)
        items = order.delete(:order_items)

        Order.new(order) do |o|
          items.each do |i|
            children = i.delete(:children)

            oi = o.order_items.build(i.merge(order: o))
            children.each { |c| oi.children.build(c.merge(order: o)) } if children
          end
        end
      end

      def create_with_items(order)
        o = new_with_items(order)
        o.save

        o
      end
    end

    private
    def validates_mobile_and_tel
      errors[:base] = 'One of mobile and tel must be present.' unless self.mobile || self.tel
    end
  end
end
