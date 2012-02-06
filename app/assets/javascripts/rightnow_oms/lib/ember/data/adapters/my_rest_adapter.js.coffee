get = Ember.get
set = Ember.set
getPath = Ember.getPath

DS.MyRESTAdapter = DS.RESTAdapter.extend
  createRecord: (store, type, model) ->
    root = this.rootForType(type)
    url = this.buildUrl(type)
    data = {}

    data[root] = get(model, 'data')

    this.ajax(url, "POST", {
      data: data,
      success: (json) ->
        store.didCreateRecord(model, json[root])
    })

  createRecords: (store, type, models) ->
    if (get(this, 'bulkCommit') == false)
      return this._super(store, type, models)

    root = this.rootForType(type)
    plural = this.pluralize(root)

    data = {}
    data[plural] = models.map((model) ->
      get(model, 'data')

    )
    this.ajax(this.buildUrl(type), "POST", {
      data: data,
      success: (json) ->
        store.didCreateRecords(type, models, json[plural])
    })

  updateRecord: (store, type, model) ->
    root = this.rootForType(type)

    data = {}
    data[root] = get(model, 'data')

    this.ajax(this.buildUrl(type, this.getPrimaryKeyValue(type, model)), "PUT", {
      data: data,
      success: (json) ->
        store.didUpdateRecord(model, json[root])
    })

  updateRecords: (store, type, models) ->
    if (get(this, 'bulkCommit') == false)
      return this._super(store, type, models)

    root = this.rootForType(type)
    plural = this.pluralize(root)

    data = {}
    data[plural] = models.map((model) ->
      get(model, 'data')
    )

    this.ajax(this.buildUrl(type), "POST", {
      data: data,
      success: (json) ->
        store.didUpdateRecords(models, json[plural])
    })

  deleteRecord: (store, type, model) ->
    root = this.rootForType(type)
    url = this.buildUrl(type, this.getPrimaryKeyValue(type, model))

    this.ajax(url, "DELETE", {
      success: (json) ->
        store.didDeleteRecord(model)
    })

  # Do not support batch deleting
  deleteRecords: (store, type, models) ->
    
  find: (store, type, id) ->
    url = ''
    root = this.rootForType(type)

    if this.isSingleton(type)
      url = this.buildUrl(type)
    else
      url = this.buildUrl(type, id)

    this.ajax(url, "GET", {
      success: (json) ->
        store.load(type, json[root])
    })

  findMany: (store, type, ids) ->
    root = this.rootForType(type)
    plural = this.pluralize(root)

    this.ajax(this.buildUrl(type), "GET", {
      data: { ids: ids },
      success: (json) ->
        store.loadMany(type, ids, json[plural])
    })
    url = "/" + plural

  findAll: (store, type) ->
    root = this.rootForType(type)
    plural = this.pluralize(root)

    this.ajax(this.buildUrl(type), "GET", {
      success: (json) ->
        store.loadMany(type, json[plural])
    })

  findQuery: (store, type, query, modelArray) ->
    root = this.rootForType(type)
    plural = this.pluralize(root)

    this.ajax(this.buildUrl(type), "GET", {
      data: query,
      success: (json) ->
        modelArray.load(json[plural])
    })

  # HELPERS

  plurals: {}

  # define a plurals hash in your subclass to define
  # special-case pluralization
  pluralize: (name) ->
    this.plurals[name] || name + "s"

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
    root = this.rootForType(type)

    url.push(this.namespace) if this.namespace?
    if this.isSingleton(type)
      url.push(root)
    else
      url.push(this.pluralize(root))
    url.push(suffix) if suffix?

    url.join('/')

  isSingleton: (type) ->
    if type.isSingleton then type.isSingleton else false

  ajax: (url, type, hash) ->
    hash.url = url
    hash.type = type
    hash.dataType = "json"

    jQuery.ajax(hash)

