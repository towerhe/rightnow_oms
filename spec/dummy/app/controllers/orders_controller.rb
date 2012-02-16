class OrdersController < ApplicationController
  before_filter :load_or_create_cart, only: :new

  def new
    @order = RightnowOms::Order.new
  end
end
