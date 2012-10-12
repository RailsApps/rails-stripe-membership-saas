Feature: Show Users
  As a visitor to the website
  I want to see registered users listed on the homepage
  so I can know if the site has users

    Scenario: Viewing users
      Given I exist as a user
      When I look at the list of users
      Then I should see my name
