Feature: Generate a shopping list based on upcoming expirations

  As a user
  I want a "shopping list" feature that generates a list of items to purchase based on low stock or upcoming expirations in my pantry inventory

  Scenario: Generating shopping list from low stock items
  Given The user's pantry "inventory" has items below the restock threshold
  When The user requests a "shopping_list"
  Then The app should include all "low_stock_items" in the "shopping_list"

  Scenario: Allowing user to modify the generated shopping list
  Given The app generates a "shopping_list" based on the user's pantry "inventory"
  When The user reviews the "shopping_list"
  Then The user should be able to "add" or "remove" items from the "shopping_list" manually

  Scenario: Receive a shopping list
  Given There are no products that are expiring
  And There are not a low quantity of certain products
  When I enter the "shopping_list_menu"
  Then An "error" message appears