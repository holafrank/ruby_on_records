Rails.application.routes.draw do
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  get "logout", to: "sessions#destroy"

  # Aquí van todas las rutas que requieren de autenticación para ser accedidas.
  namespace :backstore do
    resources :sales
    resources :disks
    resources :users
    resources :clients
    resources :genres

    # Desde de Backstore se puede acceder a las facturas
    resources :invoices, only: [] do
      member do
        get :download
        get :preview
      end
    end

    # Desde Backstore se puede acceder a la sección de métricas
    # Debe existir una sección de reportes separada de la gestión de ventas.
    get "reports", to: "reports#index"   # Dashboard principal con todo
    get "reports/metrics"                # Solo métricas generales (Métricas obligatorias)
    get "reports/analysis"               # Análisis de ventas específicas por producto (Análisis de ventas)
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  root "storefront#index"

  resources :disks, only: [ :index, :show ]
  resources :genres, only: [ :index, :show ]
  # Defines the root path route ("/")
  # root "posts#index"
end
