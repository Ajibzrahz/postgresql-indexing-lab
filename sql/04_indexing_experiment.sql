
-- ==========================================
-- 1. CREATE INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_tickets_user_id
ON tickets (user_id);

CREATE INDEX IF NOT EXISTS idx_tickets_user_category
ON tickets (user_id, category DESC);

ANALYZE tickets;


-- ==========================================
-- 2. COMPARE SEQUENTIAL SCAN AND INDEX SCAN
-- ==========================================

-- User with 50,000 tickets
EXPLAIN ANALYZE
SELECT *
FROM tickets
WHERE user_id = 'ff25e139-86de-4166-8810-f05f3475200b';

-- User with 1,000 tickets
EXPLAIN ANALYZE
SELECT *
FROM tickets
WHERE user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4';


-- ==========================================
-- 3. TEST THE COMPOSITE INDEX
-- ==========================================

-- Remove the single-column index temporarily
DROP INDEX IF EXISTS idx_tickets_user_id;

ANALYZE tickets;

-- PostgreSQL can use the composite index
-- because user_id is its leading column
EXPLAIN ANALYZE
SELECT *
FROM tickets
WHERE user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4';


-- ==========================================
-- 4. TEST INDEX ORDERING
-- ==========================================

-- Observe the planner's natural choice
EXPLAIN ANALYZE
SELECT *
FROM tickets
WHERE user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4'
ORDER BY category DESC;


-- Temporarily discourage bitmap and sequential scans
-- to demonstrate the composite index's ordering capability

SET enable_bitmapscan = OFF;
SET enable_seqscan = OFF;

EXPLAIN ANALYZE
SELECT *
FROM tickets
WHERE user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4'
ORDER BY category DESC;

-- Restore normal planner settings
RESET enable_bitmapscan;
RESET enable_seqscan;


-- ==========================================
-- 5. RESTORE THE SINGLE-COLUMN INDEX
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_tickets_user_id
ON tickets (user_id);

ANALYZE tickets;
