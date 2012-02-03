module RightnowOms
  class Cart < ActiveRecord::Base
    acts_as_api

    belongs_to :shopper
    has_many :cart_items

    api_accessible :default do |t|
      t.add :state
      t.add :total
      t.add :cart_items, template: :default
    end

    def total
      cart_items.map.sum(&:total_price) || 0
    end

    def add_item(cartable, quantity = 1)
      existing_item = cart_items.find_by_cartable(cartable)

      if existing_item
        existing_item.update_attributes(quantity: existing_item.quantity + quantity)
      else
        cart_items.create!(cartable: cartable, name: cartable.name, price: cartable.price, quantity: quantity)
      end
    end
  end
end
