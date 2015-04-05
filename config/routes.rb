RailsStripeMembershipSaas::Application.routes.draw do
  get "content/gold"
  get "content/silver"
  get "content/platinum"

  root :to => 'home#index'

  mount StripeEvent::Engine => '/stripe'
  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
  end
  resources :users
end