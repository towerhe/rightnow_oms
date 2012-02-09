class ProductsController < ApplicationController
  before_filter :load_or_create_cart, only: :index

  def index
    @products = Product.all

    respond_to do |format|
      format.html
      format.json { render_for_api :default, json: @products, status: :ok, root: :products }
    end
  end
end
