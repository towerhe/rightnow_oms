#encoding: utf-8
require 'ffaker'

(rand(6) + 1).times { Product.create!(name: Faker::LoremCN.word, price: rand(100), group: '无厘头') }

(rand(6) + 1).times do |i|
  p = Product.create!(name: Faker::LoremCN.word, price: rand(100), group: '行云')
  (rand(4) + 1).times do |i|
    Product.create!(name: Faker::LoremCN.word, price: rand(100), parent: p, group: Faker::LoremCN.word)
  end
end
