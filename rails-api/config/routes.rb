Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    devise_for :merchants, controllers: {
      sessions: 'api/merchants/sessions',
      registrations: 'api/merchants/registrations'
    }

    devise_for :customers, controllers: {
      sessions: 'api/customers/sessions',
      registrations: 'api/customers/registrations'
    }

    # Merchant management endpoints
    resource :merchant, only: [:show, :update]
    resources :products
    resources :bundles
    resources :orders, only: [:index, :show, :create, :update]

    # Customer browsing endpoints
    get 'browse/merchants', to: 'browse#merchants'
    get 'browse/products', to: 'browse#products'
    get 'browse/bundles', to: 'browse#bundles'

    # Customer management endpoints
    resource :customer, only: [:show, :update]
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
