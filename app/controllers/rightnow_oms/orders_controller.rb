module RightnowOms
  class OrdersController < ApplicationController
    before_filter :load_cart, only: :create

    def show
      @order = Order.find(params[:id])
    end

    def create
      @order = Order.new_with_items(prepare_order)

      respond_to do |format|
        if @order.save
          @cart.destroy if @cart

          format.html { redirect_to @order }
          format.json { render_for_api :default, json: @order, root: :order, status: :ok }
        else
          format.html { redirect_to ::RightnowOms.config.new_order_url }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    end

    private
    def prepare_order
      return params[:order] if params[:order].has_key?(:order_items) || @cart.nil?

      items = @cart.cart_items.inject([]) do |c, i|
        item = { name: i.name, price: i.price, quantity: i.quantity }
        unless i.children.empty?
          children = i.children.inject([]) { |m, v| m << { name: v.name, price: v.price, quantity: v.quantity }}
          item[:children] = children
        end

        c << item
      end
      params[:order][:order_items] = items

      params[:order]
    end
  end
end
