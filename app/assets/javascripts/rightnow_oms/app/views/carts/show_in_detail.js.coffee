RightnowOms.ShowCartInDetailView = Ember.View.extend
  templateName: 'rightnow_oms/app/templates/carts/show_in_detail'

  cartBinding: 'RightnowOms.cartController.content'

  cleanUp: ->
    RightnowOms.cartController.cleanUp()
