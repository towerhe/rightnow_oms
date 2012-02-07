window.RightnowOms = Ember.Application.create
  rootElement: '#cart-wrapper'

window.RightnowOms.store = DS.Store.create
  adapter:
    DS.MyRESTAdapter.create
      bulkCommit: false
      namespace: 'rightnow_oms'
