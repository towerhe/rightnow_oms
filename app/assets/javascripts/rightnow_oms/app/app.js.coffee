window.RightnowOms = Ember.Application.create
  rootElement: '#rightnow-oms'
  commit: (force = false)->
    clearTimeout(@_commitTimer) if @_commitTimer

    @_commitTimer = setTimeout((->
      window.RightnowOms.store.commit() if window.RightnowOms.config.get('autoCommit') || force
    ), 500)

  _commitTimer: null

  config: Em.Object.create()

  configure: (reconfigure) ->
    reconfigure(RightnowOms.config) if reconfigure
    
    defaultLocale = RightnowOms.config.get('defaultLocale') || 'en'
    locale = 'locales.' + defaultLocale
    Em.I18n.translations = RightnowOms.config.get(locale)


RightnowOms.store = DS.Store.create
  revision: 2
  adapter:
    DS.MyRESTAdapter.create
      bulkCommit: false
      namespace: 'rightnow_oms'
