module RightnowOms
  class ApplicationController < ActionController::Base

    protected
    def load_cart
      @cart = Cart.find_by_id(session[:cart_id]) || Cart.new
    end
  end
end
