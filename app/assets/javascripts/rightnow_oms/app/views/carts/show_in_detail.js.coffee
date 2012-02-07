RightnowOms.ShowCartInDetailView = Ember.View.extend
  classNames: ["detailed-cart"]
  templateName: 'rightnow_oms/app/templates/carts/show_in_detail'

  cartBinding: 'RightnowOms.cartController.content'
