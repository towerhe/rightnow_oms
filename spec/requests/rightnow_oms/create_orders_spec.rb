require 'spec_helper'

feature 'Creating orders' do
  let(:order_hash) { fake_order_hash }

  scenario 'create an order' do
    post '/rightnow_oms/orders', order: order_hash

    order_hash.each do |k, v|
      page.should have_content(v) unless k == 'line_items'
    end

    order_hash[:line_items].each do |li|
      li.each { |k, v| page.should have_content(v) }
    end
  end
end
