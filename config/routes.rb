RailsStripeMembershipSaas::Application.routes.draw do

  root :to => 'home#index'

  mount StripeEvent::Engine => '/stripe'
  get "content/gold"
  get "content/silver"
  get "content/platinum"
 # Documentation for below change, which does not work :
 # http://stackoverflow.com/questions/17384289/unpermitted-parameters-adding-new-fields-to-devise-in-rails-4-0
 #devise_for :users, :controllers => { :registrations => 'users/registrations' }  # Rails4  : this didn't work
  devise_for :users, :controllers => { :registrations => 'registrations' }        # Rails3  : this works
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
  end
  resources :users
end