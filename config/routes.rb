Rails.application.routes.draw do
  root to: "pages#home"
  resources :guides
  get "/guides/:id/view", to: "guides#view", as: "view_guide"
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
