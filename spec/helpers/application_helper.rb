module Features
  module SessionHelpers
    def sign_up_with(email, password, confirmation)
      visit 'new_user_registration_path'
      page.fill_in 'Email', with: email
      page.fill_in 'Password', with: password
      page.fill_in 'Password confirmation', with: confirmation
      click_button 'Sign up'
    end

    def sign_in(email, password)
      page.visit new_user_session_path
      page.fill_in 'Email', with: email
      page.fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end