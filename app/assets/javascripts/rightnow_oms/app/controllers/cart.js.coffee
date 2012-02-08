RightnowOms.cartController = Ember.Object.create
  load: (cart) ->
    RightnowOms.store.load(RightnowOms.Cart, cart.id, cart)
    @set('content', RightnowOms.store.find(RightnowOms.Cart, cart.id))

  reload: ->
    @set('content', RightnowOms.store.find(RightnowOms.Cart, @get('content').get('id')))

  # item: a hash
  addCartItem: (item) ->
    @get('content').addCartItem(item)

  increaseCartItem: (id) ->
    @get('content').increaseCartItem(id)

  decreaseCartItem: (id) ->
    @get('content').decreaseCartItem(id)

  removeCartItem: (id) ->
    @get('content').removeCartItem(id)
