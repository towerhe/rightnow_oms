module RightnowOms
  class CartItem < ActiveRecord::Base
    acts_as_api

    belongs_to :cartable, polymorphic: true
    belongs_to :cart
    belongs_to :parent, class_name: 'RightnowOms::CartItem', foreign_key: :parent_id
    has_many :children, class_name: 'RightnowOms::CartItem', foreign_key: :parent_id, dependent: :destroy

    validates :cartable, presence: true
    validates :cart, presence: true
    validates :name, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :quantity, presence: true, numericality: { greater_than: 0 }

    api_accessible :default do |t|
      t.add :id
      t.add :parent_id
      t.add :cartable_id
      t.add :cartable_type
      t.add :name
      t.add :price
      t.add :quantity
      t.add :group
    end

    def total_price
      price * quantity
    end

    class << self
      def find_by_cartable(cartable)
        find_by_cartable_id_and_cartable_type(cartable.id, cartable.class)
      end
    end
  end
end
