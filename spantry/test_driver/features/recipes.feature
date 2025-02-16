Feature: Add new recipes

  As a user
  I want to create and edit my own recipes
  So that I can have customized meal plans in my app

  Scenario: Create own recipes
    Given The "user" is in the recipe creation menu
    And Have already selected the necessary "ingredients"
    And Typed the "instructions" to make the recipe
    When The user clicks on the "create_recipe" button
    Then The recipe must be "saved" in the system