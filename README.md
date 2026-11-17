# PostgreSQL Indexing Lab

A hands-on PostgreSQL project exploring relational database fundamentals, foreign key constraints, cascading deletes, B-tree indexes, composite indexes, and query execution plans using PostgreSQL and Node.js.

## Overview

This project was built to develop a practical understanding of how PostgreSQL manages relational data and executes queries.

I created a simple users-and-tickets database, generated 51,000 ticket records, and experimented with different indexing strategies using `EXPLAIN ANALYZE`.

The goal was to understand how PostgreSQL's query planner chooses between sequential scans, index scans, and bitmap scans.

## Technologies Used

- PostgreSQL
- Node.js
- Express.js
- `pg` (node-postgres)
- dotenv
- SQL

## Database Structure

The project contains two relational tables:

### Users

| Column | Type | Constraint |
|---|---|---|
| id | UUID | Primary Key |
| name | TEXT | NOT NULL |
| email | TEXT | UNIQUE, NOT NULL |

### Tickets

| Column | Type | Constraint |
|---|---|---|
| id | UUID | Primary Key |
| user_id | UUID | Foreign Key |
| category | TEXT | NOT NULL |
| status | TEXT | NOT NULL, DEFAULT 'open' |

The `tickets.user_id` column references `users.id` with `ON DELETE CASCADE`.

This ensures that deleting a user automatically deletes their associated tickets.

## Dataset

I generated 51,000 ticket records using PostgreSQL's `generate_series()` and `random()` functions.

| User | Number of Tickets |
|---|---:|
| Demo User 1 | 50,000 |
| Demo User 2 | 1,000 |
| **Total** | **51,000** |

Ticket categories include plumbing, electrical, furniture, and other.

## Experiments

### 1. Foreign Key Constraints and Cascading Deletes

Tested the relationship between users and tickets using a foreign key constraint.

Verified that `ON DELETE CASCADE` automatically removes associated tickets when a user is deleted.

Used transactions and `ROLLBACK` to restore the test data after the experiment.

### 2. Sequential Scan vs. Index Scan

Created a B-tree index on `tickets.user_id`:

```sql
CREATE INDEX idx_tickets_user_id
ON tickets (user_id);
```

Used `EXPLAIN ANALYZE` to compare queries retrieving tickets belonging to users with different record counts.

**Query 1: Retrieve 50,000 tickets**

```sql
EXPLAIN ANALYZE
SELECT *
FROM tickets
WHERE user_id = 'ff25e139-86de-4166-8810-f05f3475200b';
```

Actual execution plan:

```text
Seq Scan on tickets
(cost=0.00..1582.50 rows=49990 width=45)
(actual time=0.423..7.505 rows=50000 loops=1)

Filter: (user_id = 'ff25e139-86de-4166-8810-f05f3475200b'::uuid)
Rows Removed by Filter: 1000

Planning Time: 0.262 ms
Execution Time: 8.975 ms
```

PostgreSQL chose a Sequential Scan because the query returned 50,000 out of 51,000 records (approximately 98% of the table).

**Query 2: Retrieve 1,000 tickets**

```sql
EXPLAIN ANALYZE
SELECT *
FROM tickets
WHERE user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4';
```

Actual execution plan:

```text
Index Scan using idx_tickets_user_id on tickets
(cost=0.29..621.31 rows=1010 width=45)
(actual time=0.030..0.157 rows=1000 loops=1)

Index Cond: (user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4'::uuid)

Planning Time: 0.112 ms
Execution Time: 0.192 ms
```

PostgreSQL chose an Index Scan because only 1,000 out of 51,000 records matched the condition (approximately 2% of the table).

**Comparison**

| Metric | 50,000 tickets | 1,000 tickets |
|---|---:|---:|
| Scan type | Sequential Scan | Index Scan |
| Actual rows | 50,000 | 1,000 |
| Execution time | 8.975 ms | 0.192 ms |
| Rows removed | 1,000 | 0 |

**Observation:** Having an index does not guarantee PostgreSQL will use it. The query planner estimates the cost of available execution strategies and chooses what it considers the most efficient plan.

These are two different queries returning different numbers of records, so their execution times should not be interpreted as a controlled before-and-after index performance comparison.

### 3. Composite Indexes

Created a composite index:

```sql
CREATE INDEX idx_tickets_user_category
ON tickets (user_id, category DESC);
```

Dropped the single-column index temporarily and observed that PostgreSQL could still use the composite index for queries filtering by `user_id`.

This demonstrated the importance of column order in composite B-tree indexes.

### 4. Index Ordering and Sorting

Tested:

```sql
SELECT *
FROM tickets
WHERE user_id = 'some-user-id'
ORDER BY category DESC;
```

Observed that PostgreSQL initially selected a Bitmap Heap Scan followed by a Sort operation.

After temporarily disabling bitmap and sequential scans, PostgreSQL selected an Index Scan using the composite index, eliminating the separate Sort operation.

This demonstrated how a composite index can support both filtering and ordering when its column order matches the query.

## Key Learnings

Through this project, I gained practical experience with:

- Relational database design and foreign keys.
- Cascading deletes and referential integrity.
- SQL transactions, COMMIT, and ROLLBACK.
- Bulk data generation using `generate_series()`.
- B-tree and composite indexes.
- Sequential Scan, Index Scan, and Bitmap Heap Scan.
- Query execution plans using `EXPLAIN ANALYZE`.
- PostgreSQL query planner decisions.
- How composite index column order affects query performance.
- Why indexes do not automatically make every query faster.

## Project Structure

```text
postgresql-indexing-lab/
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed_tickets.sql
│   ├── 03_foreign_key_experiment.sql
│   └── 04_indexing_experiment.sql
├── src/
│   ├── database.js
│   └── main.js
├── .env.example
├── .gitignore
├── package.json
└── README.md
```

## Getting Started

### Prerequisites

- Node.js
- PostgreSQL
- npm
- pgAdmin or another PostgreSQL client

### 1. Clone the repository

```bash
git clone https://github.com/Ajibzrahz/postgresql-indexing-lab.git
cd postgresql-indexing-lab
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment variables

Create a `.env` file using `.env.example` as a reference.

```env
DATABASE_PASSWORD=your_postgresql_password
```

Update the database connection configuration in `src/database.js` if your PostgreSQL host, port, username, or database name differs.

### 4. Create a PostgreSQL database

Create an empty database, for example:

```text
postgresql_indexing_lab
```

### 5. Execute the SQL scripts

Run the SQL files in this order using pgAdmin or another PostgreSQL client:

1. `01_schema.sql`
2. `02_seed_tickets.sql`
3. `03_foreign_key_experiment.sql`
4. `04_indexing_experiment.sql`

The seed script generates 51,000 ticket records.

### 6. Start the Node.js application

```bash
node src/main.js
```

The application connects to PostgreSQL and exposes basic ticket-related endpoints.

## Future Improvements

- Add more query performance experiments.
- Compare different composite index configurations.
- Explore `EXPLAIN (ANALYZE, BUFFERS)`.
- Implement pagination and filtering endpoints.
- Explore database transactions through Node.js.

## Author

**Ajibona Raheem**

Backend Developer | Node.js | TypeScript | PostgreSQL

[GitHub](https://github.com/Ajibzrahz) | [LinkedIn](https://www.linkedin.com/in/raheem-ajibona)