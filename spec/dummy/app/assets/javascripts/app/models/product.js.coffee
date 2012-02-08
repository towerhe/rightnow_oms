App.Product = DS.Model.extend
  name: DS.attr('string')
  price: DS.attr('string')

  hasChildren: (->
    @get("children").length > 0
  ).property("children")

  hasAncestry: (->
    @get("ancestry")?
  ).property("ancestry")
