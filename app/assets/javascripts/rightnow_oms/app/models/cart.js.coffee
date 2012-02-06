store = RightnowOms.store

RightnowOms.Cart = DS.Model.extend
  total: DS.attr('string')
  #cart_items: DS.hasMany(RightnowOms.CartItem, embedded: true)

  cartItems: (->
    RightnowOms.CartItem.all()
  ).property()

  cartableCount: (->
    count = 0
    this.get('cartItems').forEach (item, index, self) ->
      count += item.get('quantity')

    count
  ).property("cartItems.@each.quantity")

  addCartItem: (item) ->
    cartItem = RightnowOms.CartItem.findByName(item.name)

    if cartItem?
      cartItem.set('quantity', cartItem.get('quantity') + 1)
    else
      store.createRecord(RightnowOms.CartItem, item)

    store.commit()


RightnowOms.Cart.reopenClass
  isSingleton: true
