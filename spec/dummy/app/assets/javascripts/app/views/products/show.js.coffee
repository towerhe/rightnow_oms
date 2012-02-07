App.ShowProductView = Ember.View.extend
  tagName: 'li',
  templateName: 'app/templates/products/show',

  submit: (e) ->
    e.preventDefault()

    self = this
    product = @get('product')

    RightnowOms.cartController.addCartItem
      'cartable_id': product.get('id')
      'cartable_type': 'Product'
      'name': product.get('name')
      'price': product.get('price')
      'quantity': 1

