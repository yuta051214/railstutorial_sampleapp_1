Rails.application.routes.draw do
  # 静的ページ
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'

  # ログイン・ログアウト機能
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # ユーザー/フォロー機能
  get '/signup', to: 'users#new'
  resources :users do
    member do
      get :following, :followers
    end
    # memberメソッドを使うと、ユーザidが含まれているURLを扱うようになる。
    # この場合のURLは GET /users/1/following や GET /users/1/followers のようになる。
    # 使えるようになる名前付きルートは following_user_path(:id) / followers_user_path(:id) 。
    # ちなみに、idを指定しない場合には collectionメソッドを使う( users/following、アプリケーションにある全てのfollowingのリストを表示する)。
  end

  # フォロー機能
  resources :relationships, only: [:create, :destroy]

  # アカウント有効化機能
  resources :account_activations, only: [:edit]

  # PWの再設定機能
  resources :password_resets, only: [:new, :create, :edit, :update]

  # マイクロポスト
  resources :microposts, only: [:create, :destroy]

  # root 'application#hello'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
