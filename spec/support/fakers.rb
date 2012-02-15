def fake_room_no
  "#{rand(10)}#{'%02d%02d' % [rand(20), rand(50)]}"
end

def fake_order_hash(items_count = nil)
  address = {
    province: 'Beijing', city: Faker::Address.city, district: 'Haidian',
    street: Faker::Address.street_name, neighborhood: Faker::Address.neighborhood, room: fake_room_no
  }

  contact = {
    receiver: Faker::Name.name, mobile: Faker::PhoneNumber.phone_number, tel: Faker::PhoneNumber.phone_number
  }

  misc = {
    payment_mode: 'alipay', remarks: Faker::Lorem.paragraph, vbrk: Faker::Company.name, user_id: rand(100) + 1
  }

  order = address.merge(contact).merge(misc)

  return order unless items_count

  order_items = items_count.times.inject([]) { |c| c << fake_order_item_hash }

  order.merge(order_items: order_items)
end

def fake_order_item_hash
  { name: Faker::Product.name, price: rand(100), quantity: rand(5) + 1 }
end
