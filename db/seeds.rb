# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'CREATING ROLES'
Role.create([
  { :name => 'admin' }, 
  { :name => 'silver' }, 
  { :name => 'gold' },
  { :name => 'platinum' }
], :without_protection => true)
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'First User', :email => 'user@example.com', :password => 'please', :password_confirmation => 'please'
user.add_role :admin
puts 'admin created: ' << user.name
user2 = User.create! :name => 'Silver User', :email => 'user2@example.com', :password => 'please', :password_confirmation => 'please'
user2.add_role :silver
user3 = User.create! :name => 'Gold User', :email => 'user3@example.com', :password => 'please', :password_confirmation => 'please'
user3.add_role :gold
user4 = User.create! :name => 'Platinum User', :email => 'user4@example.com', :password => 'please', :password_confirmation => 'please'
user4.add_role :platinum
puts "added users: #{user2.name}, #{user3.name}, #{user4.name}"