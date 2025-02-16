Feature: App Notification Click

  As a user
  I want to click on the app's notifications
  So that I can quickly check the app when notified

  Scenario: User clicks on app notification and is redirected to the app
    Given The app is running in the "background"
    And A "notification" is sent to the user
    When The user "clicks" on the notification
    Then The app should open
    And The user should be "directed" to the relevant "section" of the app indicated by the "notification"