class ProductsController < ApplicationController
  before_filter :load_or_create_cart, only: :index
  before_filter only: :booking do |c|
    c.load_or_create_cart :booking
  end

  before_filter only: :instant do |c|
    c.load_or_create_cart :instant
  end

  def index
    @products = Product.all

    respond_to do |format|
      format.html
      format.json { render_for_api :default, json: @products, status: :ok, root: :products }
    end
  end

  def booking
    @products = Product.all

    respond_to do |format|
      format.html
      format.json { render_for_api :default, json: @products, status: :ok }
    end
  end

  def instant
    @products = Product.all

    respond_to do |format|
      format.html
      format.json { render_for_api :default, json: @products, status: :ok }
    end
  end
end
