# Feature: Home page
# As a visitor
# I want to visit a home page
# So I can learn more about the website
feature 'Home page', type: :feature do

# Scenario: Visit the home page
# Given I am a visitor
# When I visit the home page
# Then I see "Welcome"
scenario 'visit the home page' do
  visit root_path
  save_and_open_page
  expect(current_path).to eq '/'
  expect(page).to have_content "Learn to build a successful subscription site."
  end

end