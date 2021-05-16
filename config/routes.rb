Rails.application.routes.draw do
  root to: "pages#home"

  # Place /guides/x routes above resources to override "/guides/:id" show path
  get "/guides/owned", to: "guides#owned", as: "owned_guides"
  get "/guides/purchase-success", to: "guides#success"
  get "/guides/purchase-cancel", to: "guides#cancel"
  resources :guides
  post "/guides/:id/buy", to: "guides#buy"
  get "/guides/:id/view", to: "guides#view", as: "view_guide"
  get "/guides/:id/purchase", to: "guides#purchase", as: "purchase_guide"

  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
