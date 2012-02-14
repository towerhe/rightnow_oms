module RightnowOms
  class OrderItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :parent, class_name: 'RightnowOms::OrderItem', foreign_key: :parent_id
    has_many :children, class_name: 'RightnowOms::OrderItem', foreign_key: :parent_id, dependent: :destroy

    validates :order, presence: true
    validates :name, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :quantity, presence:true, numericality: { greater_than: 0 }
  end
end
