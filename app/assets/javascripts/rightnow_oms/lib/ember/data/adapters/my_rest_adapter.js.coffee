get = Ember.get
set = Ember.set
getPath = Ember.getPath

DS.MyRESTAdapter = DS.RESTAdapter.extend
  createRecord: (store, type, model) ->
    root = @rootForType(type)
    url = @buildUrl(type)
    data = {}

    data[root] = get(model, 'data')

    @ajax(url, "POST", {
      data: data,
      success: (json) ->
        store.didCreateRecord(model, json[root])
    })

  createRecords: (store, type, models) ->
    if (get(@, 'bulkCommit') == false)
      return @_super(store, type, models)

    root = @rootForType(type)
    plural = @pluralize(root)

    data = {}
    data[plural] = models.map((model) ->
      get(model, 'data')

    )
    @ajax(@buildUrl(type), "POST", {
      data: data,
      success: (json) ->
        store.didCreateRecords(type, models, json[plural])
    })

  updateRecord: (store, type, model) ->
    root = @rootForType(type)

    data = {}
    data[root] = get(model, 'data')

    @ajax(@buildUrl(type, @getPrimaryKeyValue(type, model)), "PUT", {
      data: data,
      success: (json) ->
        store.didUpdateRecord(model, json[root])
    })

  updateRecords: (store, type, models) ->
    if (get(@, 'bulkCommit') == false)
      return @_super(store, type, models)

    root = @rootForType(type)
    plural = @pluralize(root)

    data = {}
    data[plural] = models.map((model) ->
      get(model, 'data')
    )

    @ajax(@buildUrl(type), "POST", {
      data: data,
      success: (json) ->
        store.didUpdateRecords(models, json[plural])
    })

  deleteRecord: (store, type, model) ->
    root = @rootForType(type)
    url = @buildUrl(type, @getPrimaryKeyValue(type, model))

    @ajax(url, "DELETE", {
      success: (json) ->
        store.didDeleteRecord(model)
    })

  deleteRecords: (store, type, models) ->
    if (get(@, 'bulkCommit') == false)
      return @_super(store, type, models)

    root = @rootType(type)
    plural = @pluralize(root)
    primaryKey = getPath(type, 'proto.primaryKey')

    data = {}
    data[plural] = models.map((model) ->
      get(model, primaryKey)
    )

    @ajax(@buildUrl(type) + "/delete", "POST", {
      data: data
      success: (json) ->
        store.didDeleteRecords(models)
    })
    
  find: (store, type, id) ->
    url = ''
    root = @rootForType(type)

    if @isSingleton(type)
      url = @buildUrl(type)
    else
      url = @buildUrl(type, id)

    @ajax(url, "GET", {
      success: (json) ->
        store.load(type, json[root])
    })

  findMany: (store, type, ids) ->
    root = @rootForType(type)
    plural = @pluralize(root)

    @ajax(@buildUrl(type), "GET", {
      data: { ids: ids },
      success: (json) ->
        store.loadMany(type, ids, json[plural])
    })
    url = "/" + plural

  findAll: (store, type) ->
    root = @rootForType(type)
    plural = @pluralize(root)

    @ajax(@buildUrl(type), "GET", {
      success: (json) ->
        store.loadMany(type, json[plural])
    })

  findQuery: (store, type, query, modelArray) ->
    root = @rootForType(type)
    plural = @pluralize(root)

    @ajax(@buildUrl(type), "GET", {
      data: query,
      success: (json) ->
        modelArray.load(json[plural])
    })

  # HELPERS

  plurals: {}

  # define a plurals hash in your subclass to define
  # special-case pluralization
  pluralize: (name) ->
    @plurals[name] || name + "s"

  rootForType: (type) ->
    if type.url
      return type.url

    # use the last part of the name as the URL
    parts = type.toString().split(".")
    name = parts[parts.length - 1]
    name.replace(/([A-Z])/g, '_$1').toLowerCase().slice(1)

  getPrimaryKeyValue: (type, model)->
    primaryKey = getPath(type, 'proto.primaryKey')
    get(model, primaryKey)

  buildUrl: (type, suffix) ->
    url = [""]
    root = @rootForType(type)

    url.push(@namespace) if @namespace?
    if @isSingleton(type)
      url.push(root)
    else
      url.push(@pluralize(root))
    url.push(suffix) if suffix?

    url.join('/')

  isSingleton: (type) ->
    if type.isSingleton then type.isSingleton else false

  ajax: (url, type, hash) ->
    hash.url = url
    hash.type = type
    hash.dataType = "json"

    jQuery.ajax(hash)

