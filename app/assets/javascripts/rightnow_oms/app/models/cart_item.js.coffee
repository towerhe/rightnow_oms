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

  priceString: Ember.computed(->
    round(@get('price'), 2)
  ).property('price')

  subtotal: Ember.computed(->
    @get('price') * @get('quantity')
  ).property('price', 'quantity')

  subtotalString: Ember.computed(->
    round(@get('subtotal'), 2)
  ).property('subtotal')

  children: Ember.computed(->
    RightnowOms.CartItem.findByParentId(@get('id'))
  ).property().cacheable()

  parent: Ember.computed(->
    if @get('parent_id')?
      RightnowOms.CartItem.all().filterProperty('id', @get('parent_id'))
  ).property('parent_id')

  hasChildren: Ember.computed(->
    @set('children', RightnowOms.CartItem.findByParentId(@get('id')))
    @get('children') && @getPath('children.length') > 0
  ).property()

  hasParent: Ember.computed(->
    @get('parent_id')?
  ).property('parent_id')

  isDecreasable: Ember.computed(->
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

  isProcessing: ->
    @get('isSaving') || @get('children').someProperty('isSaving', true)

RightnowOms.CartItem.reopenClass
  all: ->
    RightnowOms.store.findAll(RightnowOms.CartItem)

  findById: (id) ->
    @all().filterProperty('id', id)[0]

  findByParentId: (parentId) ->
    result = Ember.ArrayProxy.create({ content: Ember.A() })

    @all().filterProperty('parent_id', parentId).forEach (item) ->
      result.pushObject(item)

    result


  findByName: (name) ->
    @all().filterProperty('name', name)[0]

  findByCartableAndParentId: (cartableId, cartableType, parentId) ->
    Ember.get(@all().filter((item) ->
      if item.get('cartable_id') == cartableId && item.get('cartable_type') == cartableType
        if parentId?
          return true if item.get('parent_id') == parentId
        else
          return true
    ), 'firstObject')
