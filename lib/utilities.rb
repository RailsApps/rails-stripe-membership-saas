include ApplicationHelper

  require 'capybara'
  require 'capybara/dsl'

module Utilities
  def sign_out
    visit '/users/sign_out'
  end

  def sign_up_silver(email, password, confirmation)
    sign_out
    visit new_user_registration_path
    within('#signingin legend') do
      fill_in 'Email', with: :'user4@example.com'
      fill_in 'Password', with: :'please124'
      fill_in 'Password_confirmation', with: :'please124'
      fill_in 'credit_card_number', with: :'4242424242424242'
      fill_in 'card_code', with: :'124'
      fill_in 'amount', with: :'900'
      fill_in 'role', with: :'silver'
      fill_in 'plan_id', with: :'Silver'
      click_button 'Sign up'
    end
  end

  def sign_up_gold(email, password, confirmation)
   #sign_out
   #visit new_user_registration_path
    within('#signingin legend') do
      fill_in 'Email', with: :'user5@example.com'
      fill_in 'Password', with: :'please125'
      fill_in 'Password_confirmation', with: :'please125'
      fill_in 'credit_card_number', with: :'4242424242424242'
      fill_in 'card_code', with: :'125'
      fill_in 'amount', with: :'1900'
      fill_in 'role', with: :'3'
      fill_in 'plan_id', with: :'gold'
    end
    click_button 'Sign up'
  end

  def sign_up_platinum(email, password, confirmation)
    sign_out
    visit new_user_registration_path
    within('#signingin legend') do
      fill_in 'Email', with: :'user6@example.com'
      fill_in 'Password', with: :'please126'
      fill_in 'Password_confirmation', with: :'please126'
      fill_in 'credit_card_number', with: :'4242424242424242'
      fill_in 'card_code', with: :'123'
      fill_in 'amount', with: :'2900'
      fill_in 'role', with: :'5'
      fill_in 'plan_id', with: :'platinum'
      click_button 'Sign up'
    end
  end



  def sign_in(email, password)
   #sign_out
#binding.pry
    visit new_user_session_path
    within('#signingin legend') do
#      user = User.where(email: :'test@example.com').first_or_initialize do |user|
 #     user.email = email
  #    user.password = password
   #   user.role = 1
    #  user.save
     # visit new_user_session_path
      page.fill_in("Email", with: :'test@example.com')
      page.fill_in("Password", with: 'please123')
      click_button 'Sign in'
    end
  end


=begin
  def sign_in(email, password)
    case 'email'
    when 'test@example.com'
      puts 'Signing in as Admin'
#     sign_in_admin
      user = User.where(email: :'test@example.com').first_or_initialize do |user|
      user.email = 'test@example.com'
      user.password = 'please123'
      user.role = 1
      user.save
      visit new_user_session_path
      page.fill_in("Email", with: :'test@example.com')
      page.fill_in("Password", with: 'please123')
      click_button 'Sign in'
      end
    when 'user4@example.com'
      puts 'Signing in as Silver'
      sign_in_silver
    when 'user5@example.com'
      puts 'Signing in as Gold'
      sign_in_gold
    when 'user6@example.com'
      puts 'Signing in as Platinum'
      sign_in_platinum
    else
      puts "You need to Sign up before you can Sign in."
      visit '/'
    end
  end
=end

  def sign_in_admin
    sign_out
    user = User.where(email: :'test@example.com').first_or_initialize do |user|
      user.email = 'test@example.com'
      user.password = 'please123'
      user.role = 1
      user.save
      visit new_user_session_path
      page.fill_in("Email", with: :'test@example.com')
      page.fill_in("Password", with: 'please123')
      click_button 'Sign in'
    end
  end

  def sign_in_fails(email, password)
    sign_out
    visit new_user_registration_path
    user = User.where(email: :'test@example.com').first_or_initialize do |user|
      visit new_user_session_path
      page.fill_in("Email", with: :'test@example.com')
      page.fill_in("Password", with: :'not_my_password')
      click_button 'Sign in'
    end
  end

  def sign_up_new_user(email, password)
    sign_out
    visit new_user_registration_path
    user = User.where(email: :'user4@example.com').first_or_initialize do |user|
      user.password = 'please124'
      user.password_confirmation = 'please124'
      user.role = 'silver'
      user.plan_id = 'Silver'
      user.save
      visit new_user_registration_path
      page.fill_in("Email", with: :'user4@example.com')
      page.fill_in("Password", with: 'please124')
      click_button 'Sign in'
    end
  end

  def sign_in_admin(email, password)
    sign_out
    visit new_user_session_path
    user = User.where(email: :'test@example.com').first_or_initialize do |user|
      user.password = 'please123'
      user.password_confirmation = 'please123'
      user.role = 'admin'
      user.plan_id = ''
      user.save
      visit new_user_session_path
      page.fill_in("Email", with: :'test@example.com')
      page.fill_in("Password", with: :'please123')
      click_button 'Sign in'    
    end
  end

  def sign_in_silver(email, password)
    sign_out
    visit new_user_session_path
    user = User.where(email: :'user4@example.com').first_or_initialize do |user|
      user.password = 'please124'
      user.password_confirmation = 'please124'
      user.role = 'silver'
      user.plan_id = 'Silver'
      user.save
      visit new_user_session_path
      page.fill_in("Email", with: :'user4@example.com')
      page.fill_in("Password", with: 'please124')
      click_button 'Sign in'
    end
  end

  def sign_in_gold(email, password)
    sign_out
    visit new_user_session_path
    user = User.where(email: :'user5@example.com').first_or_initialize do |user|
      user.password = 'please125'
      user.password_confirmation = 'please125'
      user.role = 'gold'
      user.plan_id = 'Gold'
      user.save
      visit new_user_session_path
      page.fill_in("Email", with: :'user5@example.com')
      page.fill_in("Password", with: :'please125')
      click_button 'Sign in'
    end
  end

  def sign_in_platinum(email, password)
    sign_out
    visit new_user_session_path
    user = User.where(email: :'user6@example.com').first_or_initialize do |user|
      user.password = 'please126'
      user.password_confirmation = 'please126'
      user.role = 'platinum'
      user.plan_id = 'Platinum'
      user.save
      visit new_user_session_path
      page.fill_in("Email", with: :'user6@example.com')
      page.fill_in("Password", with: 'please126')
      click_button 'Sign in'
    end
  end

end