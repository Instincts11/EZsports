-- Adds coaches Santhosh ID and Sean Cleatus, plus players Arjun Menon and Diya Nair.
-- Safe to run more than once: existing emails / mobiles are skipped.
-- Coach sign-in password: coach123

BEGIN;

INSERT INTO users (email, password_hash, role, is_active, is_logged_in)
SELECT v.email,
       '$2b$12$V4gzzhnbejJLjfgIRj9PH.BiixsCJeLAgA0Ik2ubK3U1OXgpi6BQW',
       'COACH'::userrole,
       true,
       false
FROM (VALUES
        ('santhosh.id@idsports.com', '9961861588'),
        ('sean.cleatus@idsports.com', '9731335300')
     ) AS v(email, mobile)
WHERE NOT EXISTS (SELECT 1 FROM users u WHERE lower(u.email) = v.email)
  AND NOT EXISTS (SELECT 1 FROM coaches c WHERE right(c.mobile, 10) = v.mobile);

INSERT INTO coaches (user_id, admin_id, name, mobile, headline, experience)
SELECT u.user_id,
       (SELECT admin_id FROM super_admins ORDER BY admin_id LIMIT 1),
       v.name,
       v.mobile,
       v.headline,
       v.experience
FROM (VALUES
        ('Santhosh ID', '9961861588', 'santhosh.id@idsports.com', 'Head coach', '8 years'),
        ('Sean Cleatus', '9731335300', 'sean.cleatus@idsports.com', 'Assistant coach', '5 years')
     ) AS v(name, mobile, email, headline, experience)
JOIN users u ON lower(u.email) = v.email
WHERE NOT EXISTS (SELECT 1 FROM coaches c WHERE c.user_id = u.user_id)
  AND NOT EXISTS (SELECT 1 FROM coaches c WHERE right(c.mobile, 10) = v.mobile);

INSERT INTO students (
  admin_id, name, first_name, last_name, dob, gender, mobile, parent_mobile,
  guardian_name, position, preferred_foot, school, school_class, jersey, fee_status
)
SELECT (SELECT admin_id FROM super_admins ORDER BY admin_id LIMIT 1),
       v.name,
       v.first_name,
       v.last_name,
       v.dob,
       v.gender,
       v.mobile,
       v.parent_mobile,
       v.guardian_name,
       v.position,
       v.preferred_foot,
       v.school,
       v.school_class,
       v.jersey,
       'PAID'::billstatus
FROM (VALUES
        ('Arjun Menon', 'Arjun', 'Menon', '12 Mar 2012', 'Male', '9000000101', '9847010101',
         'Ravi Menon', 'Midfielder', 'Right', 'Esperanza Public', '8', '7'),
        ('Diya Nair', 'Diya', 'Nair', '5 Aug 2013', 'Female', '9000000102', '9847020202',
         'Meera Nair', 'Forward', 'Left', 'St. Mary''s', '7', '9')
     ) AS v(name, first_name, last_name, dob, gender, mobile, parent_mobile,
            guardian_name, position, preferred_foot, school, school_class, jersey)
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
