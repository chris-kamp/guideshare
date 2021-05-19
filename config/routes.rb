Rails.application.routes.draw do
  # Root path routes to home page
  root to: "pages#home"

  # Place /guides/x routes above resources to override "/guides/:id" show path
  get "/guides/owned", to: "guides#owned", as: "owned_guides"
  get "/guides/dashboard", to: "guides#dashboard", as: "guides_dashboard"

  # Use shallow nesting to include :guide_id param in index, create and new Review paths
  resources :guides, shallow: true do
    resources :reviews
  end

  # Custom routes for guides
  post "/guides/:id/purchase", to: "guides#purchase"
  get "/guides/:id/purchase-success", to: "guides#success"
  get "/guides/:id/purchase-cancel", to: "guides#cancel"
  get "/guides/:id/view", to: "guides#view", as: "view_guide"
  get "/guides/:id/archive", to: "guides#archive", as: "archive_guide"
  get "/guides/:id/restore", to: "guides#restore", as: "restore_guide"

  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
