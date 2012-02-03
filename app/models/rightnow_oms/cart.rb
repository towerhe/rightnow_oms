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
  end
end
