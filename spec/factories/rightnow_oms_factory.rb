FactoryGirl.define do
  factory :cart, :class => RightnowOms::Cart do
  end

  factory :cart_item, :class => RightnowOms::CartItem do
    association :cart, factory: :cart
    association :cartable, factory: :product

    name { cartable.name }
    price { cartable.price }
    quantity 1
  end

  factory :order, :class => RightnowOms::Order do
  end
end
