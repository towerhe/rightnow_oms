module RightnowOms
  class Order < ActiveRecord::Base
    REQUIRED_ATTRS = %W(
      province city district neighborhood room
      receiver payment_mode
    )

    has_many :order_items

    REQUIRED_ATTRS.each do |attr|
      validates attr, presence: true
    end

    validate :validates_mobile_and_tel


    private
    def validates_mobile_and_tel
      errors[:base] = 'One of mobile and tel must be present.' unless self.mobile || self.tel
    end
  end
end
