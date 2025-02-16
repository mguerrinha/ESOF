Feature: Create a shopping list

  As a frequent shopper
  I want to create a shopping list based on the items I need to restock in my pantry
  So that I can be sure I have purchased all the necessary items

  Scenario: Adding items to the shopping list
    Given The "user" identifies items that need to be restocked in their pantry
    When The "user" "adds" these items to their "shopping_list" through the app
    Then The "app" should "update" the "shopping_list" with these items

  Scenario: Saving the shopping list
    Given The "user" has created a "shopping_list" in the app
    When The "user" "closes" the app
    Then The "app" should automatically "save" the "shopping_list"