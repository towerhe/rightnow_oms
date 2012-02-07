store = RightnowOms.store

RightnowOms.Cart = DS.Model.extend
  total: DS.attr('string')
  #cart_items: DS.hasMany(RightnowOms.CartItem, embedded: true)

  cartItems: (->
    RightnowOms.CartItem.all()
  ).property()

  cartableCount: (->
    count = 0
    @get('cartItems').forEach (item) ->
      count += item.get('quantity')

    count
  ).property("cartItems.@each.quantity")

  total: (->
    total = 0
    @get('cartItems').forEach (item) ->
      total += parseFloat(item.get('price')) * item.get('quantity')

    round(total, 2)
  ).property("cartableCount")

  addCartItem: (item) ->
    cartItem = RightnowOms.CartItem.findByName(item.name)

    if cartItem?
      cartItem.set('quantity', cartItem.get('quantity') + 1)
    else
      store.createRecord(RightnowOms.CartItem, item)

    store.commit()

  removeCartItem: (id) ->
    item = RightnowOms.CartItem.findById(id)
    
    if item?
      item.deleteRecord()
      RightnowOms.store.commit()

  plusCartItem: (id) ->
    cartItem = RightnowOms.CartItem.findById(id)

    cartItem.increase()
    store.commit()

  minusCartItem: (id) ->
    cartItem = RightnowOms.CartItem.findById(id)

    cartItem.decrease()
    removeCartItem(id) if cartItem.get('quantity') <= 0
    store.commit()


RightnowOms.Cart.reopenClass
  isSingleton: true
