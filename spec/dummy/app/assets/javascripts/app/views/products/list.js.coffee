App.ListProductsView = Ember.View.extend
  tagName: 'ul'
  templateName: 'app/templates/products/list'
  productsBinding: 'App.productsController'
