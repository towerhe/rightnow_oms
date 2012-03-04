FactoryGirl.define do
  factory :cart, class: RightnowOms::Cart do
  end

  factory :cart_item, class: RightnowOms::CartItem do
    association :cart, factory: :cart
    association :cartable, factory: :product

    name { cartable.name }
    price { cartable.price }
    quantity 1
  end

  factory :order, class: RightnowOms::Order do
    province 'Beijing'
    city { Faker::Address.city }
    district 'Haidian'
    neighborhood { Faker::Address.neighborhood}
    room { '%02d%02d' % [rand(20), rand(20)] }
    receiver { Faker::Name.name }
    mobile { Faker::PhoneNumber.phone_number }
    tel { Faker::PhoneNumber.phone_number }
    payment_mode 'alipay'
    required_arrival_time { Time.now + 2.hours }
    user_id { rand(10) + 1 }
  end

  factory :order_item, class: RightnowOms::OrderItem do
    association :order

    name { Faker::Product.name }
    price { rand(100) }
    quantity { rand(5) }
  end
end
