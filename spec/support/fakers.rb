def fake_room_no
  "#{rand(10)}#{'%02d%02d' % [rand(20), rand(50)]}"
end

def fake_order_hash
    {
      province: 'Beijing', city: Faker::Address.city, district: 'Haidian', street: Faker::Address.street_name, neighborhood: Faker::Address.neighborhood, room: fake_room_no,
      receiver: Faker::Name.name, mobile: Faker::PhoneNumber.phone_number, tel: Faker::PhoneNumber.phone_number,
      payment_mode: 'alipay', remarks: Faker::Lorem.paragraph, vbrk: Faker::Company.name,
      line_items: [{
        name: Faker::Product.name, price: rand(100), quantity: rand(5), parent_id: 'null',
        name: Faker::Product.name, price: rand(100), quantity: rand(5), parent_id: 'null'
      }]
    }
end
