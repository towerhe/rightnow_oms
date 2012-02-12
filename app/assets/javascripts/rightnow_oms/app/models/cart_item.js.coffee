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

  isDecreasable: (->
    @get('quantity') > 1
  ).property('quantity')

  increase: ->
    @get('children').forEach((child) ->
      child.increase()
    )

    @set('quantity', @get('quantity') + 1)

  decrease: ->
    @get('children').forEach((child) ->
      child.decrease()
    )

    @set('quantity', @get('quantity') - 1)

  deleteRecord: ->
    @get('children').forEach((child) ->
      child.deleteRecord()
    )

    @_super()

RightnowOms.CartItem.reopenClass
  all: ->
    RightnowOms.store.findAll(RightnowOms.CartItem)

  findById: (id) ->
    @all().filterProperty('id', id).get('firstObject')

  findByName: (name) ->
    @all().filterProperty('name', name).get('firstObject')

  findByCartableAndParentId: (cartableId, cartableType, parentId) ->
    @all().filter((item) ->
      if item.get('cartable_id') == cartableId && item.get('cartable_type') == cartableType
        if parentId?
          return true if item.get('parent_id') == parentId
        else
          return true
    ).get('firstObject')
