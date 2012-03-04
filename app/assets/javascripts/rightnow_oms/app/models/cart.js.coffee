RightnowOms.Cart = DS.Model.extend
  cart_items: DS.hasMany('RightnowOms.CartItem', { embedded: true })

  # TODO Use cart_items instead
  cartItems: Ember.computed(->
    @get('cart_items')
  ).property("cart_items")

  cartableCount: Ember.computed(->
    count = 0
    @get('cart_items').forEach (item) ->
      count += item.get('quantity') unless item.get('hasParent')

    count
  ).property("cart_items.@each.quantity")

  total: Ember.computed(->
    total = 0
    @get('cart_items').forEach (item) ->
      total += item.get('price') * item.get('quantity') unless item.get('hasParent')

    round(total, 2)
  ).property("cart_items.@each.quantity", "cart_items.@each.price")

  addCartItem: (item) ->
    return @createCartItem(item) if item.mergable == false

    cartItem = @findCartItemByCartable(item.cartable_id, item.cartable_type)

    if cartItem? && !cartItem.get('hasParent')
      cartItem.increase()
    else
      cartItem = @createCartItem(item)

    cartItem

  createCartItem: (item)->
    cartItem = RightnowOms.CartItem.createRecord(item)
    @get('cart_items').pushObject(cartItem)

    return cartItem if !(item.children && item.children.length > 0)

    return cartItem.addChild(c) for c in item.children if cartItem.get('id')?

    afterCartItemCreated = ->
      if (!cartItem.get('isDirty')) && (!cartItem.get('isDeleted'))
        cartItem.addChild(c) for c in item.children
        cartItem.removeObserver('isDirty', afterCartItemCreated)
        RightnowOms.commit(true) if RightnowOms.config.get('autoCommit')

    cartItem.addObserver('isDirty', afterCartItemCreated)

    cartItem

  updateCartItem: (id, properties) ->
    cartItem = @findCartItemById(id)
    cartItem.setProperties(properties) if cartItem?
    
  cleanUp: ->
    cartItemIds = @get('cart_items').map (item) ->
      return item.get('id')

    self = @
    cartItemIds.forEach (id) ->
      self.removeCartItem(id)

  removeCartItem: (id) ->
    cartItem = @findCartItemById(id)
    @get('cart_items').removeObject(cartItem)
    cartItem.deleteRecord() if cartItem?

    cartItem

  increaseCartItem: (id) ->
    cartItem = @findCartItemById(id)
    cartItem.increase()

    cartItem

  decreaseCartItem: (id) ->
    cartItem = @findCartItemById(id)
    cartItem.decrease()

    cartItem

  # TODO Rename to findAllCartItemsInGroup()
  findCartItemsByGroup: (group) ->
    @get('cart_items').filter (item) ->
      return true if item.get('group') == group

  # @private
  findCartItemById: (id) ->
    @get('cart_items').filterProperty('id', id)[0]

  # @private
  findCartItemByCartable: (cartableId, cartableType) ->
    @get('cart_items').filter((item) ->
      return true if item.get('cartable_id') == cartableId && item.get('cartable_type') == cartableType
    ).get('firstObject')

RightnowOms.Cart.reopenClass
  isSingleton: true
