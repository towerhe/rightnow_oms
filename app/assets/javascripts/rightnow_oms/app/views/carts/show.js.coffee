RightnowOms.ShowCartView = Ember.View.extend
  classNames: ['r-mini-cart']
  templateName: 'rightnow_oms/app/templates/carts/show'

  cartBinding: 'RightnowOms.cartController.content'

  mouseLeave: (e) ->
    $('.r-cart-items').hide()
