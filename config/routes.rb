Rails.application.routes.draw do
  # ルートURLをポーカーゲームのトップページに設定
  root to: 'poker_rooms#show'
  
  # ユーザー認証関連（Devise）
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }
  
  # WebSocket for Poker
  mount ActionCable.server => '/cable'
  
  # ユーザー関連
  resources :users, only: [:show] do
    member do
      get :following, :followers
    end
  end
  
  # ポーカーゲーム用のルート
  resources :poker_games, only: [:new, :create, :show] do
    member do
      post :action
    end
  end
  
  # チェス関連
  get 'chases/top' => 'chases#top', as: :chases_top
  resources :chases do
    resources :comments, only: [:create]
    resource :like, only: [:create, :destroy]
  end
  
  # その他のリソース
  resources :relationships, only: [:create, :destroy]
  get 'tetris' => 'games#tetris'
  
  # パブリック名前空間
  namespace :public do
    resources :customers, only: [:show, :edit, :update] do
      collection do
        get 'show'
        get 'edit'
        get 'update'
      end
    end
  end
get '/sounds/:filename', to: 'sounds#show'
get 'play', to: 'pages#play'

end