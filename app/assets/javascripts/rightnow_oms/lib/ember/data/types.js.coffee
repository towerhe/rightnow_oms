DS.attr.transforms.money =
  from: (serialized) ->
    parseFloat(serialized) unless Em.none(serialized)

  to: (deserialized) ->
    (Math.round(deserialized * Math.pow(10, 2)) / Math.pow(10, 2)).toFixed(22) unless Em.none(deserialized)

