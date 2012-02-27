RightnowOms.CartItem = DS.Model.extend
  cartable_id: DS.attr('integer')
  cartable_type: DS.attr('string')
  name: DS.attr('string')
  original_price: DS.attr('string')
  base_quantity: DS.attr('integer')
  price: DS.attr('money')
  quantity: DS.attr('integer')
  group: DS.attr('string')
  mergable: DS.attr('boolean')
  parent_id: DS.attr('integer')
  cart: DS.belongsTo('RightnowOms.Cart')
  parent: DS.belongsTo('RightnowOms.CartItem', { key: 'parent_id' })
  children: DS.hasMany('RightnowOms.CartItem', { embedded: true })

  priceString: Ember.computed(->
    round(@get('price'), 2)
  ).property('price')

  subtotal: Ember.computed(->
    @get('price') * @get('quantity')
  ).property('price', 'quantity')

  subtotalString: Ember.computed(->
    round(@get('subtotal'), 2)
  ).property('subtotal')

  hasChildren: Ember.computed(->
    @get('children')? && @getPath('children.length') > 0
  ).property('children')

  hasParent: Ember.computed(->
    @get('parent')?
  ).property('parent')

  addChild: (child) ->
    child.parent_id = @get('id')
    childItem = RightnowOms.CartItem.createRecord(child)
    @get('children').pushObject(childItem)

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
    # If having children, remove the children from the local store.
    # No use to delete the children explicitly since it will be remove
    # automatically on remote.
    if @get('hasChildren')
      @get('children').forEach(@get('children').removeObject, @get('children'))

    @_super()

  isProcessing: ->
    @get('isSaving') || @get('children').someProperty('isSaving', true)

#RightnowOms.CartItem.reopenClass
  #all: ->
    #RightnowOms.store.findAll(RightnowOms.CartItem)

  #findById: (id) ->
    #@all().filterProperty('id', id)[0]

  #findByName: (name) ->
    #@all().filterProperty('name', name)[0]

  #findByCartableAndParentId: (cartableId, cartableType, parentId) ->
    #Ember.get(@all().filter((item) ->
      #if item.get('cartable_id') == cartableId && item.get('cartable_type') == cartableType
        #if parentId?
          #return true if item.getPath('parent.id') == parentId
        #else
          #return true
    #), 'firstObject')
