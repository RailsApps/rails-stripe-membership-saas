source 'https://rubygems.org'
ruby '2.2.2'
gem 'rails', '4.2.1'
gem 'sqlite3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
end
gem 'bootstrap-sass'
gem 'devise'
gem 'gibbon'
gem 'payola-payments'
gem 'sucker_punch'
group :development do
  gem 'better_errors'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring-commands-rspec'
end
group :development, :test do
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
  %w[ rspec rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support ].each do |lib|
    'gem lib, github: "rspec/#{lib}"'
  gem 'stripe-ruby-mock', '~> 2.1.1', :require => 'stripe_mock'
  end
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'pry'
  gem 'selenium-webdriver'
  gem 'thin'
end
