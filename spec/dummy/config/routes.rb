Rails.application.routes.draw do

  root to: "products#index"

  resources :products
  resources :orders

  mount RightnowOms::Engine => "/rightnow_oms"
  mount TestTrack::Engine => "test"

  get 'booking' => 'products#booking'
  get 'instant' => 'products#instant'
end
