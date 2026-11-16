-- Adds coaches Santhosh ID and Sean Cleatus, plus players Player One and Player Two.
-- Safe to run more than once: existing emails / mobiles are skipped.
-- Coach sign-in password: Coach@123

BEGIN;

INSERT INTO users (email, password_hash, role, is_active, is_logged_in)
SELECT v.email,
       '$2b$12$HViWxYt0T4BkLHqGictXC.Qj6NkeyPhMULlKIP22w77i7pH1kaqqm',
       'COACH'::userrole,
       true,
       false
FROM (VALUES
        ('santhosh.id@idsports.com', '9961861588'),
        ('sean.cleatus@idsports.com', '9731335300')
     ) AS v(email, mobile)
WHERE NOT EXISTS (SELECT 1 FROM users u WHERE lower(u.email) = v.email)
  AND NOT EXISTS (SELECT 1 FROM coaches c WHERE right(c.mobile, 10) = v.mobile);

INSERT INTO coaches (user_id, admin_id, name, mobile)
SELECT u.user_id,
       (SELECT admin_id FROM super_admins ORDER BY admin_id LIMIT 1),
       v.name,
       v.mobile
FROM (VALUES
        ('Santhosh ID', '9961861588', 'santhosh.id@idsports.com'),
        ('Sean Cleatus', '9731335300', 'sean.cleatus@idsports.com')
     ) AS v(name, mobile, email)
JOIN users u ON lower(u.email) = v.email
WHERE NOT EXISTS (SELECT 1 FROM coaches c WHERE c.user_id = u.user_id)
  AND NOT EXISTS (SELECT 1 FROM coaches c WHERE right(c.mobile, 10) = v.mobile);

INSERT INTO students (admin_id, name, first_name, last_name, mobile, parent_mobile, jersey, fee_status)
SELECT (SELECT admin_id FROM super_admins ORDER BY admin_id LIMIT 1),
       v.name,
       v.first_name,
       v.last_name,
       v.mobile,
       v.mobile,
       v.jersey,
       'PAID'::billstatus
FROM (VALUES
        ('Player One', 'Player', 'One', '9000000101', '19'),
        ('Player Two', 'Player', 'Two', '9000000102', '20')
     ) AS v(name, first_name, last_name, mobile, jersey)
WHERE NOT EXISTS (
    SELECT 1 FROM students s
    WHERE right(s.mobile, 10) = v.mobile OR right(s.parent_mobile, 10) = v.mobile
);

COMMIT;

SELECT 'coach' AS kind, c.name, c.mobile, u.email
FROM coaches c JOIN users u ON u.user_id = c.user_id
WHERE right(c.mobile, 10) IN ('9961861588', '9731335300')
UNION ALL
SELECT 'player', s.name, s.mobile, NULL
FROM students s
WHERE right(s.mobile, 10) IN ('9000000101', '9000000102');
