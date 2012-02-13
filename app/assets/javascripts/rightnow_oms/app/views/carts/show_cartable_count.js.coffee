RightnowOms.ShowCartableCountView = Ember.View.extend
  classNames: ['r-cart-cartable-count']
  templateName: 'rightnow_oms/app/templates/carts/show_cartable_count'

  mouseEnter: (e) ->
    $('.r-cart-items').show()
