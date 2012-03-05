#encoding: utf-8
require 'ffaker'

(rand(6) + 1).times do
  name = Faker::Product.product_name
  Product.find_or_create_by_name(name, price: rand(100), group: 'Instant')
end

(rand(6) + 1).times do |i|
  name = Faker::Product.product_name

  unless Product.exists?(name: name)
    p = Product.create!(name: name, price: rand(100), group: 'Booking')
    (rand(4) + 1).times do |i|
      n = Faker::Product.product_name
      Product.find_or_create_by_name(n, price: rand(100), parent: p, group: 'Booking')
    end
    p.update_attribute(:price, p.children.sum(&:price))
  end

end
