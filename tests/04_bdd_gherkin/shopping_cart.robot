*** Settings ***
Documentation    BDD-style tests using Given/When/Then syntax
...              Robot Framework supports Gherkin prefixes natively
Resource         ${CURDIR}/../../resources/bdd_keywords.resource
Default Tags     advanced    bdd

*** Test Cases ***
Add Single Item To Cart
    [Documentation]    Scenario: Adding one item to an empty cart
    Given the shopping cart is empty
    When I add "Widget" priced at 9.99 to the cart
    Then the cart should contain 1 item(s)
    And the cart total should be 9.99

Add Multiple Items To Cart
    [Documentation]    Scenario: Adding multiple items
    Given the shopping cart is empty
    When I add "Widget" priced at 9.99 to the cart
    And I add "Gadget" priced at 24.99 to the cart
    And I add "Gizmo" priced at 14.99 to the cart
    Then the cart should contain 3 item(s)
    And the cart total should be 49.97

Remove Item From Cart
    [Documentation]    Scenario: Removing an item updates the total
    Given the shopping cart is empty
    And I add "Widget" priced at 9.99 to the cart
    And I add "Gadget" priced at 24.99 to the cart
    When I remove "Widget" from the cart
    Then the cart should contain 1 item(s)
    And the cart total should be 24.99

Apply Discount To Cart
    [Documentation]    Scenario: Percentage discount on total
    Given the shopping cart is empty
    And I add "Premium Widget" priced at 100 to the cart
    When I apply a 20% discount
    Then the cart total should be 80.0

Empty Cart Has Zero Total
    [Documentation]    Scenario: Edge case — empty cart
    Given the shopping cart is empty
    Then the cart should contain 0 item(s)
    And the cart total should be 0
