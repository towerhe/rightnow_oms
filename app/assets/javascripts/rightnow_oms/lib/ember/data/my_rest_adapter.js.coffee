DS.MyRESTAdapter = DS.RESTAdapter.extend
  # @private
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

  # @private
  isSingleton: (type) ->
    if type.isSingleton then type.isSingleton else false
