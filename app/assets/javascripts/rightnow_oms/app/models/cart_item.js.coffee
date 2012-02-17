RightnowOms.CartItem = DS.Model.extend
  cartable_id: DS.attr('integer')
  cartable_type: DS.attr('string')
  name: DS.attr('string')
  original_price: DS.attr('string')
  base_quantity: DS.attr('integer')
  price: DS.attr('money')
  quantity: DS.attr('integer')
  group: DS.attr('string')
  parent_id: DS.attr('integer')
  mergable: DS.attr('boolean')

  priceString: (->
    round(@get('price'), 2)
  ).property('price')

  subtotal: (->
    @get('price') * @get('quantity')
  ).property('price', 'quantity')

  subtotalString: (->
    round(@get('subtotal'), 2)
  ).property('subtotal')

  children: (->
    RightnowOms.CartItem.findByParentId(@get('id'))
  ).property().cacheable()

  parent: (->
    if @get('parent_id')?
      RightnowOms.CartItem.all().filterProperty('id', @get('parent_id'))
  ).property('parent_id')

  hasChildren: (->
    @set('children', RightnowOms.CartItem.findByParentId(@get('id')))
    @get('children') && @getPath('children.length') > 0
  ).property()

  hasParent: (->
    @get('parent_id')?
  ).property('parent_id')

  isDecreasable: (->
    @get('quantity') > 1
  ).property('quantity')

  increase: ->
    if @get('hasChildren')
      @get('children').forEach((child) ->
        child.increase()
      )

    @set('quantity', @get('quantity') + @get('base_quantity'))

  decrease: ->
    if @get('hasChildren')
      @get('children').forEach((child) ->
        child.decrease()
      )

    @set('quantity', @get('quantity') - @get('base_quantity'))

  deleteRecord: ->
    if @get('hasChildren')
      @get('children').forEach((child) ->
        child.deleteRecord()
      )

    @_super()

RightnowOms.CartItem.reopenClass
  all: ->
    RightnowOms.store.findAll(RightnowOms.CartItem)

  findById: (id) ->
    @all().filterProperty('id', id).get('firstObject')

  findByParentId: (parentId) ->
    @all().filterProperty('parent_id', parentId)

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
