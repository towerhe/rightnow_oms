get = Ember.get
set = Ember.set
getPath = Ember.getPath

DS.MyRESTAdapter = DS.RESTAdapter.extend
  createRecord: (store, type, model) ->
    root = @rootForType(type)
    url = @buildUrl(type)
    data = {}

    data[root] = model.toJSON()

    @ajax(url, "POST", {
      data: data,
      success: (json) ->
        @sideload(store, type, json, root)
        store.didCreateRecord(model, json[root])
    })

  updateRecord: (store, type, model) ->
    root = @rootForType(type)

    data = {}
    data[root] = model.toJSON()

    @ajax(@buildUrl(type, @getPrimaryKeyValue(type, model)), "PUT", {
      data: data,
      success: (json) ->
        @sideload(store, type, json, root)
        store.didUpdateRecord(model,json[root])
    })

  deleteRecord: (store, type, model) ->
    root = @rootForType(type)
    url = @buildUrl(type, @getPrimaryKeyValue(type, model))

    @ajax(url, "DELETE", {
      success: (json) ->
        @sideload(store, type, json) if json
        store.didDeleteRecord(model)
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
        @sideload(store, type, json, root)
    })

  findMany: (store, type, ids) ->
    root = @rootForType(type)
    plural = @pluralize(root)

    @ajax(@buildUrl(type), "GET", {
      data: { ids: ids },
      success: (json) ->
        store.loadMany(type, ids, json[plural])
        @sideload(store, type, json, plural)
    })

  findAll: (store, type) ->
    root = @rootForType(type)
    plural = @pluralize(root)

    @ajax(@buildUrl(type), "GET", {
      success: (json) ->
        store.loadMany(type, json[plural])
        @sideload(store, type, json, plural)
    })

  findQuery: (store, type, query, modelArray) ->
    root = @rootForType(type)
    plural = @pluralize(root)

    @ajax(@buildUrl(type), "GET", {
      data: query,
      success: (json) ->
        modelArray.load(json[plural])
        @sideload(store, type, json, plural)
    })

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
