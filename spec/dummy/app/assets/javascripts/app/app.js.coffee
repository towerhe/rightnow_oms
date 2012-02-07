window.App = Ember.Application.create
  rootElement: "#products"

window.App.store = DS.Store.create
  adapter:
    DS.RESTAdapter.create
      bulkCommit: false
