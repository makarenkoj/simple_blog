Rails.application.routes.draw do
  mount_avo
  get "pages/privacy"
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    get 'up' => 'rails/health#show', as: :rails_health_check

    authenticate :user, ->(user) { user.role == 'creator' && user.email == ENV['ADMIN_EMAIL'] } do
      mount MissionControl::Jobs::Engine, at: "/jobs"
    end

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
    get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
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
      collection do
        get :library
      end
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

    get 'search', to: 'search#index'
    get 'privacy', to: 'pages#privacy', as: :privacy_policy
    get 'terms', to: 'pages#terms', as: :terms
    get 'about', to: 'pages#about', as: :about
    get '/profile', to: 'users#current_profile', as: :current_profile
  end
end
