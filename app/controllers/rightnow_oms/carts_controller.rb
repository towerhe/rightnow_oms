module RightnowOms
  class CartsController < ApplicationController
    before_filter :load_cart, only: :show

    def show
      respond_to do |format|
        format.json { render_for_api :default, json: @cart, root: :cart, status: :ok }
      end
    end
  end
end
