class ProductsController < ApplicationController
  before_filter :load_product_roots
  before_filter :load_or_create_cart, only: :index

  before_filter only: :booking do |c|
    c.load_or_create_cart :booking
  end

  before_filter only: :instant do |c|
    c.load_or_create_cart :instant
  end

  def index
    respond_to do |format|
      format.html
      format.json { render_for_api :default, json: @products, status: :ok, root: :products }
    end
  end

  def booking
    respond_to do |format|
      format.html
      format.json { render_for_api :default, json: @products, status: :ok }
    end
  end

  def instant
    respond_to do |format|
      format.html
      format.json { render_for_api :default, json: @products, status: :ok }
    end
  end

  private
  def load_product_roots
    @products = Product.roots
  end
end
