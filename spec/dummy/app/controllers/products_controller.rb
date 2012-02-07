class ProductsController < ApplicationController
  def index
    @cart = RightnowOms::Cart.find_by_id(session[:cart_id]) || RightnowOms::Cart.new

    # TODO To be removed
    if @cart.new_record?
      @cart.save
      session[:cart_id] = @cart.id
    end

    @products = Product.all

    respond_to do |format|
      format.html
      format.json { render_for_api :default, json: @products, status: :ok, root: :products }
    end
  end
end
