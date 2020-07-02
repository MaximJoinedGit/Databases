USE vk;

SHOW TABLES;

/**********************************************************************************/
-- users
DESC users;

SELECT * FROM users LIMIT 10;

-- �������� �������� updated_at, ���� ��� ������ created_at.
UPDATE media SET updated_at  = CURRENT_TIMESTAMP() WHERE created_at > updated_at;

-- ��������. �� ������ ������ ������������.
SELECT * FROM users WHERE created_at > updated_at;

/**********************************************************************************/
-- profiles
DESC profiles;

SELECT * FROM profiles LIMIT 10;

-- �������� �������� ���� ��������, ���� ������������ ������� �������.
UPDATE profiles SET birthday = FROM_UNIXTIME(RAND() * (UNIX_TIMESTAMP('2014-12-31') - UNIX_TIMESTAMP('1970-01-01'))) 
WHERE birthday > '2014-12-31';

-- �������� �������� created_at, ���� ������� ����� ���� ��� �� ���� ��������.
UPDATE profiles SET created_at = DATE_ADD(birthday, INTERVAL 5 YEAR) WHERE birthday >= created_at;

-- �������� �������� updated_at, ���� ��� ������ created_at.
UPDATE media SET updated_at  = CURRENT_TIMESTAMP() WHERE created_at > updated_at;

-- ��������. �� ������ ������ ������������. 
-- ������������ �� ����� 2015 �.�. ������������, �������� ������ ���� ������� ����� ��� ��������, ��������� ����� ��������.
SELECT * FROM profiles WHERE birthday > '2014-12-31';
SELECT * FROM profiles WHERE birthday >= created_at;
SELECT * FROM profiles WHERE created_at > updated_at;

/**********************************************************************************/
-- messages
DESC messages;

SELECT * FROM messages LIMIT 10;

-- �������� �������� from_user_id �� ��������� � ��������� �� 1 �� 300.
UPDATE messages SET from_user_id = CEIL(RAND() * 300);

-- ����� ������ ������ ��� ��������� ���� ���������� ������������� ������ ����.
SELECT * FROM messages WHERE from_user_id = to_user_id;

-- �������� �� �����������, ��������� ����� ����� �������� � ������� from_user_id ��������� �������� � ������� updated_at �� ������� �����.

/**********************************************************************************/
-- media
DESC media;

SELECT * FROM media LIMIT 10;

UPDATE media SET updated_at  = CURRENT_TIMESTAMP() WHERE created_at > updated_at;

-- ��������. �� ������ ������ ������������.
SELECT * FROM media WHERE created_at > updated_at;

CREATE TEMPORARY TABLE extensions (name VARCHAR(10));

INSERT INTO extensions VALUES ('.jpeg'), ('.gif'), ('.avi'), ('.mpeg'), ('.mp3'), ('.aac'); 

UPDATE media SET filename = CONCAT(
  'https://dropbox.com/vk/',
  filename,
  (SELECT name FROM extensions ORDER BY RAND() LIMIT 1));

UPDATE media SET `size` = CEIL(RAND() * 100000000) WHERE `size` < 10000;

UPDATE media SET metadata = CONCAT('{"owner":"',
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE users.id = media.user_id),
  '"}');
 
 ALTER TABLE media MODIFY COLUMN metadata JSON;

/**********************************************************************************/
-- media_types
DESC media_types;

SELECT * FROM media_types;

UPDATE media_types SET updated_at = CURRENT_TIMESTAMP() WHERE created_at > updated_at;

-- ��������. �� ������ ������ ������������. 
SELECT * FROM profiles WHERE created_at > updated_at;

/**********************************************************************************/
-- friendship

DESC friendship;

ALTER TABLE friendship DROP COLUMN requested_at;

SELECT * FROM friendship LIMIT 10;

UPDATE friendship SET user_id = CEIL(RAND() * 300);

UPDATE friendship SET status_id = CEIL(RAND() * 3);

UPDATE friendship SET confirmed_at = created_at WHERE confirmed_at < created_at;

/**********************************************************************************/
-- friendship-statuses

SELECT * FROM friendship_statuses;

TRUNCATE friendship_statuses;

INSERT INTO friendship_statuses (name) VALUES ('requested'), ('confirmed'), ('rejected');

/**********************************************************************************/
-- communities

DESC communities;

SELECT * FROM communities LIMIT 10;

UPDATE communities SET updated_at = CURRENT_TIMESTAMP() WHERE created_at > updated_at;

/**********************************************************************************/
-- communities-users

DESC communities_users;

SELECT * FROM communities_users LIMIT 10;
