App.productsController = Ember.ArrayController.create
  loadAll: (products) ->
    this.set('content', App.store.loadAll(App.Product, products))

  findAll: ->
    this.set('content', App.store.findAll(App.Product))
