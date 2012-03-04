zh_CNKeys = Ember.keys(RightnowOms.config.get('locales.zh_CN'))
en = RightnowOms.config.get 'locales.en'

module 'En locale'

test 'it has all the translations defined in zh_CN', ->
  expect zh_CNKeys.get('length')

  zh_CNKeys.forEach (key) ->
    equal en[key]?, true, 'key %@ found'.fmt key
