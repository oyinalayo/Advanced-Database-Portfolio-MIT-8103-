# Advanced Database Portfolio - ShopBeta

**Student:** Oyindamola
**Student ID:** 2026/A/MIT/0063
**Course:** MIT 8103 Advanced Database Systems
**Session:** 2026/2027, First Semester

## Case Study
ShopBeta is a simulated online marketplace based in Lagos, Nigeria, inspired by multi-seller platforms such as Jumia. Independent sellers list products and customers buy them online, with ShopBeta handling payment and delivery. All data is synthetic and generated for this project.
- **Nature of business:** multi-seller online marketplace selling electronics, fashion and home items
- **Users of the database:** customers, sellers, delivery staff, administrators
- **Major data stored:** products, categories, sellers, customers and addresses, orders and order items, payments, deliveries, stock
- **Key operations:** add products, place orders, update stock, process payment, track delivery

## Tools Used
- PostgreSQL 17 with pgAdmin
- MongoDB 6.0.5 with MongoDB Compass and mongosh.
- Git and GitHub

## Repository Structure
| Folder | Contents | Status |
|---|---|---|
| [portfolio-1-database-design](portfolio-1-database-design) | ER diagram, schema, normalisation | Completed |
| [portfolio-2-query-optimisation](portfolio-2-query-optimisation) | Queries, execution plans, indexes | Completed |
| [portfolio-3-transactions-concurrency](portfolio-3-transactions-concurrency) | Transaction and locking demos | Completed |
| [portfolio-4-nosql](portfolio-4-nosql) | MongoDB model and scripts | Completed |
| [portfolio-5-distributed-cloud](portfolio-5-distributed-cloud) | Replication, sharding, availability, partitioning demo  | Completed |

## How to Run
1. **Portfolio 1:** create a PostgreSQL database named `shopbeta` and run `portfolio-1-database-design/Schema.sql`.
2. **Portfolio 2:** run `portfolio-2-query-optimisation/generate_data.sql`, then the queries in `queries.sql` one block at a time.
3. **Portfolio 3:** run the examples in `portfolio-3-transactions-concurrency/transactions_concurrency.sql`. The concurrency tests need two separate sessions.
4. **Portfolio 4:** paste `portfolio-4-nosql/seed_data.js` into mongosh, then run the queries in that folder's README.
5. **Portfolio 5:** run `portfolio-5-distributed-cloud/partitioning_demo.sql` after the orders data exists.

   Each folder has its own README with the evidence and explanations.

## AI Use Declaration
**Tool used:** Claude (Anthropic).

**Purpose of use:** AI was used as a support tool for explaining technical concepts, suggesting SQL and MongoDB script approaches, generating synthetic data scripts, and troubleshooting errors.

**Implementation and Verification:** The assignment involved the development and execution of database scripts, generation and testing of data, review of execution plans, validation of outputs, and preparation of the final documentation. All scripts were executed locally using PostgreSQL 17 and MongoDB 6.0.5. AI suggestions were reviewed, adapted, and corrected where necessary.
