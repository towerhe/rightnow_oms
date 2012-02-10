# -*- encoding: utf-8 -*-
require 'spec_helper'

feature "Load cart", js: true do
  scenario "without any cart item" do
    visit '/products'

    page.find('#cart-wrapper').should have_cart(cartable_count: 0, total: 0.0)
  end
end
