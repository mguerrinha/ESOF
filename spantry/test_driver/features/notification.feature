Feature: Notification about an expiry date of a product

  As a user
  I want to be notified when a product in my pantry is about to expire
  So that I can plan to use or replace it before it goes bad

  Scenario: The product has expired
  Given A product's "expiration_date" was yesterday
  When The system checks the "expiration_dates" daily
  Then The user receives a "notification" telling them to replace the expired product

  Scenario: The product is about to expire soon
  Given A "product" is three days away from its "expiration_date"
  When The system "checks" the "expiration_dates" daily
  Then The user receives a "notification" suggesting to use the product soon

  Scenario: When I'm opening the app for the first time
  Given The user is "creating" an "account"
  When The user goes to the permissions "login" part
  Then A box to "allow" the use of "notifications" should appear on the screen