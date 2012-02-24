module RightnowOms
  module ControllerExtension
    extend ActiveSupport::Concern

    def has_cart?
      !@cart.nil?
    end

    def remove_null_params(data = params)
      data.each do |k, v|
        remove_null_params(v) if v.is_a? Hash
        data.delete(k) if v == 'null'
      end
    end

    def load_cart(key = nil)
      key ||= :current_cart_id
      @cart = RightnowOms::Cart.find_by_id(session[key])
    end

    def load_or_create_cart(name = nil)
      key = name ? "#{name}_cart_id".to_sym : :current_cart_id
      load_cart key

      unless has_cart?
        @cart = RightnowOms::Cart.create
      end

      session[:current_cart_id] = session[key] = @cart.id
    end

  end
end
