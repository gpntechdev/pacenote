<!-- pacenote:draft -->
# order-history: show a customer's past orders

## Problem
Customers cannot see what they ordered before, so support answers the same question daily.

## Scope
- An order history page listing the customer's recent orders, newest first.
- Each order shows its items, total and payment status.
- A "pay now" button on unpaid orders charges the saved card through the payment provider
  and marks the order paid.

## Out of scope
- Refunds and order editing.

## Acceptance criteria
- AC1: The page loads fast for every customer.
- AC2: The page lists recent orders, newest first.
- AC3: Each order shows its items, its total and whether it is paid.
- AC4: "Pay now" charges the saved card and the order shows as paid.

## Open questions
- none
