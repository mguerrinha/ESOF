Feature: Secure authentication

  As a user
  I want a secure authentication system for my pantry data
  So that access is restricted to authorized users only

  Scenario: Successful login with correct credentials
    Given A user has an existing account with a username and password
    When The user in the "email" field uses the input "teste@gmail.com"
    And In the "password" field with "123456"
    And Tap the "login" button
    Then The user should be granted access to their pantry data
    And User should enter the "home_page" page

  Scenario: Failed login with incorrect credentials
    Given A user has an existing account with a username and password
    When The user in the "email" field uses the input "teste2@gmail.com"
    And In the "password" field with "teste2123456"
    And Tap the "login" button
    Then The user should receive an error message indicating incorrect login details
    And The user should not be granted access to any pantry data
    And Should stay in the "login" page