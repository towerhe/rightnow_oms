# -*- encoding: utf-8 -*-
RSpec::Matchers.define :have_cart do |cart|
  match do |actual|
    actual.trigger('hover')

    actual.has_content?("购物车 #{cart[:cartable_count]} 件") &&
      actual.has_content?("查看我的购物车") &&
      actual.has_content?("总计：￥#{cart[:total].round(2)}")
  end
end

RSpec::Matchers.define :have_cart_items do |items|
  match do |actual|
    success = true
    actual.all('tr').each_with_index do |tr, i|
      break if i == items.size

      success &&= tr.has_content?(items[i][:name])
      success &&= tr.has_content?("#{'%.2f' % items[i][:price]}x#{items[i][:quantity]}")
      if items[i][:deletable]
        success &&= tr.has_content?('删除')
      else
        success &&= tr.has_no_content?('删除')
      end
    end

    success
  end
end
