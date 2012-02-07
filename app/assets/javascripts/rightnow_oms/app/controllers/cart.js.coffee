RightnowOms.cartController = Ember.Object.create
  load: (cart) ->
    RightnowOms.store.load(RightnowOms.Cart, cart.id, cart)
    @set('content', RightnowOms.store.find(RightnowOms.Cart, cart.id))

  reload: ->
    @set('content', RightnowOms.store.find(RightnowOms.Cart, @get('content').get('id')))

  addCartItem: (item) ->
    @get('content').addCartItem(item)

  removeCartItem: (item) ->
    item.deleteRecord()
    RightnowOms.store.commit()
