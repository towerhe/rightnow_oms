RightnowOms.ShowCartItemInDetailView = Ember.View.extend
  tagName: 'tr'
  templateName: 'rightnow_oms/app/templates/cart_items/show_in_detail'

  deleteRecord: ->
    item = @get('cartItem')
    RightnowOms.cartController.removeCartItem(item.get('id'))

  plus: ->
    item = @get('cartItem')
    RightnowOms.cartController.plusCartItem(item.get('id'))

  minus: ->
    item = @get('cartItem')
    RightnowOms.cartController.minusCartItem(item.get('id'))
