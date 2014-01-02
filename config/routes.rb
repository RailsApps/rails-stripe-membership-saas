require 'sidekiq/web'

RailsStripeMembershipSaas::Application.routes.draw do
  mount StripeEvent::Engine => '/stripe'
  mount Sidekiq::Web, at: '/sidekiq'
  get "content/gold"
  get "content/silver"
  get "content/platinum"
  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :items
      resources :listings
      resources :follows
      get 'get_urls' => 'follows#get_urls'
    end
  end

  resources :users
  resources :taxonomies, :only => [:index]
  resources :categories, :only => [:index]
  resources :tags, :only => [:index]
  resources :organizations, :only => [:index]
  resources :items, :only => [:index]
  resources :listings, :only => [:index]
  resources :unknowns, :only => [:index]
end