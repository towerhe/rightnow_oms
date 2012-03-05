# -*- encoding: utf-8 -*-
RSpec::Matchers.define :have_cart do |cart|
  match do |actual|
    actual.trigger('hover')

    actual.has_content?("Shopping Cart (#{cart[:cartable_count]})") &&
      actual.has_content?("Check Cart") &&
      actual.has_content?("Total $#{cart[:total].round(2)}")
  end
end

RSpec::Matchers.define :have_cart_item do |item|
  match do |actual|
    matched = actual.has_content?(item[:name]) &&
      actual.has_content?("#{'%.2f' % item[:price]}x#{item[:quantity]}")

    matched
  end
end

RSpec::Matchers.define :have_cart_items do |items|
  match do |actual|
    items.each { |i| return false unless have_cart_item(i) }
  end
end
