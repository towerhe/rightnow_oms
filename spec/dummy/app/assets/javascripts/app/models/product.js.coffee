App.Product = DS.Model.extend
  name: DS.attr('string')
  price: DS.attr('string')
  hasChildren: DS.attr('boolean')

App.Product.reopenClass
  collectionUrl: '/products'
  resourceUrl: '/products/@%'
  resourceName: 'product'
