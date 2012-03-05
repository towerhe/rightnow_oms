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
  gem 'confstruct'
  gem 'ransack'

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

## Setup

Mount `rightnow_oms` to your application.

```ruby
  # config/routes.rb
  mount RightnowOms::Engine => "rightnow_oms", as: :rightnow_oms
```

Install the migrations of `rightnow_oms`:

```bash
  rake rightnow_oms:install:migrations
  rake db:migrate
```

`rightnow_oms` is built based on ember, ember-data and ember-i18n, so you need to
install these libs first. Or you can use the files in
`rightnow_oms`. So you need to add the following lines to your `app/assets/javascripts/application.js`:

```
  = require rightnow_oms/vendor/ember
  = require rightnow_oms/vendor/ember-data
  = require rightnow_oms/vendor/ember-i18n
```

After ember libs installed, you need to add `rightnow_oms/application`
to your `app/assets/javascripts/application.js`:

```
  = require rightnow_oms/application
```

To enable the default theme of `rightnow_oms`, you need to link the
default stylesheet into your `app/assets/stylesheets/application.css`:

```
  = require rightnow_oms/application
```

The configurations of `rightnow_oms` ember application are saved in key-value
pairs. To override the default configurations, you only need to call
`RightnowOms.configure` and reset the values of the configurations.

```javascript
  RightnowOms.configure(function(config) {
    // Disable autoCommit
    config.set('autoCommit', false);

    // Set the default locale to zh_CN
    config.set('defaultLocale', 'zh_CN');
  });
```

## Usage

### Add a Float Cart to Your Pages

First, you need to load/create a cart for your pages. By adding a before
filter `load_or_create_cart` to your controllers, you can get the cart.

```ruby
  # This before filter will create an instance variable @cart
  before_filter :load_or_create_cart
```

Secondly, you need to add a place holder for your cart in your views:

```html
  <div id="rightnow-oms">
    <script type="text/x-handlebars">
      {{ view RightnowOms.ShowCartView }}
    </script>
  </div>
```

And then you can load the cart:

```javascript
  $(function() {
    RightnowOms.cartController.load(#{@cart.as_api_response(:default).to_json.html_safe});
  });
```

### Add Cartable Things to Your Cart

`rightnow_oms` can only accept cartable model, so the things you added
to the cart must be a cartable model. To define a cartable model, you
just need to call the extended method `acts_as_cartable` in the model
class.

``` ruby
  class Product < ActiveRecord::Base
    acts_as_cartable
  end
```

By default, Cart loads the name and price of cartable models by
attributes named name and price. But you can define your own name and
price attributes as follows:

```ruby
  class Product < ActiveRecord::Base
    acts_as_cartable name: :your_name_attr, price: :your_price_attr
  end
```

Now you can add cartables to the cart.

```javascript
  RightnowOms.cartController.addCartItem({
    cartable_id: 1,             // required
    cartable_type: 'Product',   // required
    price: '10.00',             // required
    name: 'Parent Product',    // optional
    quantity: 1,                // optional
    // optional, grouping cart items
    group: 'booking',
    // optional
    children: [{
      cartable_id: 2,             // required
      cartable_type: 'Product',   // required
      price: '5.00',              // required
      name: 'Child Product',      // optional
      quantity: 1,                // optional
      // optional, grouping cart items
      group: 'booking',
    })
  })
```

### Manage Your Cart

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

### Create an Order with the Cart

To create an order, you need to specify the url of the page which the
customer will add more detailed information on it. After you click the
submit button on the detailed cart page, you will be redirected to the
url which you have set.

```ruby
  # config/initializers/rightnow_oms.rb
  RightnowOms.configure do
    new_order_url '/orders/new'
  end
```

### Checkout

WIP

## I18n

`rightnow_oms` supports I18n now. By default it only includes two
locales: en and zh_CN, but you can create your own locales easily.
First, you need to define your translations, for example:

### For Javascript

```javascript
  var zh_CN = { 
    'cart.cartable.counter': '购物车'
    'cart.total': '总计'

    'cart_item.name': '名称'
    'cart_item.price': '价格'
    'cart_item.quantity': '数量'
    'cart_item.total': '小计'

    'currency.unit': '￥'
    
    'buttons.check_cart': '查看我的购物车'
    'buttons.delete': '删除'
    'buttons.clean_cart': '清空购物车'
    'buttons.continue_to_shop': '继续购物'
    'buttons.new_order': '提交订单'

    'titles.cart': '我的购物车'

    'alerts.saving_cart': '正在保存购物车，请稍后。。。'

    'confirmations.delete_cart_item': '您确定要删除该商品吗？'
    'confirmations.clean_up_cart': '您确定要清空您的购物车吗？'
  };
```

And then add your translations to `rightnow_oms` and set it as the
default locale:

```javascript
  RightnowOms.configure(function(config) {
    config.set('locales.zh_CN', zh_CN);
    config.set('defaultLocale', 'zh_CN');
  });
```

### For Rails

```yml
# config/locales/rightnow_oms.zh-CN.yml
'zh-CN':
  order:
    total: '总计'
    serial_no: '订单号'
    address: '送货地址'
    contact:
      title: '联系方式'
      receiver: '收货人'
      mobile: '手机'
      tel: '电话'
      required_arrival_time: '要求送达时间'
    payment_mode: '支付方式'
    order_items: '商品清单'
    remarks: '备注'
    vbrk: '发票抬头'
  order_item:
    name: '名称'
    price: '价格'
    quantity: '数量'
    total: '小计'
```

It's welcome to create a pull request for your locale.

## Development

RightnowOms is developed with Ruby 1.9.3-p0 and Rails 3.1.3

First of all, you need to create a database config for RightnowOms.
There are already some useful templates for you under
`spec/dummy/config/`. RightnowOms use MySQL by default. If you want
to setup to use other databases, for example PostgreSQL, you need to modify the
Gemfile and add the adapters by yourself.

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

For the javascript unit tests, you need to start the dummy application
first, and then open your browser and visit
[http://localhost:3000/test/qunit](http://localhost:3000/test/qunit)

## Copyright
Copyright 2011-2012 Beijing Menglifang Network Technology and Science Co.,Ltd. All rights reserved.
