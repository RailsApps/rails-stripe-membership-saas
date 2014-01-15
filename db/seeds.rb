# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html
puts "ROLES"
YAML.load(ENV['ROLES']).each do |role|
   #Role.find_or_create_by_name({ :name => role }, :without_protection => true) #Rails3
    Role.find_or_create_by(name: role) # }, :without_protection => true) #Rails4
  puts 'role: ' << role
end
puts "DEFAULT USERS"
# Rails3 \/
# user = User.find_or_create_by_email :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
# Rails4 \/
user = User.find_or_create_by(email: ENV['ADMIN_EMAIL'].dup) do |user|
    user.name = ENV['ADMIN_NAME'].dup
    user.password = ENV['ADMIN_PASSWORD'].dup
    user.password_confirmation = ENV['ADMIN_PASSWORD'].dup
end
puts 'user: ' << user.name
user.add_role :admin
# Rails3 \/
# user2 = User.find_or_create_by_email :name => 'Silver User', :email => 'user2@example.com', :password => 'changeme', :password_confirmation => 'changeme'
# Rails4 \/
#user2 = User.find_or_create_by(:email => 'user2@example.com') do |user|
user2 = User.find_or_create_by(email: 'user2@example.com') do |user|
    user.name = 'Silver User'
    user.password = 'changeme'
    user.password_confirmation = 'changeme'
end
user2.add_role :silver
# Rails3 \/
# user3 = User.find_or_create_by_email :name => 'Gold User', :email => 'user3@example.com', :password => 'changeme', :password_confirmation => 'changeme'
# Rails4 \/
#user3 = User.find_or_create_by(:email => 'user3@example.com') do |user|
user3 = User.find_or_create_by(email: 'user3@example.com') do |user|
    user.name = 'Gold User'
    user.password = 'changeme'
    user.password_confirmation = 'changeme'
end
user3.add_role :gold
# Rails3 \/
# user4 = User.find_or_create_by_email :name => 'Platinum User', :email => 'user4@example.com', :password => 'changeme', :password_confirmation => 'changeme'
# Rails4 \/
#user4 = User.find_or_create_by(:email => 'user4@example.com') do |user|
user4 = User.find_or_create_by(email: 'user4@example.com') do |user|
    user.name = 'Platinum User'
    user.password = 'changeme'
    user.password_confirmation = 'changeme'
end
user4.add_role :platinum
puts "users: #{user2.name}, #{user3.name}, #{user4.name}"
