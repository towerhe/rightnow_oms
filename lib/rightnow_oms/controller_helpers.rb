module RightnowOms
  module ControllerHelpers
    extend ActiveSupport::Concern

    module InstanceMethods
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

    end
  end
end
