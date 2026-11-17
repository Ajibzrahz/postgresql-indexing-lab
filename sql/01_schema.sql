
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);

-- Tickets table
CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open'
);

-- Seed demo users
INSERT INTO users (id, name, email)
VALUES
    (
        'ff25e139-86de-4166-8810-f05f3475200b',
        'Demo User 1',
        'user1@example.com'
    ),
    (
        'a7c1297c-90a4-4a81-937e-c5a802f686e4',
        'Demo User 2',
        'user2@example.com'
    );
