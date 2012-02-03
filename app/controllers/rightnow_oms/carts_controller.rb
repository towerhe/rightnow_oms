module RightnowOms
  class CartsController < ApplicationController
    def show
      cart = Cart.find(session[:cart_id]) if session[:cart_id]

      unless cart
        cart = Cart.create
        session[:cart_id] = cart.id
      end

      respond_to do |format|
        format.json { render_for_api :default, json: cart, root: :cart, status: :ok }
      end
    end
  end
end
