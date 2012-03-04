RightnowOms.ShowCartItemInDetailView = RightnowOms.ShowCartItemView.extend
  templateName: 'rightnow_oms/app/templates/cart_items/show_in_detail'

  increase: ->
    item = @get('cartItem')
    RightnowOms.cartController.increaseCartItem(item.get('id'))

  decrease: ->
    item = @get('cartItem')
    RightnowOms.cartController.decreaseCartItem(item.get('id'))

  deleteRecord: ->
    item = this.get('cartItem')
    RightnowOms.cartController.removeCartItem(item.get('id'))

  mouseEnter: (e) ->
    $(e.target).parents('.r-cart-items').find('dt').css('background', 'white')
    $(e.target).parents('dt').css('background','#EEE')

  mouseLeave: (e) ->
    $(e.target).parents('.r-cart-items').find('dt').css('background', 'white')
