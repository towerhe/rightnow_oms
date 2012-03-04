module RightnowOms
  module ControllerHelpers
    def current_cart
      @cart
    end

    def list_items(items)
      render partial: "rightnow_oms/cart_items/list", locals: { items: items }
    end
  end
end
