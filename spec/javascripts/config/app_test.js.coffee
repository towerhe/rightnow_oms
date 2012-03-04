module 'RightnowOms App'

test 'it overrides the default configurations', ->
  expect 2

  RightnowOms.configure (config) ->
    config.set('autoCommit', false)
    config.set('defaultLocale', 'zh_CN')

  equal RightnowOms.config.get('autoCommit'), false, 'set autoCommit to false'
  equal RightnowOms.config.get('defaultLocale'), 'zh_CN', 'set default locale to zh_CN'
