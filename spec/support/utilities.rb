include ApplicationHelper    

require 'pry'
require 'capybara/rspec'
require 'rspec/rails'

  # sign_out ref : http://stackoverflow.com/questions/19357399/capybaraelementnotfound-unable-to-find-field-email-railstutorialchapter-9
  # cannot find 'Email' field ref :
  # http://stackoverflow.com/questions/19357399/capybaraelementnotfound-unable-to-find-field-email-railstutorialchapter-9?rq=1

  def sign_out
    visit '/'
    first(:link, "Sign out").click
    click_link("Sign out")
#    first(:link, "Sign Out").click
  end

    # 20151012 : this seems to be working, based on last logger call
    def sign_up_with(email, password, confirmation)
#binding.pry
      sign_out
      Rails.logger.debug "we are now in utilities.rb file and the current path is #{current_path}" # => users/sign_up
      visit new_user_registration_path
      Rails.logger.debug "we are now in utilities.rb file and the current path is #{current_path}" # => users/sign_up
      page.find_field('Email').value
      Rails.logger.debug "we are now in utilities.rb file and the current path is #{current_path}" # => users/sign_up
      element = page.field_labeled('Email')
      element.set(email)
      #element.set(@visitor[:email])
      #fill_in 'email', with: email
      element = page.field_labeled('Password')
      element.set(password)
      #element.set(@visitor[:password])
      #page.fill_in 'password', with: password
      element = page.field_labeled('Password confirmation')
      element.set(confirmation)
      #element.set(@visitor[:password_confirmation])
      #page.fill_in 'password confirmation', :with => confirmation
      click_button 'Sign up'
      Rails.logger.debug "we are now in utilities.rb file after clicking Sign up : #{current_path}" # => /pay
    end

    def sign_in(email, password)
      sign_out
      visit new_user_session_path
      #element = page.field_labeled('email')
      #element.set(@visitor[:email])
      fill_in 'Email', with: @visitor[email]
      #fill_in 'Email', with: email
      #element = page.field_labeled('password')
      #element.set(@visitor[:password])
      fill_in 'Password', with: @visitor[password]
      #page.fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def visitor_sign_up_with(email, password, confirmation)
binding.pry
      visit '/visitors/new'
      current_path
      page.find("section/div.column/div.form-centered") do  
      page.should have_xpath('input[1]', text: @email)
      fill_in 'Email', with: "me@myemail.com"     
      click_button 'Sign up'
    end
  end
#        sign_out
 #       visit '/users/sign_up'
  #      visit 'visitors/new'
   #     fill_in 'Email', with: email
    #    fill_in 'Password', with: password
     #   fill_in 'Password confirmation', :with => confirmation
      #click_button 'Sign up'
    #end