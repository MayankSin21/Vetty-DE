CREATE TABLE items (
  store_id INT NOT NULL,
  item_id INT NOT NULL,
  item_category VARCHAR(100),
  item_name VARCHAR(200),
  PRIMARY KEY (store_id, item_id)
);

CREATE TABLE transactions (
  txn_id INT AUTO_INCREMENT PRIMARY KEY,
  buyer_id INT NOT NULL,
  store_id INT NOT NULL,
  item_id INT NOT NULL,
  purchase_time DATETIME NOT NULL,
  refund_time DATETIME DEFAULT NULL,
  gross_transaction_value DECIMAL(10,2)
);

INSERT INTO items(store_id, item_id, item_category, item_name) VALUES
(1, 101, 'electronics', 'Wireless Headphones'),
(1, 102, 'electronics', 'Bluetooth Speaker'),
(2, 201, 'food', 'Veg Sandwich'),
(2, 202, 'food', 'Chicken Wrap'),
(3, 301, 'books', 'Algorithms Book'),
(3, 302, 'books', 'Data Science Handbook');

INSERT INTO transactions(buyer_id, store_id, item_id, purchase_time, refund_time, gross_transaction_value) VALUES
(1, 1, 101, '2020-10-05 09:00:00', '2020-10-07 07:00:00', 1500.00),
(1, 1, 102, '2020-11-02 12:00:00', NULL, 800.00),
(2, 2, 201, '2020-10-10 14:30:00', NULL, 120.00),
(3, 2, 202, '2020-09-15 10:00:00', '2020-09-19 14:00:00', 200.00),
(3, 3, 301, '2020-10-20 08:00:00', NULL, 450.00),
(4, 1, 101, '2020-10-02 09:00:00', NULL, 1500.00),
(4, 1, 101, '2020-10-03 10:00:00', NULL, 1500.00),
(4, 1, 102, '2020-10-04 11:00:00', NULL, 800.00),
(4, 1, 102, '2020-10-10 12:00:00', NULL, 800.00),
(4, 1, 101, '2020-10-22 13:00:00', NULL, 1500.00),
(5, 3, 302, '2020-11-01 09:00:00', '2020-11-03 02:00:00', 600.00),
(6, 2, 201, '2020-10-12 18:00:00', NULL, 120.00);

-- Q1)What is the count of purchases per month (excluding refunded purchases)?
SELECT
  DATE_FORMAT(purchase_time, '%Y-%m-01') AS month_start,
  DATE_FORMAT(DATE_FORMAT(purchase_time, '%Y-%m-01'), '%Y-%m') AS month_label,
  COUNT(*) AS purchases_count
FROM transactions
WHERE refund_time IS NULL
GROUP BY DATE_FORMAT(purchase_time, '%Y-%m-01')
ORDER BY month_start;

-- Q2)  How many stores receive at least 5 orders/transactions in October 2020?
WITH oct_all AS (
  SELECT store_id
  FROM transactions
  WHERE purchase_time >= '2020-10-01' 
    AND purchase_time <  '2020-11-01'
)
SELECT COUNT(*) AS stores_with_5plus_incl_refunds
FROM (
  SELECT store_id, COUNT(*) AS cnt
  FROM oct_all
  GROUP BY store_id
  HAVING COUNT(*) >= 5
) s;

-- 2b) Exclude refunds
WITH oct_nonref AS (
  SELECT store_id
  FROM transactions
  WHERE purchase_time >= '2020-10-01' 
    AND purchase_time <  '2020-11-01'
    AND refund_time IS NULL
)
SELECT COUNT(*) AS stores_with_5plus_excl_refunds
FROM (
  SELECT store_id, COUNT(*) AS cnt
  FROM oct_nonref
  GROUP BY store_id
  HAVING COUNT(*) >= 5
) s;

-- Q3) For each store, what is the shortest interval (in min) from purchase to refund time?

SELECT
  store_id,
  MIN(TIMESTAMPDIFF(MINUTE, purchase_time, refund_time)) AS shortest_refund_minutes
FROM transactions
WHERE refund_time IS NOT NULL
GROUP BY store_id
ORDER BY store_id;

-- Q4) What is the gross_transaction_value of every store’s first order?

SELECT store_id, purchase_time, item_id, gross_transaction_value
FROM (
  SELECT
    store_id,
    purchase_time,
    item_id,
    gross_transaction_value,
    ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
) t
WHERE rn = 1
ORDER BY store_id;

-- Q5) What is the most popular item name that buyers order on their first purchase?

WITH first_by_buyer AS (
  SELECT
    buyer_id,
    store_id,
    item_id,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
)
SELECT i.item_name, COUNT(*) AS cnt_first_purchases
FROM first_by_buyer f
JOIN items i
  ON i.store_id = f.store_id AND i.item_id = f.item_id
WHERE rn = 1
GROUP BY i.item_name
ORDER BY cnt_first_purchases DESC
LIMIT 1;

-- Q6) Create a flag in the transaction items table indicating whether the refund can be processed or not. The condition for a refund to be processed is that 
--     it has to happen within 72 of Purchase time. Expected Output: Only 1 of the three refunds would be processed in this case

SELECT txn_id, buyer_id, store_id, item_id, purchase_time, refund_time, gross_transaction_value,
  CASE
    WHEN refund_time IS NOT NULL AND refund_time <= purchase_time + INTERVAL 72 HOUR THEN TRUE
    ELSE FALSE
  END AS refund_processable
FROM transactions
ORDER BY txn_id;

-- Q7) Create a rank by buyer_id column in the transaction items table and filter for only the second purchase per buyer. (Ignore refunds here) 
--     Expected Output: Only the second purchase of buyer_id 3 should the output

WITH ordered_purchases AS (
  SELECT
    txn_id, buyer_id, store_id, item_id, purchase_time, refund_time, gross_transaction_value,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS buyer_rank
  FROM transactions
  WHERE refund_time IS NULL
)
SELECT *
FROM ordered_purchases
WHERE buyer_rank = 2
ORDER BY buyer_id;

-- Q8) How will you find the second transaction time per buyer (don’t use min/max; assume there were more transactions per buyer in the table)
--     Expected Output: Only the second purchase of buyer_id along with a timestamp

SELECT buyer_id, purchase_time AS second_purchase_time
FROM (
  SELECT
    buyer_id,
    purchase_time,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
) t
WHERE rn = 2
ORDER BY buyer_id;