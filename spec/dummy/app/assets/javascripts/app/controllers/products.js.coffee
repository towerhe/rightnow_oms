App.productsController = Ember.ArrayController.create
  loadAll: (products) ->
    @set('content', App.store.loadAll(App.Product, products))

  findAll: ->
    @set('content', App.store.findAll(App.Product))
