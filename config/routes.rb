RailsStripeMembershipSaas::Application.routes.draw do
  get "content/silver"

  get "content/gold"

  get "content/platinum"

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users
end