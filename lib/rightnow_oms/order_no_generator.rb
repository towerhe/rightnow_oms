module RightnowOms
  class OrderNoGenerator
    NO_FORMAT = '%s%06d'

    def initialize(order)
      @order = order
    end

    def generate
      NO_FORMAT % [@order.created_at.strftime('%Y%m%d'), @order.id]
    end
  end
end
