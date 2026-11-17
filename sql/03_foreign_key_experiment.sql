
-- Check how many tickets Demo User 2 owns
SELECT COUNT(*) AS tickets_before
FROM tickets
WHERE user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4';

BEGIN;

-- Delete the parent user
DELETE FROM users
WHERE id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4';

-- Check the tickets after deletion
-- ON DELETE CASCADE should have deleted them too
SELECT COUNT(*) AS tickets_after
FROM tickets
WHERE user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4';

-- Restore the deleted user and tickets
ROLLBACK;

-- Verify that the tickets have been restored
SELECT COUNT(*) AS tickets_after_rollback
FROM tickets
WHERE user_id = 'a7c1297c-90a4-4a81-937e-c5a802f686e4';
