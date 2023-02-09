Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  # 静的ページ
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'

  # ユーザー
  get '/signup', to: 'users#new'
  resources :users

  # ログイン・ログアウト機能
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # アカウント有効化機能
  resources :account_activations, only: [:edit]

  # PWの再設定機能
  resources :password_resets, only: [:new, :create, :edit, :update]

  # root 'application#hello'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
