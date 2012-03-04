enKeys = Ember.keys(RightnowOms.config.get('locales.en'))
zh_CN = RightnowOms.config.get 'locales.zh_CN'

module 'zh_CN locale'

test 'it has all the translations defined in en', ->
  expect enKeys.get('length')

  enKeys.forEach (key) ->
    equal zh_CN[key]?, true, 'key %@ found'.fmt key
