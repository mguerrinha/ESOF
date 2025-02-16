Feature: Product barcode scanning

  As a user
  I want to scan product´s barcode
  So that I can quickly add them to my pantry

  Scenario: Scan product barcode
    Given The user is in the "add_product" menu
    When The user clicks the "scanBarcode" button
    And The user points to the barcode
    Then The product is stored in the system
    And "ImageUrl" is different from "''"
    And Dispay the "_scanBarcodeResult"