RightnowOms::Engine.routes.draw do
  resource :cart
  resources :cart_items
  resources :orders
end
