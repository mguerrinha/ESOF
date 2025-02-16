Feature: Add new products

  As a user
  I want to add new products to my pantry, including details such as name, quantity, and category
  So that I can keep an accurate inventory

  Scenario: The user navigate to the "Add Product" section
    Given The user is logged into my pantry management system
    When The user selects the button to "add_new_product"
    Then The user should see input fields for product "name", "quantity", and "category"

  Scenario: The user select the category for the product
    Given The user is adding a new "product"
    When The user select the "category" from the dropdown menu
    Then The system should allow me to choose from "default_categories"
