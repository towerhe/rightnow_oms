RightnowOms::Engine.routes.draw do
  resource :cart do
    resources :cart_items
  end
end
