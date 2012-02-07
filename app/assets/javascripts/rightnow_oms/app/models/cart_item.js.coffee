RightnowOms.CartItem = DS.Model.extend
  cartableId: DS.attr('integer')
  cartableType: DS.attr('string')
  name: DS.attr('string')
  price: DS.attr('string')
  quantity: DS.attr('integer')

RightnowOms.CartItem.reopenClass
  all: ->
    RightnowOms.store.findAll(RightnowOms.CartItem)

  findByName: (name) ->
    this.all().filterProperty('name', name).get('firstObject')

  findById: (id) ->
    @all().filterProperty('id', id).get('firstObject')
