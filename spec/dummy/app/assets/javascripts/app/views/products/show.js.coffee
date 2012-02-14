App.ShowProductView = Ember.View.extend
  tagName: 'li',
  templateName: 'app/templates/products/show',

  submit: (e) ->
    e.preventDefault()

    self = @
    product = @get('product')
    RightnowOms.cartController.addCartItem({
      'cartable_id': product.get('id')
      'cartable_type': 'Product'
      'price': product.get('price')
      'group': product.get('group')
    }, (cartItem) ->
      self.addChildren(product.children, cartItem)
    )

  addChildren: (children, parent) ->
    children.forEach((child) ->
      RightnowOms.cartController.addCartItem
        'cartable_id': child.id
        'cartable_type': 'Product'
        'price': child.price
        'parent_id': parent.get('id')
        'group': child.group
    )


