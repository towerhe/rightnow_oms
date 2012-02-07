RightnowOms.CartItem = DS.Model.extend
  cartableId: DS.attr('integer')
  cartableType: DS.attr('string')
  name: DS.attr('string')
  price: DS.attr('string')
  quantity: DS.attr('integer')

  subtotal: (->
    round(round(@get('price'), 2) * @get('quantity'), 2)
  ).property('price', 'quantity')

  increase: ->
    @set('quantity', @get('quantity') + 1)

  decrease: ->
    @set('quantity', @get('quantity') - 1)

RightnowOms.CartItem.reopenClass
  all: ->
    RightnowOms.store.findAll(RightnowOms.CartItem)

  findByName: (name) ->
    @all().filterProperty('name', name).get('firstObject')

  findById: (id) ->
    @all().filterProperty('id', id).get('firstObject')
