RightnowOms.cartController = Ember.Object.create
  load: (cart) ->
    RightnowOms.store.load(RightnowOms.Cart, cart.id, cart)
    this.set('content', RightnowOms.store.find(RightnowOms.Cart, cart.id))

  reload: ->
    this.set('content', RightnowOms.store.find(RightnowOms.Cart, this.get('content').get('id')))

  addCartItem: (item) ->
    this.get('content').addCartItem(item)

  removeCartItem: (item) ->
    item.deleteRecord()
    RightnowOms.store.commit()
