RightnowOms.ShowCartItemView = Ember.View.extend
  tagName: 'tr'
  templateName: 'rightnow_oms/app/templates/cart_items/show'

  deleteRecord: ->
    item = this.get('cartItem')
    RightnowOms.cartController.removeCartItem(item.get('id'))
