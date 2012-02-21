window.RightnowOms = Ember.Application.create
  rootElement: '#rightnow-oms'
  commit: (force = false)->
    clearTimeout(@_commitTimer) if @_commitTimer

    @_commitTimer = setTimeout((->
      window.RightnowOms.store.commit() if window.RightnowOms.config.get('autoCommit') || force
    ), 500)

  _commitTimer: null

window.RightnowOms.store = DS.Store.create
  adapter:
    DS.MyRESTAdapter.create
      bulkCommit: false
      namespace: 'rightnow_oms'

window.RightnowOms.config = Em.Object.create()
window.RightnowOms.config.set('autoCommit', true)
