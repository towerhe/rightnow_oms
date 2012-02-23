module RightnowOms
  module ControllerExtension
    extend ActiveSupport::Concern

    def has_cart?
      !@cart.nil?
    end

    def load_or_create_cart
      load_cart

      unless has_cart?
        @cart = RightnowOms::Cart.create! and session[:cart_id] = @cart.id
      end
    end

    def load_cart
      @cart = RightnowOms::Cart.find_by_id(session[:cart_id])
    end

    def remove_null_params(data = params)
      data.each do |k, v|
        remove_null_params(v) if v.is_a? Hash
        data.delete(k) if v == 'null'
      end
    end
  end
end
