require 'ffaker'

10.times { Product.create!(name: Faker::LoremCN.word, price: rand(100)) }
