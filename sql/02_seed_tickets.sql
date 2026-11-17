
BEGIN;

-- Generate 50,000 tickets for Demo User 1
INSERT INTO tickets (user_id, category, status)
SELECT
    'ff25e139-86de-4166-8810-f05f3475200b'::uuid,
    (ARRAY['plumbing', 'electrical', 'furniture', 'other'])
        [1 + floor(random() * 4)::int],
    'open'
FROM generate_series(1, 50000);

-- Generate 1,000 tickets for Demo User 2
INSERT INTO tickets (user_id, category, status)
SELECT
    'a7c1297c-90a4-4a81-937e-c5a802f686e4'::uuid,
    (ARRAY['plumbing', 'electrical', 'furniture', 'other'])
        [1 + floor(random() * 4)::int],
    'open'
FROM generate_series(1, 1000);

COMMIT;

-- Refresh query planner statistics
ANALYZE tickets;
