module RightnowOms
  class OrdersController < ApplicationController
    before_filter :load_cart, only: :create

    def show
      @order = Order.find(params[:id])
    end

    def create
      @order = Order.new_with_items(params[:order], get_order_items)

      respond_to do |format|
        if @order.save
          @cart.destroy

          format.html { redirect_to @order }
        else
          # TODO redirect to the new order url
          format.html { redirect_to '/' }
        end
      end
    end

    private
    def get_order_items
      @cart.cart_items.inject([]) do |c, i|
        c << { name: i.name, price: i.price, quantity: i.quantity }
      end
    end
  end
end
