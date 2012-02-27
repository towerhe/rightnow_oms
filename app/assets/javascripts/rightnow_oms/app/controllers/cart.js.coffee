RightnowOms.cartController = Ember.Object.create
  store: RightnowOms.store

  #find: (id) ->
    #cart = @store.find(RightnowOms.Cart, id)
    #@set('content', cart)

  load: (cart) ->
    RightnowOms.store.load(RightnowOms.Cart, cart.id, cart)
    @set('content', RightnowOms.store.find(RightnowOms.Cart, cart.id))

  reload: ->
    @set('content', RightnowOms.store.find(RightnowOms.Cart, @get('content').get('id')))

  # item: a hash
  addCartItem: (item) ->
    cartItem = @get('content').addCartItem(item)
    RightnowOms.commit()
  
  # @id: id of the cart item to be updated
  # @properties: a hash which is the new properties of the cart item.
  # 
  # For example:
  #
  # RightnowOms.cartController.updateCartItem(1, {
  #   'price': 10.00,
  #   'quantity': 2
  # })
  updateCartItem: (id, properties) ->
    if @get('content').findCartItemById(id).isProcessing()
      alert('正在保存购物车，请稍后。。。')
      return

    @get('content').updateCartItem(id, properties)
    RightnowOms.commit()

  increaseCartItem: (id) ->
    if @get('content').findCartItemById(id).isProcessing()
      alert('正在保存购物车，请稍后。。。')
      return

    cartItem = @get('content').increaseCartItem(id)
    RightnowOms.commit(true)

  decreaseCartItem: (id) ->
    cartItem = @get('content').findCartItemById(id)

    if cartItem.isProcessing()
      alert('正在保存购物车，请稍后。。。')
      return

    if cartItem.get('isDecreasable')
      @get('content').decreaseCartItem(id)
      RightnowOms.commit(true)
    else
      @removeCartItem(id)

  removeCartItem: (id, silent) ->
    remove = true
    remove = confirm('您确定要删除该商品吗？') unless silent

    if remove
      @get('content').removeCartItem(id)
      RightnowOms.commit(true)

  cleanUp: ->
    if confirm('您确定要清空您的购物车吗？')
      @get('content').cleanUp()
      RightnowOms.commit(true)

  # return: an array of cart items.
  #
  # For example:
  #
  # RightnowOms.cartController.findCartItemsByGroup('booking');
  #
  # =>
  #   [{
  #     'id': 1, 'cartable_id': 2, 'cartable_type': 'Product', 'name': 'product-1', 'original_price', 10.0, 'base_quantity': 1, 'price': 10.0, 'group': 'booking', 'parent_id': null
  #   }, {
  #     'id': 2, 'cartable_id': 3, 'cartable_type': 'Product', 'name': 'product-2', 'original_price', 20.0, 'base_quantity': 1,  'price': 20.0, 'group': 'booking', 'parent_id': 2
  #   }]
  findCartItemsByGroup: (group) ->
    found = []
    cartItems = @get('content').findCartItemsByGroup(group)

    cartItems.forEach (item) ->
      found.push(item.getProperties('id', 'cartable_id', 'cartable_type', 'name', 'original_price', 'base_quantity', 'price', 'quantity', 'group', 'parent_id'))

    found
