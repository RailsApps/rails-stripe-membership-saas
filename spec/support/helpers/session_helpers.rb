module Requests
  module SessionHelpers
    def sign_up(email, password, password_confirmation, plan_id)
      visit new_user_registration_path(plan: 'platinum')
      within('#select_user_plan_id') do
        plan = Plan.find_by_id(plan_id)
        select plan.name
      end
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password_confirmation
      fill_in 'card_number', with: '4242424242424242'
      fill_in 'card_code', with: '123'
      select 12, from: 'date_month'
      select 2025, from: 'date_year'
      click_button 'Sign up'
    end

    def sign_in(email, password)
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

  end
end