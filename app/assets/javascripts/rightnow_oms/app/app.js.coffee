window.RightnowOms = Ember.Application.create
  rootElement: '#rightnow-oms'
  commit: (force = false)->
    window.RightnowOms.store.commit() if window.RightnowOms.config.autoCommit || force

window.RightnowOms.store = DS.Store.create
  adapter:
    DS.MyRESTAdapter.create
      bulkCommit: false
      namespace: 'rightnow_oms'

window.RightnowOms.config = Em.Object.create({
  autoCommit: true
})
