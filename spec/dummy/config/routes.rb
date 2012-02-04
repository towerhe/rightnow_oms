Rails.application.routes.draw do

  root to: "products#index"

  mount RightnowOms::Engine => "/rightnow_oms"
end
