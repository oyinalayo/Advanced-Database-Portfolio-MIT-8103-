# Portfolio 3: Transactions and Concurrency

## 1. Purpose
This portfolio shows how transactions keep ShopBeta's data correct when an order is placed, when something fails, and when several customers act at the same time. All scripts are in `transactions_concurrency.sql`.

## 2. Successful transaction (COMMIT)
Placing an order involves several steps: create the order, add the items, reduce stock, record the payment and mark the order paid. All steps run inside one transaction.

- Orders before: [number], after: [number]
- Stock of product 1 before: [number], after: [number]

![Commit success](_commit_success.png)

Executing COMMIT permanently saved every step of the checkout process—from creating the order to updating stock and recording the payment—into the database all at once. Because all five queries succeeded inside the transaction, the changes took effect together as a single complete unit without leaving any partial data behind.

## 3. Failed transaction (ROLLBACK)
I tried to buy 50 units when only [number] were in stock. The CHECK constraint rejected the stock update, so I rolled the transaction back.

![Rollback](12_p3_rollback.png)

[Two sentences in your own words: what happened to the order that was created before the error, and why.]

## 4. Concurrency problem: lost update
Two customers each bought 1 unit of product 3 at the same time. Stock started at 10 and should have ended at 8.

- Without protection, final stock: [number]
- With `SELECT ... FOR UPDATE`, final stock: [number]

![Lost update](13_p3_lost_update.png)
![Fixed with row lock](14_p3_for_update.png)

[Your explanation: why both tabs read 10, and how the lock made the second tab wait.]

## 5. Isolation levels

| Level | First read | Second read (same transaction) | Meaning |
|---|---|---|---|
| READ COMMITTED | [ ] | [ ] | [ ] |
| REPEATABLE READ | [ ] | [ ] | [ ] |

![Isolation levels](15_p3_isolation.png)

## 6. Conclusion
[Two or three sentences: why transactions matter, what the lock prevents, and what trade-off locking has.]
