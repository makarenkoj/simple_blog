Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount_avo

  # scope '(:locale)', locale: /it|uk/ do
    get '/:locale(/*path)',
        to: redirect { |_params, request|
          path = request.path.sub(%r{^/(uk|it|en)}, '')
          path = '/' if path.blank?
          path
        },
        constraints: { locale: /uk|it|en/ },
        status: 301

    get 'up' => 'rails/health#show', as: :rails_health_check

    authenticate :user, ->(user) { user.role == 'creator' && user.email == ENV['AVO_EMAIL'] } do
      mount MissionControl::Jobs::Engine, at: "/jobs"
    end

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
    get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
    get '/sitemap.xml.gz', to: redirect('https://pub-b5117945ddf24c73be1b37aa13e64f80.r2.dev/sitemaps/sitemap.xml.gz')

    devise_scope :user do
      get 'users/sign_out', to: 'devise/sessions#destroy', as: 'logout'
    end

    devise_for :users, controllers: {
      registrations: 'users/registrations'
    }

    root 'posts#index'

    resources :posts do
      resource :bookmark, only: [:create, :destroy], module: :posts
      resource :like, only: [:create, :destroy], module: :posts
      get :library, on: :collection
    end

    resources :users, only: [:show] do
      member do
        delete :delete_avatar, to: 'users#delete_avatar'
        post :follow, to: 'follows#create'
        delete :unfollow, to: 'follows#destroy'
      end
    end

    resources :notifications, only: [:index, :destroy] do
      member do
        get :click
        patch :mark_as_read
      end
    end

    resources :categories, only: [:show, :index] do
      resource :preference, only: [:create, :destroy], module: :categories
    end

    controller :pages do
      get :privacy, as: :privacy_policy
      get :terms
      get :about
    end

    get 'search', to: 'search#index'
    get '/profile', to: 'users#current_profile', as: :current_profile

    post 'update_fcm_token', to: 'users#update_fcm_token'

    namespace :api do
      namespace :v1 do
        resources :posts, only: [:create]
        resources :categories, only: [:index]
      end
    end
  # end
end
