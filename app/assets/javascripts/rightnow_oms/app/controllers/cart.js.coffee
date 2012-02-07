RightnowOms.cartController = Ember.Object.create
  load: (cart) ->
    RightnowOms.store.load(RightnowOms.Cart, cart.id, cart)
    @set('content', RightnowOms.store.find(RightnowOms.Cart, cart.id))

  reload: ->
    @set('content', RightnowOms.store.find(RightnowOms.Cart, @get('content').get('id')))

  # item: a hash
  addCartItem: (item) ->
    @get('content').addCartItem(item)

  plusCartItem: (id) ->
    @get('content').plusCartItem(id)

  minusCartItem: (id) ->
    @get('content').minusCartItem(id)

  removeCartItem: (id) ->
    @get('content').removeCartItem(id)
