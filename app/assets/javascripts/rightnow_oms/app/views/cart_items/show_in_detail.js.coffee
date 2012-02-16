RightnowOms.ShowCartItemInDetailView = RightnowOms.ShowCartItemView.extend
  templateName: 'rightnow_oms/app/templates/cart_items/show_in_detail'

  increase: ->
    item = @get('cartItem')
    RightnowOms.cartController.increaseCartItem(item.get('id'))

  decrease: ->
    item = @get('cartItem')
    RightnowOms.cartController.decreaseCartItem(item.get('id'))
