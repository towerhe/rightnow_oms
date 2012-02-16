RightnowOms.ShowCartItemView = Ember.View.extend
  tagName: 'table'
  templateName: 'rightnow_oms/app/templates/cart_items/show'

  toggleChildren: ->
    hidden = @get('isChildrenHidden')
    @set('isChildrenHidden', !hidden)

  deleteRecord: ->
    item = this.get('cartItem')
    RightnowOms.cartController.removeCartItem(item.get('id'), true)
