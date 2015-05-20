module Requests
  module SessionHelpers
    
    def sign_up
      visit new_user_registration_path(plan: 'platinum')
      expect(page).to have_selector("select#user_plan_id")
      within('select#user_plan_id') do
        select('Platinum')
      end
      fill_in('Email', with: 'platinum10@example.com')
      fill_in('Password', with: 'please130')
      fill_in('Password confirmation', with: 'please130')
      fill_in('card_number', with: '4242424242424242')
      fill_in('card_code', with: '123')
      select(12, from: 'date_month')
      select(2025, from: 'date_year')
      click_button('Sign up')
    end

    def sign_in(email, password)
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

  end
end