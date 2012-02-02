module RightnowOms
  class CartsController < ApplicationController
    def show
      cart = Cart.first || Cart.create!(session_id: request.session_options[:id])

      respond_to do |format|
        format.json { render_for_api :default, json: cart, status: :ok }
      end
    end
  end
end
