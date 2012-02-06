Rails.application.routes.draw do

  root to: "products#index"

  resources :products

  mount RightnowOms::Engine => "/rightnow_oms"
end
