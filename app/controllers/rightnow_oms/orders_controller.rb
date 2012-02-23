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
          format.json { render_for_api :default, json: @order, root: :order, status: :ok }
        else
          format.html { redirect_to ::RightnowOms.config.new_order_url }
          format.json { render json: @order.errors, status: :unprocessable_entity }
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
