window.RightnowOms = Ember.Application.create
  rootElement: '#cart'

window.RightnowOms.store = DS.Store.create
  adapter:
    DS.MyRESTAdapter.create
      bulkCommit: false
      namespace: 'rightnow_oms'
