# # Rails.application.routes.draw do
# #   get "home/index"
# #   # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

# #   # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
# #   # Can be used by load balancers and uptime monitors to verify that the app is live.
# #   get "up" => "rails/health#show", as: :rails_health_check

# #   # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
# #   # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
# #   # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

# #   # Defines the root path route ("/")
# #   # root "posts#index"
# #     root "home#index"

# # end

# # config/routes.rb
# Rails.application.routes.draw do
#   root 'dashboard#index'
  
#   # Shopify authentication
#   get '/auth', to: 'auth#login'
#   get '/auth/callback', to: 'auth#callback'
  
#   # Webhooks
#   post '/webhooks/products_update', to: 'webhooks#products_update'
#   post '/webhooks/products_create', to: 'webhooks#products_create'
#   post '/webhooks/inventory_update', to: 'webhooks#inventory_update'
  
#   # API endpoints
#   namespace :api do
#     get 'stores', to: 'stores#index'
#     get 'products', to: 'products#index'
#     post 'sync', to: 'sync#create'
#     get 'sync/:mapping_id/status', to: 'sync#sync_status'
#   end
  
#   # React app entry point
#   get '*path', to: 'dashboard#index', constraints: ->(req) do
#     !req.xhr? && req.format.html?
#   end
# end
Rails.application.routes.draw do
  mount ShopifyApp::Engine, at: '/'
  
  root to: 'home#index'
  
  resources :product_syncs, only: [:index, :update, :destroy]
  get '/stores', to: 'stores#index'
  get '/products', to: 'products#index'
  post '/products/sync', to: 'products#create'
  
  post '/webhooks/products_update', to: 'webhooks#products_update'
  post '/webhooks/products_create', to: 'webhooks#products_create'
  
  match '*path' => 'home#index', via: :all
end