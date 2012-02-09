App.ShowProductView = Ember.View.extend
  tagName: 'li',
  templateName: 'app/templates/products/show',

  submit: (e) ->
    e.preventDefault()

    product = @get('product')
    cartItem = RightnowOms.cartController.addCartItem
      'cartable_id': product.get('id')
      'cartable_type': 'Product'
      'name': product.get('name')
      'price': product.get('price')
      'group': product.get('group')
      'quantity': 1

    self = @
    if cartItem.get('id')
      @addChildren(product.children, cartItem)
    else
      cartItem.addObserver('isDirty', ->
        self.addChildren(product.children, cartItem) unless cartItem.get('isDirty')
      )

  addChildren: (children, parent) ->
    children.forEach((child) ->
      RightnowOms.cartController.addCartItem
        'cartable_id': child.id
        'cartable_type': 'Product'
        'name': child.name
        'price': child.price
        'group': child.group
        'quantity': 1
        'parent_id': parent.get('id')
    )


