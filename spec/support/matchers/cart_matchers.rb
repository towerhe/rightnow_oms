# -*- encoding: utf-8 -*-
RSpec::Matchers.define :have_cart do |cart|
  match do |actual|
    actual.trigger('hover')

    actual.has_content?("购物车 #{cart[:cartable_count]} 件") &&
      actual.has_content?("查看我的购物车") &&
      actual.has_content?("总计：￥#{cart[:total].round(2)}")
  end
end

RSpec::Matchers.define :have_cart_item do |item|
  match do |actual|
    matched = actual.has_content?(item[:name]) &&
      actual.has_content?("#{'%.2f' % item[:price]}x#{item[:quantity]}")
    #matched &&= wrapper.has_content?('删除') if item[:deletable]

    matched
  end
end

RSpec::Matchers.define :have_cart_items do |items|
  match do |actual|
    items.each { |i| return false unless have_cart_item(i) }
  end
end
