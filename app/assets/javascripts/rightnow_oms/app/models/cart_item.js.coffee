RightnowOms.CartItem = DS.Model.extend
  cartable_id: DS.attr('integer')
  cartable_type: DS.attr('string')
  name: DS.attr('string')
  price: DS.attr('string')
  quantity: DS.attr('integer')
  group: DS.attr('string')
  parent_id: DS.attr('integer')

  subtotal: (->
    round(round(@get('price'), 2) * @get('quantity'), 2)
  ).property('price', 'quantity')

  children: (->
    RightnowOms.CartItem.all().filterProperty('parent_id', @get('id'))
  ).property()

  parent: (->
    if @get('parent_id')?
      RightnowOms.CartItem.all().filterProperty('id', @get('parent_id'))
  ).property()

  hasChildren: (->
    @get('children.length') > 0
  ).property()

  hasParent: (->
    @get('parent_id')?
  ).property('parent_id')

  increase: ->
    @set('quantity', @get('quantity') + 1)

  decrease: ->
    @set('quantity', @get('quantity') - 1)

  deleteRecord: ->
    @get('children').forEach((child) ->
      child.deleteRecord()
    )

    @_super()
    RightnowOms.store.commit()

  # FIXME
  #
  # This will cause duplicated commit when creating new record and changing
  # the quantity of a combo product
  quantityChanged: (->
    quantity = @get('quantity')
    children = RightnowOms.CartItem.all().filterProperty('parent_id', @get('id'))

    children.forEach((child) ->
      child.set('quantity', quantity) unless child.get('child') == quantity
    )

    RightnowOms.store.commit() if @get('quantity') > 0 && @get('cartable_id')
  ).observes('quantity')

RightnowOms.CartItem.reopenClass
  all: ->
    RightnowOms.store.findAll(RightnowOms.CartItem)

  findByName: (name) ->
    @all().filterProperty('name', name).get('firstObject')

  findById: (id) ->
    @all().filterProperty('id', id).get('firstObject')
