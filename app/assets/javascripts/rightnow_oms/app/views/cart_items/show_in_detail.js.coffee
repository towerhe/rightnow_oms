RightnowOms.ShowCartItemInDetailView = Ember.View.extend
  tagName: 'tr'
  templateName: 'rightnow_oms/app/templates/cart_items/show_in_detail'

  deleteRecord: ->
    item = @get('cartItem')
    RightnowOms.cartController.removeCartItem(item.get('id'))

  increase: ->
    item = @get('cartItem')
    RightnowOms.cartController.increaseCartItem(item.get('id'))

  decrease: ->
    item = @get('cartItem')
    RightnowOms.cartController.decreaseCartItem(item.get('id'))
