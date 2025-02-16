Feature: Edit or delete products

  As a user
  I want to edit or delete products in my pantry
  So that if I make a mistake or need to update information

  Scenario: Editing a product's details
    Given The user views their pantry inventory
    When The user selects a "product" to edit
    And The user updates any detail ("name", "quantity" or "category") of the product
    Then The app should save the changes
    And Display the updated details ("new_name", "new_quantity" or "new_category") for the product in the inventory

  Scenario: Deleting a product from the pantry
    Given The user views their pantry inventory
    When The user selects a "product" to delete
    And "Confirms" the deletion
    Then The "product" should be removed from the pantry inventory
    And The "product" no longer exists in the list of products