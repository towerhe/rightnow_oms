RightnowOms.cartController = Ember.Object.create
  store: RightnowOms.store

  load: (cart) ->
    RightnowOms.store.load(RightnowOms.Cart, cart.id, cart)
    @set('content', RightnowOms.store.find(RightnowOms.Cart, cart.id))

  reload: ->
    @set('content', RightnowOms.store.find(RightnowOms.Cart, @get('content').get('id')))

  # item: a hash
  addCartItem: (item, callback) ->
    cartItem = @get('content').addCartItem(item)
    @store.commit()

    return unless callback

    return callback.call(@, cartItem) if cartItem.get('id')

    self = @
    cartItem.addObserver('isDirty', ->
      if (!cartItem.get('isDirty')) && (!cartItem.get('isDeleted'))
        callback.call(self, cartItem)
    )

  updateCartItem: (id, properties) ->
    @get('content').updateCartItem(id, properties)
    @store.commit()

  increaseCartItem: (id) ->
    @get('content').increaseCartItem(id)
    @store.commit()

  decreaseCartItem: (id) ->
    cartItem = RightnowOms.CartItem.findById(id)

    if cartItem.get('isDecreasable')
      @get('content').decreaseCartItem(id)
      @store.commit()
    else
      @removeCartItem(id)

  removeCartItem: (id, silent) ->
    remove = true
    remove = confirm('您确定要删除该商品吗？') unless silent

    if remove
      @get('content').removeCartItem(id)
      @store.commit()

  cleanUp: ->
    if confirm('您确定要清空您的购物车吗？')
      @get('content').cleanUp()
      @store.commit()

  findCartItemsByGroup: (group) ->
    @get('content').findCartItemsByGroup(group)
