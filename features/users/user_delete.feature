Feature: Delete User
  As a registered user of the website
  I want to delete my user profile
  so I can close my account

    @javascript
    Scenario: I sign in and delete my account
      Given I am logged in
      When I delete my account
      Then I should see an account deleted message

    @javascript
    Scenario: I create a new subscription and delete my account
      Given: I am on the home page
      When I follow the subscribe for silver path
      Then I should see "Silver Subscription Plan"
      Given I fill in the following:
        | Name                       | Testy ShortLived  |
        | Email                      | short@testing.com |
        | user_password              | secret_password   |
        | user_password_confirmation | secret_password   |
        | Credit Card Number         | 4242424242424242  |
        | card_code                  | 111               |
      Then I select "5 - May" as the "month"
      And I select "2015" as the "year"
      When I press "Sign up"
      Then I should be on the "content silver" page
      And I should see a successful sign up message
      When I delete my account
      Then I should see an account deleted message
