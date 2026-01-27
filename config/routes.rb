Rails.application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    get 'up' => 'rails/health#show', as: :rails_health_check

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

    resources :posts
    resources :users, only: [:show] do
      member do
        delete :delete_avatar, to: 'users#delete_avatar'
      end
    end
  end
end
