#Ember.LOG_STATE_TRANSITIONS = true

window.App = Ember.Application.create
  rootElement: "#products"

window.App.store = DS.Store.create
  revision: 1
  adapter:
    DS.RESTAdapter.create
      bulkCommit: false
