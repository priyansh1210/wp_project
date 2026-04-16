-- The Archive Co. Library Portal - Schema Update
-- Run this against the library_portal database

USE library_portal;

-- ============================================
-- 1. Update admin table - add columns safely
-- ============================================
-- Use a procedure to safely add columns
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS safe_alter()
BEGIN
    -- admin: username
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='admin' AND COLUMN_NAME='username') THEN
        ALTER TABLE admin ADD COLUMN username VARCHAR(50) UNIQUE AFTER name;
    END IF;
    -- admin: first_name
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='admin' AND COLUMN_NAME='first_name') THEN
        ALTER TABLE admin ADD COLUMN first_name VARCHAR(50) AFTER name;
    END IF;
    -- admin: last_name
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='admin' AND COLUMN_NAME='last_name') THEN
        ALTER TABLE admin ADD COLUMN last_name VARCHAR(50) AFTER first_name;
    END IF;
    -- admin: contact_no
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='admin' AND COLUMN_NAME='contact_no') THEN
        ALTER TABLE admin ADD COLUMN contact_no VARCHAR(20) AFTER email;
    END IF;
    -- members: username
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='members' AND COLUMN_NAME='username') THEN
        ALTER TABLE members ADD COLUMN username VARCHAR(50) UNIQUE AFTER name;
    END IF;
    -- members: contact_no
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='members' AND COLUMN_NAME='contact_no') THEN
        ALTER TABLE members ADD COLUMN contact_no VARCHAR(20) AFTER email;
    END IF;
    -- books: language
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='books' AND COLUMN_NAME='language') THEN
        ALTER TABLE books ADD COLUMN language VARCHAR(50) DEFAULT 'English' AFTER genre;
    END IF;
    -- books: added_by
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='books' AND COLUMN_NAME='added_by') THEN
        ALTER TABLE books ADD COLUMN added_by INT AFTER available;
    END IF;
END //
DELIMITER ;

CALL safe_alter();
DROP PROCEDURE IF EXISTS safe_alter;

-- Migrate data
UPDATE admin SET first_name = name WHERE first_name IS NULL;
UPDATE admin SET last_name = '' WHERE last_name IS NULL;
UPDATE admin SET username = email WHERE username IS NULL;
UPDATE members SET username = email WHERE username IS NULL;

-- ============================================
-- 2. Create branches table
-- ============================================
CREATE TABLE IF NOT EXISTS branches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  contact_no VARCHAR(20),
  location VARCHAR(200),
  added_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. Insert sample branch
-- ============================================
INSERT IGNORE INTO branches (name, contact_no, location) VALUES
('The Archive Co. - Main', '0412410984', 'Bengaluru');

-- ============================================
-- 4. Update borrow_history for return approval flow
-- ============================================
ALTER TABLE borrow_history MODIFY COLUMN status ENUM('BORROWED','RETURN_PENDING','RETURNED','REJECTED') DEFAULT 'BORROWED';

-- Add reject_message column if not exists
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS safe_alter_borrow()
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='library_portal' AND TABLE_NAME='borrow_history' AND COLUMN_NAME='reject_message') THEN
        ALTER TABLE borrow_history ADD COLUMN reject_message VARCHAR(255) DEFAULT NULL;
    END IF;
END //
DELIMITER ;
CALL safe_alter_borrow();
DROP PROCEDURE IF EXISTS safe_alter_borrow;

SELECT 'Schema update completed successfully!' AS result;
