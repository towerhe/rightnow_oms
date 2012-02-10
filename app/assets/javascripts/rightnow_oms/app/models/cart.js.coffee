RightnowOms.Cart = DS.Model.extend
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
    cartItem = RightnowOms.CartItem.findByCartableAndParentId(item.cartable_id, item.cartable_type, item.parent_id)

    if cartItem?
      cartItem.increase() unless cartItem.get('parent')?
    else
      cartItem = RightnowOms.store.createRecord(RightnowOms.CartItem, item)

    cartItem

  removeCartItem: (id) ->
    cartItem = RightnowOms.CartItem.findById(id)
    
    cartItem.deleteRecord() if cartItem?

    cartItem

  increaseCartItem: (id) ->
    cartItem = RightnowOms.CartItem.findById(id)

    cartItem.increase()
    cartItem

  decreaseCartItem: (id) ->
    cartItem = RightnowOms.CartItem.findById(id)

    cartItem.decrease()
    #removeCartItem(id) if cartItem.get('quantity') <= 0
    cartItem

RightnowOms.Cart.reopenClass
  isSingleton: true
