Rails.application.routes.draw do
  # ROOT
  # Root path routes to home page
  root to: "pages#home"

  # GUIDES
  # Place /guides/x routes above resources to override "/guides/:id" show path
  get "/guides/owned", to: "guides#owned", as: "owned_guides"
  get "/guides/dashboard", to: "guides#dashboard", as: "guides_dashboard"

  # Use shallow nesting to include :guide_id param in index, create and new Review paths
  resources :guides, shallow: true do
    # REVIEWS
    resources :reviews, except: :show
  end

  # Custom routes for guides
  post "/guides/:id/purchase", to: "guides#purchase"
  get "/guides/:id/purchase-success", to: "guides#success"
  get "/guides/:id/purchase-cancel", to: "guides#cancel"
  get "/guides/:id/view", to: "guides#view", as: "view_guide"
  get "/guides/:id/archive", to: "guides#archive", as: "archive_guide"
  get "/guides/:id/restore", to: "guides#restor# Dele", as: "restore_guide"

  # CARTS
  # No restful params required as users can only view their own cart
  get "/cart", to: "carts#show", as: "cart"

  # CART GUIDES
  resources :cart_guides, only: [:create, :destroy]

  # USERS
  # Use custom SignupsController to handle registrations (extends devise default to provide added functionality)
  devise_for :users, controllers: { registrations: "signups" }
end
