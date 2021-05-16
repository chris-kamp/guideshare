Rails.application.routes.draw do
  root to: "pages#home"
  # Place owned_guides above resources to override "/guides/:id" show path
  get "/guides/owned", to: "guides#owned", as: "owned_guides"
  resources :guides
  get "/guides/:id/view", to: "guides#view", as: "view_guide"
  get "/guides/:id/purchase", to: "guides#purchase", as: "purchase_guide"
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
