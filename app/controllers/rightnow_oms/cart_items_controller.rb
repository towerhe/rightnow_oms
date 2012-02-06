module RightnowOms
  class CartItemsController < ApplicationController
    before_filter :load_cart, only: [:index, :create]
    before_filter :load_cart_item, only: [:update, :destroy]

    # TODO Unit test needed
    def index
      render_for_api :default, json: @cart.cart_items, root: :cart_items, status: :ok
    end

    def create
      if @cart.new_record?
        @cart.save
        session[:cart_id] = @cart.id
      end

      cart_item = @cart.add_item(find_cartable)

      respond_to do |format|
        if cart_item.save
          format.json { render_for_api :default, json: cart_item, root: :cart_item, status: :created }
        else
          format.json { render json: cart_item.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @cart_item.update_attributes(params[:cart_item])
          format.json { render_for_api :default, json: @cart_item, root: :cart_item, status: :ok }
        else
          format.json { render json: @cart_item, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @cart_item.destroy

      head :ok
    end

    private
    def find_cartable
      cartable_id = params[:cart_item][:cartable_id]
      cartable_type = params[:cart_item][:cartable_type]

      cartable_type.constantize.find_by_id(cartable_id)
    end

    def load_cart_item
      @cart_item = CartItem.find(params[:id])
    end
  end
end
