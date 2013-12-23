source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '3.2.13'
gem 'devise'
gem 'cancan'
gem 'rolify'
gem 'acts_as_follower'
gem 'sqlite3'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'bootstrap-sass'
gem 'figaro'
gem 'high_voltage'
gem 'simple_form'
gem 'therubyracer'
gem "stripe", ">= 1.7.11"
gem "stripe_event", ">= 0.4.0"
gem "awesome_print" #For using in Rails Console
# gem 'protected_attributes' #For upgrading to Rails 4

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'teaspoon'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :rbx]
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'guard'
  gem "guard-rspec"
  gem "guard-livereload"
  gem "guard-cucumber"
  gem "guard-spork"
end

group :test do
  gem "database_cleaner"
  gem "email_spec"
  gem "cucumber-rails", :require => false
  gem 'selenium-webdriver'
  gem "launchy"
  gem "capybara"
  gem 'headless'
end