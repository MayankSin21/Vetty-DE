Q1 — Count purchases per month (excluding refunded purchases)
This query identifies all transactions that were not refunded (i.e., refund_time IS NULL).
Then it groups them by the month of purchase_time and counts how many valid purchases occurred per month.
Purpose:
To understand successful monthly sales trends without counting refunded transactions.

Q2 — Stores with at least 5 orders in October 2020
(a) Including refunded transactions)
We select all purchases made in October 2020, regardless of refunds, group them by store_id, and count how many times each store appears.
Stores with 5 or more orders qualify.
(b) Excluding refunded transactions)
Same as above, but we only count rows where refund_time IS NULL.
This gives us how many stores had at least 5 successful (non-refunded) orders in October.
Purpose:
To compare store performance based on actual vs. total orders.

Q3 — Shortest refund interval per store (in minutes)
We look only at refunded transactions (where refund_time IS NOT NULL).
For each store, we calculate the time difference between the purchase and the refund.
We then choose the minimum interval per store.
Purpose:
This helps evaluate refund processing speed for each store.

Q4 — First order's gross transaction value per store
For each store, we identify the earliest purchase_time.
We then extract that specific order's gross transaction value (and related details).
Purpose:
To understand the starting transaction pattern and revenue for each store.

Q5 — Most popular item among buyers’ first purchases
We first identify each buyer’s first-ever purchase using the earliest purchase time.
Then we find which item appears most frequently in these first purchases.
Purpose:
Gives insight into which products are most commonly bought by new customers.

Q6 — Determine whether a refund is processable (≤ 72 hours)
A refund is considered “processable” only when the refund occurred within 72 hours of the purchase.
We compare refund_time with purchase_time + 72 hours and flag each transaction as TRUE or FALSE.
Purpose:
To enforce or analyze refund policies based on allowed time windows.

Q7 — Get each buyer’s second purchase (excluding refunded ones)
We ignore refunded transactions and sort purchases for each buyer by purchase_time.
We then select the second one in that ordering.
Purpose:
To analyze returning customer behavior based on successful purchases.

Q8 — Find the second transaction time per buyer
We rank all purchases for each buyer based on time.
Then we simply extract the entry where the rank is 2.
Purpose:
To track purchasing patterns and understand when users typically make their second purchase.
