### UTILITY METHODS ###

def create_visitor
  @visitor ||= { :name => "Testy McUserton", :email => "example@example.com",
    :password => "changeme", :password_confirmation => "changeme", :role => "silver" }
end

def find_user
 #@user ||= User.first conditions: {:email => @visitor[:email]}      # Rails3 : will not work in Rails4
 #reference for change is http://rubydoc.info/docs/rails/ActiveRecord/Relation:find_or_create_by
  @user ||= User.find_or_create_by(email: @visitor[:email])          # Rails4
  # @user ||= User.find_or_create_by(email: @visitor[:email]) do |user|      # Rails4 to add more than one attribute
  #   user.password = @visitor[:password]                                    # Rails4 use this 'do |user|' method
  # end                                                                      # Rails4 end of the do command
end

def create_unconfirmed_user
  create_visitor
  delete_user
  sign_up
  visit '/users/sign_out'
end

def create_user
  create_visitor
  delete_user
  @user = FactoryGirl.create(:user, email: @visitor[:email])
  @user.add_role(@visitor[:role])
end

def delete_user
 #@user ||= User.first conditions: {:email => @visitor[:email]}  # Rails3 : will not work in Rails4
  @user ||= User.find_or_create_by(email: @visitor[:email])      # Rails4
 # reference for change is
 # http://stackoverflow.com/questions/18727356/how-to-fix-deprecation-relationfirst-with-finder-options

  @user.destroy unless @user.nil?
end

def sign_up
  delete_user
  visit '/users/sign_up/?plan=silver'
  puts "You have arrived here " + current_path        # can be removed when tests all pass
  page.fill_in "Name", :with => @visitor[:name]
  page.fill_in "Email", :with => @visitor[:email]
  page.fill_in "user_password", :with => @visitor[:password]
  page.fill_in "user_password_confirmation", :with => @visitor[:password_confirmation]
  puts "You click on the Sign Up button next"         # can be removed when tests all pass
  click_button "Sign up"
  puts "You have arrived here " + current_path        # can be removed when tests all pass
  find_user
end

def sign_in
  visit '/users/sign_in'
  page.fill_in "Email", :with => @visitor[:email]
  page.fill_in "Password", :with => @visitor[:password]
  click_button "Sign in"
  puts "You have arrived here " + current_path        # can be removed when tests all pass
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit destroy_user_session_path
end

Given /^I am logged in$/ do
  create_user
  sign_in
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

Given /^I exist as an unconfirmed user$/ do
  create_unconfirmed_user
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(:email => "notanemail")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
  sign_up
end

When /^I sign up without a subscription plan$/ do
  visit '/users/sign_up'
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "changeme123")
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong email$/ do
  @visitor = @visitor.merge(:email => "wrong@example.com")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(:password => "wrongpass")
  sign_in
end

When /^I change my email address$/ do
  click_link "Edit account"
  page.fill_in "user_email", :with => "different@example.com"
  page.fill_in "user_current_password", :with => @visitor[:password]
  click_button "Update"
end

When /^I delete my account$/ do
  puts "You are here " + current_path        # can be removed when tests all pass
  click_link "Edit account"
  puts "You just pressed the Edit account button"
  puts "You have arrived here " + current_path        # can be removed when tests all pass
  click_link "Cancel my account"
  page.driver.browser.switch_to.alert.accept
  puts "You have just pressed the Cancel my account button"
  puts "You have just pressed the Okay button in the Confirm box"
  puts "You have arrived here " + current_path        # can be removed when tests all pass
end

When /^I follow the subscribe for silver path$/ do
  visit '/users/sign_up/?plan=silver'
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_content "Logout"
  page.should_not have_content "Sign up"
  page.should_not have_content "Login"
end

Then /^I should be signed out$/ do
  page.should have_content "Login"
  page.should_not have_content "Logout"
end

And /^I should see "(.*?)"$/ do |text|                            # replaced by below specificly named tests
  puts "You are currently here " + current_path                    # can be removed when tests all pass
  page.should have_content text
end

#Then /^I should see Silver Subscription Plan$/  do             # first replacement of above generic code with this exact code
#  page.should have_content "Silver Subscription Plan"          # can be removed when all tests pass
#end

#Then /^I should see Your card number is incorrect$/  do        # second replacement of above generic code with this specific code
#  page.should have_content "Your card number is incorrect"     # remove when all tests pass
#end

#Then /^I should see Your card security code is invalid$/  do     # third replacement of above generic with this specific code
#  page.should have_content "Your card security code is invalid"  # remove notes when all tests pass
#end

#Then /^I should see declined$/  do                                  # fourth replacement of above generic with this specific code
#  puts "You have arrived here " + current_path                      # can be removed when tests all pass
#  puts "Alert Text is " + page.driver.browser.switch_to.alert.text  # can be removed when tests all pass
#  page.driver.browser.switch_to.alert.accept                        # ? working ?
#  page.should have_content "declined"
#end

Then /^I should be on the "([^"]*)" page$/ do |path_name|
  puts "You have arrived here " + current_path                       # can be removed when tests all pass

  current_path.should == send("#{path_name.parameterize('_')}_path")
end

#Then /^I should be on the content silver page$/ do    # first replacement of above generic code with this specific address
#  puts "You have arrived here " + current_path        # can be removed when tests all pass
#  current_path.should == '/content/silver'
#end

#Then /^I should be on the user registration page$/ do      # second replacement of above generic code with this specific address
#  puts "You have arrived here " + current_path        # can be removed when tests all pass
#  current_path.should == '/users'
#end

Then /I should be on the new silver user registration page$/ do
  puts "You have arrived here " + current_path        # can be removed when tests all pass
  current_path_with_args.should == '/users/sign_up/?plan=silver'
end

Then /^I see an unconfirmed account message$/ do
  page.should have_content "You have to confirm your account before continuing."
end

Then /^I see a successful sign in message$/ do
  puts "You have arrived here " + current_path        # can be removed when tests all pass
  page.should have_content "Signed in successfully."
end

And /^I should see a successful sign up message$/ do
  puts "You have arrived here " + current_path        # can be removed when tests all pass
  page.should have_content "Welcome! You have signed up successfully."
end

Then /^I should see an invalid email message$/ do
  page.should have_content "is invalid"
end

Then /^I should see a missing password message$/ do
  page.should have_content "can't be blank"
end

Then /^I should see a missing password confirmation message$/ do
  page.should have_content "Password confirmation doesn't match Password"
end

Then /^I should see a mismatched password message$/ do
  page.should have_content "Password confirmation doesn't match Password"
end

Then /^I should see a missing subscription plan message$/ do
  page.should have_content "Please select a subscription plan below"
end

Then /^I should see a signed out message$/ do
  page.should have_content "Signed out successfully."
end

Then /^I see an invalid login message$/ do
  page.should have_content "Invalid email or password."
end

Then /^I should see an account edited message$/ do
  page.should have_content "You updated your account successfully."
end

Then /^I should see an account deleted message$/ do
 page.should have_content "account was successfully cancelled"  # Original code, below is a temporary fix
 #page.should have_content "Not authorized as an administrator"  # This passes the test # TODO  must fix this, why is it happening ?
 #page.should have_content "Bye! Your account was successfully cancelled. We hope to see you again soon."
                          # ^^^^ this is what shows when run in the browswer !!!
end

Then /^I should see my name$/ do
  create_user
  page.should have_content @user[:name]
end
