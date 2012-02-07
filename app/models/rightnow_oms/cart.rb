module RightnowOms
  class Cart < ActiveRecord::Base
    acts_as_api

    belongs_to :shopper
    has_many :cart_items, dependent: :destroy

    api_accessible :default do |t|
      t.add :id
      t.add :state
      t.add :total
    end

    def total
      cart_items.map.sum(&:total_price) || 0
    end

    def add_item(cartable, opts = { quantity: 1 })
      quantity = opts[:quantity]
      group = opts[:group]
      cart_item = cart_items.find_by_cartable(cartable)

      if cart_item
        cart_item.update_attributes(
          quantity: cart_item.quantity + quantity,
          group: group
        )
      else
        cart_item = cart_items.create!(
          cartable: cartable,
          name: cartable.name,
          price: cartable.price,
          quantity: quantity,
          group: group
        )
      end

      cart_item
    end
  end
end
