#encoding: utf-8
require 'ffaker'

5.times { Product.create!(name: Faker::LoremCN.word, price: rand(100), group: '无厘头') }

5.times do |i|
  p = Product.create!(name: Faker::LoremCN.word, price: rand(100), group: '行云')
  Product.create!(name: Faker::LoremCN.word, price: rand(100), parent: p, group: Faker::LoremCN.word)
end
