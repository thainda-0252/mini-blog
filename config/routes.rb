Rails.application.routes.draw do
  scope "(:locale)", locale: /jp|vi/ do
    root "posts#feed"
    get "/", to: "posts#feed", as: "user_feed"
    get "/register",  to: "users#new"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    resources :users do
      member do
         get :following, :followers, :liked_posts
      end
    end
    resources :follows, only: %i(create destroy)
    resources :posts do
      collection do
        get :export
        post :import
      end
      resources :likes, only: [:create, :destroy]
    end
    namespace :v1 do
      resources :posts
      post "/login", to: "sessions#create"
      get "/feed", to: "posts#feed"
      resources :follows, only: %i(create destroy)
    end
  end
end
