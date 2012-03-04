App.Product = DS.Model.extend
  name: DS.attr('string')
  price: DS.attr('string')

  hasChildren: Ember.computed(->
    @get("children").length > 0
  ).property("children")

  hasAncestry: Ember.computed(->
    @get("ancestry")?
  ).property("ancestry")
