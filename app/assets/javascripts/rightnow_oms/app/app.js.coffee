window.RightnowOms = Ember.Application.create
  rootElement: '#rightnow-oms'

window.RightnowOms.store = DS.Store.create
  adapter:
    DS.MyRESTAdapter.create
      bulkCommit: false
      namespace: 'rightnow_oms'

window.RightnowOms.config = Em.Object.create()
