# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email
CreatePlanService.new.call
puts 'CREATED PLANS'
silver = Plan.find_by_name("Silver")
gold = Plan.find_by_name("Gold")
platinum = Plan.find_by_name("Platinum")
puts 'CREATED SILVER PLAN   : stripe_id = ' + silver.stripe_id
puts 'CREATED GOLD PLAN     : stripe_id = ' + gold.stripe_id
puts 'CREATED PLATINUM PLAN : stripe_id = ' + platinum.stripe_id
CreateUserService.new.call
silver_user = User.find_by_email("user2@example.com")
gold_user = User.find_by_email("user3@example.com")
platinum_user = User.find_by_email("user4@example.com")
puts 'CREATED SILVER USER   :'  << silver_user.email
puts 'CREATED GOLD USER     :'  << gold_user.email
puts 'CREATED PLATINUM USER :'  << platinum_user.email
