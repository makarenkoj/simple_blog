Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    devise_scope :user do
      get 'users/sign_out', to: 'devise/sessions#destroy', as: 'logout'
    end
    devise_for :users
    root 'posts#index'

    resources :posts
    resources :users
  end
end
