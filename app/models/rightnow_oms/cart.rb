module RightnowOms
  class Cart < ActiveRecord::Base
    acts_as_api

    belongs_to :shopper
    has_many :cart_items, dependent: :destroy

    api_accessible :default do |t|
      t.add :id
      t.add :state
      t.add :cart_items, template: :default
    end

    def total
      cart_items.roots.map.sum(&:total) || 0
    end

    def cartable_count
      cart_items.roots.map.sum(&:quantity)
    end

    def add_item(cartable, opts = {})
      quantity = opts[:quantity] || 1
      mergable = true if opts[:mergable].nil?

      return create_item(cartable, opts) unless mergable

      cart_item = cart_items.find_by_cartable(cartable)
      if cart_item
        cart_item.update_attributes(
          quantity: cart_item.quantity + quantity.to_i,
        )
      else
        cart_item = create_item(cartable, opts)
      end

      cart_item
    end

    private
    def create_item(cartable, opts)
      cart_items.create(
        cartable: cartable,
        name: cartable.cartable_name,
        price: opts[:price] || cartable.cartable_price,
        base_quantity: opts[:base_quantity],
        quantity: opts[:quantity] || 1,
        group: opts[:group],
        parent_id: opts[:parent_id]
      )
    end
  end
end
