module Features
  module SessionHelpers

    def sign_up_silver
      fill_in 'Email', with: 'silver@johnnyappleseed.com'
      fill_in 'Password', with: 'please123'
      fill_in 'Password confirmation', with: 'please123'
      fill_in 'card_number', with: '4242424242424242'
      fill_in 'card_code', with: '123'
      select 10, from: 'date_month'
      select 2020, from: 'date_year'
      click_button 'Sign up'
    end

    def sign_up_gold
      visit '/users/sign_up?plan=gold'
      fill_in 'Email', with: 'tester@example.com'
      fill_in 'Password', with: 'please123'
      fill_in 'Password confirmation', with: 'please123'
      fill_in 'card_number', with: '4242424242424242'
      fill_in 'card_code', with: '123'
      select 11, from: 'date_month'
      select 2021, from: 'date_year'
      click_button 'Sign up'
    end

    def sign_up_platinum
      visit '/users/sign_up?plan=platinum'
      fill_in 'Email', with: 'testers@example.com'
      fill_in 'Password', with: 'please123'
      fill_in 'Password confirmation', with: 'please123'
      fill_in 'card_number', with: '4242424242424242'
      fill_in 'card_code', with: '123'
      select 12, from: 'date_month'
      select 2022, from: 'date_year'
      click_button 'Sign up'
    end

    def sign_in(email, password)
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def sign_out
      visit '/users/sign_out'
    end
  end
end