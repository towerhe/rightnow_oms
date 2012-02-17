RightnowOms.ShowCartInDetailView = Ember.View.extend
  templateName: 'rightnow_oms/app/templates/carts/show_in_detail'

  cartBinding: 'RightnowOms.cartController.content'
  newOrderUrlBinding: 'RightnowOms.config.newOrderUrl'

  cleanUp: ->
    RightnowOms.cartController.cleanUp()
