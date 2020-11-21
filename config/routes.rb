Rails.application.routes.draw do
  devise_scope :user do
    get 'users/sign_out', to: "devise/sessions#destroy", as: "logout"
  end
  devise_for :users
  root 'posts#index'

  resources :posts
  resources :users, only: %i[show edit update]
end
