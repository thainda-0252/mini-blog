Rails.application.routes.draw do
  scope "(:locale)", locale: /jp|vi/ do
    root "static_pages#index"
    get "/", to: "static_pages#index"
    get "/register",  to: "users#new"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    resources :users do
      member do
         get :following, :followers
      end
    end
    resources :follows, only: %i(create destroy)
    resources :posts
  end
end
