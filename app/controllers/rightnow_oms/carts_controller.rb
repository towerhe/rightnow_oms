module RightnowOms
  class CartsController < ApplicationController
    before_filter :load_or_create_cart, only: :show
    before_filter :load_cart, only: :destroy

    def show
      respond_to do |format|
        format.html
        format.json { render_for_api :default, json: @cart, root: :cart, status: :ok }
      end
    end

    def destroy
      @cart.destroy if has_cart?

      head :ok
    end
  end
end
