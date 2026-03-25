*** Settings ***
Library    Collections

*** Variables ***
${CART_TOTAL}    ${0}
@{CART_ITEMS}

*** Keywords ***
the shopping cart is empty
    ${CART_ITEMS}=    Create List
    Set Suite Variable    ${CART_ITEMS}
    Set Suite Variable    ${CART_TOTAL}    ${0}

I add "${item}" priced at ${price} to the cart
    ${item_dict}=    Create Dictionary    name=${item}    price=${price}
    Append To List    ${CART_ITEMS}    ${item_dict}
    ${new_total}=    Evaluate    ${CART_TOTAL} + ${price}
    Set Suite Variable    ${CART_TOTAL}    ${new_total}

the cart should contain ${count} item(s)
    ${actual}=    Get Length    ${CART_ITEMS}
    Should Be Equal As Integers    ${actual}    ${count}

the cart total should be ${expected}
    Should Be Equal As Numbers    ${CART_TOTAL}    ${expected}

I remove "${item}" from the cart
    ${new_list}=    Create List
    FOR    ${cart_item}    IN    @{CART_ITEMS}
        IF    "${cart_item}[name]" != "${item}"
            Append To List    ${new_list}    ${cart_item}
        ELSE
            ${new_total}=    Evaluate    ${CART_TOTAL} - ${cart_item}[price]
            Set Suite Variable    ${CART_TOTAL}    ${new_total}
        END
    END
    Set Suite Variable    ${CART_ITEMS}    ${new_list}

I apply a ${percent}% discount
    ${discounted}=    Evaluate    ${CART_TOTAL} * (1 - ${percent}/100)
    Set Suite Variable    ${CART_TOTAL}    ${discounted}
