Feature: Having a profile page for each user

  As a developer
  I want the app to have a profile page, with the user's profile picture, account settings and general settings
  So that the user can properly organize/costumize their account or the app

  Scenario: Edit Account Settings
    Given The "user" is logged in
    When The user navigates to the "profile_page"
    And The user clicks on the account "settings" option
    And The user updates their "username"
    And The user updates their "email" address
    And The user "saves" the changes
    Then The user's account information should be "updated"

  Scenario: View Profile
    Given The "user" is logged in
    When The user navigates to the "profile_page"
    Then The user should see their "profile_picture"
    And The user should see their "username"
    And The user should see their "email" address
    And The user should see an option to "edit" their profile