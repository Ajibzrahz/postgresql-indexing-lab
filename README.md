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

Observed:

- PostgreSQL chose a Sequential Scan when retrieving 50,000 of the 51,000 records.
- PostgreSQL chose an Index Scan when retrieving 1,000 records.

This demonstrated that PostgreSQL considers the estimated cost of retrieving matching records when choosing an execution plan.

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