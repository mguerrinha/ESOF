Feature: Search products

  As a user
  I want a search functionality within my pantry inventory allowing me to quickly locate specific products based on name or quantity
  So that I can efficiently manage my stock

  Scenario: Search for a product by name
    Given The user's pantry inventory contains "products" with distinct names
    When The user searches for a product by entering a specific "name"
    Then The app should display "all_products" that "equals" the search query by "name"

  Scenario: Advanced search using multiple filters
    Given The user's pantry inventory contains a variety of "products"
    When The user performs an advanced search using multiple filters like "name" or "quantity"
    Then The app should display "products" that "equals" all the specified criteria in the filters

  Scenario: Product not added yet
    Given The "product" the user wants to search for has not yet been added
    When The user puts its "name" in the text box
    And The user clicks on the "search" button
    Then An "error" message saying that the item was not found must appear on the screen