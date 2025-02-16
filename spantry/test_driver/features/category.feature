Feature: Categorize products

  As a user
  I want to categorize products in my pantry
  So that I can organize them better

  Scenario: Adding a new category
    Given The "user" wants to organize their pantry products into "categories"
    When The "user" creates a "new_category" by entering a "category_name"
    Then The "app" should add the "new_category" to the list of available "categories"

  Scenario: Assigning a product to a category
    Given The "user" has "uncategorized_products"
    When The "user" assigns a "product" to a "category"
    Then The "product" appears in that "category"