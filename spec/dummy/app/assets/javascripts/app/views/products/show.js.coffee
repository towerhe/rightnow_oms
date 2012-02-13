App.ShowProductView = Ember.View.extend
  tagName: 'li',
  templateName: 'app/templates/products/show',

  submit: (e) ->
    e.preventDefault()

    product = @get('product')
    cartItem = RightnowOms.cartController.addCartItem
      'cartable_id': product.get('id')
      'cartable_type': 'Product'
      'group': product.get('group')

    self = @
    if cartItem.get('id')
      @addChildren(product.children, cartItem)
    else
      cartItem.addObserver('isDirty', ->
        unless cartItem.get('isDirty')
          self.addChildren(product.children, cartItem) unless cartItem.get('isDeleted')
      )

  addChildren: (children, parent) ->
    children.forEach((child) ->
      RightnowOms.cartController.addCartItem
        'cartable_id': child.id
        'cartable_type': 'Product'
        'parent_id': parent.get('id')
        'group': child.group
    )


