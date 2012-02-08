module RightnowOms
  class ApplicationController < ActionController::Base
    before_filter :set_null_to_nil

    protected
    def load_cart
      @cart = Cart.find_by_id(session[:cart_id]) || Cart.new
    end

    def set_null_to_nil(data = params)
      data.each do |k, v|
        set_null_to_nil(v) if v.is_a? Hash
        data[k] = nil if v == 'null'
      end
    end
  end
end
