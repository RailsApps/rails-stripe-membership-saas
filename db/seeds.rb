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
    Role.find_or_create_by(name: role) # }, :without_protection => true) # Rails 4 further research this change
  puts 'role: ' << role
end
puts "DEFAULT USERS"
user = User.find_or_create_by(email: ENV['ADMIN_EMAIL'].dup) do |user|
    user.name = ENV['ADMIN_NAME'].dup
    user.password = ENV['ADMIN_PASSWORD'].dup
    user.password_confirmation = ENV['ADMIN_PASSWORD'].dup
end
puts 'user: ' << user.name
user.add_role :admin
user2 = User.find_or_create_by(email: 'user2@example.com') do |user|
    user.name = 'Silver User'
    user.password = 'changeme'
    user.password_confirmation = 'changeme'
end
user2.add_role :silver
user3 = User.find_or_create_by(email: 'user3@example.com') do |user|
    user.name = 'Gold User'
    user.password = 'changeme'
    user.password_confirmation = 'changeme'
end
user3.add_role :gold
user4 = User.find_or_create_by(email: 'user4@example.com') do |user|
    user.name = 'Platinum User'
    user.password = 'changeme'
    user.password_confirmation = 'changeme'
end
user4.add_role :platinum
puts "users: #{user2.name}, #{user3.name}, #{user4.name}"
