window.RightnowOms = Ember.Application.create
  rootElement: '#rightnow-oms'
  commit: (force = false)->
    clearTimeout(@_commitTimer) if @_commitTimer

    @_commitTimer = setTimeout((->
      window.RightnowOms.store.commit() if window.RightnowOms.config.get('autoCommit') || force
    ), 500)

  _commitTimer: null

  configure: (reconfigure) ->
    RightnowOms.config = Em.Object.create locales: {} unless RightnowOms.config?

    reconfigure(RightnowOms.config) if reconfigure

RightnowOms.store = DS.Store.create
  revision: 2
  adapter:
    DS.MyRESTAdapter.create
      bulkCommit: false
      namespace: 'rightnow_oms'
