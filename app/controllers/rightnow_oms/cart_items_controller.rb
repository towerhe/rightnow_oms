module RightnowOms
  class CartItemsController < ApplicationController
    before_filter :load_cart, only: :create

    def create
      cart_item = @cart.add_item(find_cartable)

      respond_to do |format|
        if cart_item.save
          format.json { render_for_api :default, json: cart_item, root: :cart_item, status: :created }
        else
          format.json { render json: cart_item.errors, status: :unprocessable_entity }
        end
      end
    end

    private
    def load_cart
      @cart = Cart.find_by_id(session[:cart_id]) || Cart.create
      session[:cart_id] = @cart.id
    end

    def find_cartable
      cartable_id = params[:cart_item][:cartable_id]
      cartable_type = params[:cart_item][:cartable_type]

      cartable_type.constantize.find_by_id(cartable_id)
    end
  end
end
