module RightnowOms
  class CartsController < ApplicationController
    before_filter :load_cart, only: [:show, :destroy]

    def show
      respond_to do |format|
        format.html
        format.json { render_for_api :default, json: @cart, root: :cart, status: :ok }
      end
    end

    def destroy
      @cart.destroy

      head :ok
    end
  end
end
