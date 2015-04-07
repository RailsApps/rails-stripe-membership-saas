source 'https://rubygems.org'
ruby '2.1.0'
gem 'rails', '4.2.0'
group :development, :test do
  gem 'factory_girl_rails', '~> 4.3.0'
  %w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
    gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => 'master'
  end
  gem 'pry'
  gem 'teaspoon', '~> 0.7.8'
end
group :test do
  gem 'capybara', '~> 2.2.1'
  gem 'cucumber-rails', '~> 1.4.0', :require => false
  gem 'database_cleaner', '~> 1.2.0'
  gem 'email_spec', '>= 1.5.0'
  gem 'launchy', '~> 2.4.2'
end
group :development do
  gem 'better_errors', '~> 1.1.0'
  gem 'binding_of_caller', '~> 0.7.2', :platforms => [:mri_19, :rbx]
  gem 'quiet_assets', '>= 1.0.2'
  gem 'spring'
end
gem 'bootstrap-sass', '~> 3.1.0.2'
gem 'coffee-rails', '~> 4.0.1'
gem 'cancan', '~> 1.6.10'
gem 'devise', '~> 3.4.0'
gem 'jquery-rails'
gem 'rolify', '~> 3.4.0'
gem 'sass-rails', '~> 4.0.1'
gem 'selenium-webdriver', '~> 2.39.0'
gem 'simple_form', '~> 3.0.1'
gem 'stripe', '~> 1.20'
gem 'stripe_event', '~> 1.5.0'
gem 'stripe-ruby-mock', '~> 2.1', :require => 'stripe_mock'
gem 'sqlite3'
gem 'uglifier', '~> 2.4.0'
gem 'web-console', '~> 2.0'
