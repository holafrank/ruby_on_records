Rails.application.routes.draw do


  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  get "logout", to: "sessions#destroy"

  # Helpers no tiene el prefijo "backstore",
  # pero sí da controllers organizados por módulo, como por ejemplo, Backstore::SalesController
  # Agrego las rutas con prefijo manualmente para obtener lo que haría un namespace
  # pero sin compromenter los nombres de los helpers que ya utilizo, volviendo más difícil la refactorización.
 # scope module: :backstore do
 #   resources :sales, path: 'backstore/sales'
 #   resources :disks, path: 'backstore/disks'
 #   resources :items, path: 'backstore/items'
 #   resources :users, path: 'backstore/users'
 #   resources :clients, path: 'backstore/clients'
 #   resources :genres, path: 'backstore/genres'
 # end

  namespace :backstore do
    resources :sales
    resources :disks
    resources :items
    resources :users
    resources :clients
    resources :genres
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  root "storefront#index"

  resources :disks, only: [:index, :show]
  resources :genres, only: [:index, :show]
  # Defines the root path route ("/")
  # root "posts#index"
end
