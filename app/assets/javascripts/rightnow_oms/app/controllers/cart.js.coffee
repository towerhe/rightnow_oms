RightnowOms.cartController = Ember.Object.create
  store: RightnowOms.store

  load: (cart) ->
    RightnowOms.store.load(RightnowOms.Cart, cart.id, cart)
    @set('content', RightnowOms.store.find(RightnowOms.Cart, cart.id))

  reload: ->
    @set('content', RightnowOms.store.find(RightnowOms.Cart, @get('content').get('id')))

  # item: a hash
  addCartItem: (item) ->
    cartItem = @get('content').addCartItem(item)
    @store.commit()

    cartItem

  increaseCartItem: (id) ->
    @get('content').increaseCartItem(id)
    @store.commit()

  decreaseCartItem: (id) ->
    @get('content').decreaseCartItem(id)
    @store.commit()

  removeCartItem: (id) ->
    @get('content').removeCartItem(id)
    @store.commit()
