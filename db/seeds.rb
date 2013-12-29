# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html
puts 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.find_or_create_by_name({ :name => role }, :without_protection => true)
  puts 'role: ' << role
end
puts 'DEFAULT USERS'
user = User.find_or_create_by_email :first_name => ENV['ADMIN_FIRST_NAME'].dup, :last_name => ENV['ADMIN_LAST_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.first_name
user.add_role :admin
# user.api_key = ApiKey.create

# begin 
# 	require File.expand_path(File.dirname(__FILE__) + "/data/seed.rb")
# rescue 
if !Rails.env.production?
	user2 = User.find_or_create_by_email :first_name => 'Silver', :last_name => 'User', :email => 'user2@example.com', :password => 'changeme', :password_confirmation => 'changeme'
	user2.add_role :silver
	# user2.api_key = ApiKey.create
	user3 = User.find_or_create_by_email :first_name => 'Gold', :last_name => 'User', :email => 'user3@example.com', :password => 'changeme', :password_confirmation => 'changeme'
	user3.add_role :gold
	# user3.api_key = ApiKey.create
	user4 = User.find_or_create_by_email :first_name => 'Platinum', :last_name => 'User', :email => 'user4@example.com', :password => 'changeme', :password_confirmation => 'changeme'
	user4.add_role :platinum
	# user4.api_key = ApiKey.create
	puts "users: #{user2.first_name}, #{user3.first_name}, #{user4.first_name}"
end

if Dir.exists?('db/sites')
	require File.expand_path(File.dirname(__FILE__) + "/sites/seed.rb")
end