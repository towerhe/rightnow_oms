RightnowOms.Cart = DS.Model.extend
  cartItems: (->
    RightnowOms.CartItem.all()
  ).property()

  cartableCount: (->
    count = 0
    @get('cartItems').forEach (item) ->
      count += item.get('quantity') unless item.get('hasParent')

    count
  ).property("cartItems.@each.quantity")

  total: (->
    total = 0
    @get('cartItems').forEach (item) ->
      total += item.get('subtotal') unless item.get('hasParent')

    round(total, 2)
  ).property("cartItems.@each.total")

  addCartItem: (item) ->
    cartItem = RightnowOms.CartItem.findByCartableAndParentId(item.cartable_id, item.cartable_type, item.parent_id)

    if cartItem?
      cartItem.increase() unless cartItem.get('parent')?
    else
      cartItem = RightnowOms.store.createRecord(RightnowOms.CartItem, item)

      if cartItem.get('hasParent')
        cartItem.get('parent').set('children', RightnowOms.CartItem.findByParentId(cartItem.get('id')))

    cartItem

  updateCartItem: (id, properties) ->
    cartItem = RightnowOms.CartItem.findById(id)
    cartItem.setProperties(properties) if cartItem?
    
  cleanUp: ->
    cartItemIds = @get('cartItems').map (item) ->
      return item.get('id')

    cartItemIds.forEach (id) ->
      item = RightnowOms.CartItem.findById(id)

      # INFO Children will be deleted when the parent is deleted
      item.deleteRecord() if item && !item.get('hasParent')

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
    cartItem

  findCartItemsByGroup: (group) ->
    @get('cartItems').filter (item) ->
      return true if item.get('group') == group

RightnowOms.Cart.reopenClass
  isSingleton: true
