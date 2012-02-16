module RightnowOms
  class Cart < ActiveRecord::Base
    acts_as_api

    belongs_to :shopper
    has_many :cart_items, dependent: :destroy

    api_accessible :default do |t|
      t.add :id
      t.add :state
    end

    def total
      cart_items.map.sum(&:total_price) || 0
    end

    def cartable_count
      cart_items.select{ |v| v.parent.nil? }.map.sum(&:quantity)
    end

    def add_item(cartable, opts = { quantity: 1 })
      cart_item = cart_items.find_by_cartable(cartable)

      if cart_item
        cart_item.update_attributes(
          quantity: cart_item.quantity + opts[:quantity].to_i,
        )
      else
        cart_item = cart_items.create(
          cartable: cartable,
          name: cartable.cartable_name,
          price: opts[:price] || cartable.cartable_price,
          quantity: opts[:quantity],
          group: opts[:group],
          parent_id: opts[:parent_id]
        )
      end

      cart_item
    end
  end
end
