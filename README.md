# RightnowOms

## Description

A common gem for managing your carts and orders. RightnowOms is a rails mountable engine. It gets a lot of benifits from [Ember.JS](http://emberjs.com)

## Requirements

Add the following gems to your Gemfile:

```ruby
  gem 'jquery-rails'
  gem 'ember-rails'
  gem 'acts_as_api'
  gem 'haml-rails'

  group :assets do
    gem 'uglifier'
    gem 'coffee-rails'
    gem 'sass-rails'
  end
```

## Installation

Make sure that all requirements are met and add RightnowOms to your Gemfile.

```ruby
  gem 'rightnow_oms'
```

and run `bundle install`

## Usage

Mount RightnowOms to your application.

```ruby
  # config/routes.rb
  mount RightnowOms::Engine => "rightnow_oms"
```

Create the migrations with:

```bash
  rake rightnow_oms:install:migrations
  rake db:migrate
```

Run `bundle install` and require ember and ember-data in your `app/assets/javascripts/application.js`:

```
  = require rightnow_oms/vendor/ember
  = require rightnow_oms/vendor/ember-data
```

Add the following line to your `app/assets/javascripts/application.js`:

```
  = require rightnow_oms/application
```

Add the stylesheets to your `app/assets/stylesheets/application.css`:

```
  = require rightnow_oms/application
```

Create a layout for your detailed cart view like:

```haml
  # app/views/layouts/rightnow_oms/cart.html.haml
  !!!
  %html
    %head
      %title RightnowOms
      = stylesheet_link_tag    "application"
      = javascript_include_tag "application"
      = csrf_meta_tags

    %body
      = yield
```

Add before filters to your controllers which need to use the cart:

```ruby
  # This before filter will create an instance variable @cart
  before_filter :load_or_create_cart
```

Create cartable models in your application:

```ruby
class Product < ActiveRecord::Base
  acts_as_cartable
end
```

By default, Cart loads the name and price of cartable models by
attributes named name and price. You can customize these attributes:

```ruby
  acts_as_cartable { name: :your_name_attr, price: :your_price_attr }
```

Add a place holder for your cart in your views:

```html
  <div id="cart-wrapper">
    <script type="text/x-handlebars">
      {{ view RightnowOms.ShowCartView }}
    </script>
  </div>
```

and load your cart in the view:

```javascript
  $(function() {
    RightnowOms.cartController.load(#{@cart.as_api_response(:default).to_json.html_safe});
  });
```

You can add cartables to the cart by:

```javascript
  RightnowOms.cartController.addCartItem({
    cartable_id: 1,
    cartable_type: 'Product'

    // if the item is a child, you need to set the parent id.
    // parent_id: 2
  })
```

Now you have all things done. Wish you have a good day.

## Development

RightnowOms is developed with Ruby 1.9.3-p0 and Rails 3.1.3

```bash
  bundle install
  bundle exec rake app:db:migrate
  bundle exec rake app:db:seed

  # Run the tests. Please make sure you have firefox installed
  bundle exec rake app:db:test:prepare
  rspec

  # Start the dummy application
  rails s
```

## Copyright
Copyright 2011-2012 Beijing Menglifang Network Technology and Science Co.,Ltd. All rights reserved.
