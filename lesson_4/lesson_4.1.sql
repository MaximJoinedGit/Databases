USE vk;

SHOW TABLES;

/**********************************************************************************/
-- users
DESC users;

SELECT * FROM users LIMIT 10;

-- Поменяем значение updated_at, если оно меньше created_at.
UPDATE media SET updated_at  = CURRENT_TIMESTAMP() WHERE created_at > updated_at;

-- Проверка. Не должно ничего отобразиться.
SELECT * FROM users WHERE created_at > updated_at;

/**********************************************************************************/
-- profiles
DESC profiles;

SELECT * FROM profiles LIMIT 10;

-- Поменяем значение даты рождения, если пользователь слишком молодой.
UPDATE profiles SET birthday = FROM_UNIXTIME(RAND() * (UNIX_TIMESTAMP('2014-12-31') - UNIX_TIMESTAMP('1970-01-01'))) 
WHERE birthday > '2014-12-31';

-- Поменяем значение created_at, если создано менее пяти лет от даты рождения.
UPDATE profiles SET created_at = DATE_ADD(birthday, INTERVAL 5 YEAR) WHERE birthday >= created_at;

-- Поменяем значение updated_at, если оно меньше created_at.
UPDATE media SET updated_at  = CURRENT_TIMESTAMP() WHERE created_at > updated_at;

-- Проверка. Не должно ничего отобразиться. 
-- Пользователь не позже 2015 г.р. включительно, страница должна быть создана после дня рождения, обновлена после создания.
SELECT * FROM profiles WHERE birthday > '2014-12-31';
SELECT * FROM profiles WHERE birthday >= created_at;
SELECT * FROM profiles WHERE created_at > updated_at;

/**********************************************************************************/
-- messages
DESC messages;

SELECT * FROM messages LIMIT 10;

-- Поменяем значения from_user_id на случайные в диапазоне от 1 до 300.
UPDATE messages SET from_user_id = CEIL(RAND() * 300);

-- После замены только два сообщения были отправлены пользователем самому себе.
SELECT * FROM messages WHERE from_user_id = to_user_id;

-- Проверка не обязательна, поскольку после смены значений в столбце from_user_id сменилось значение в столбце updated_at на текущее время.

/**********************************************************************************/
-- media
DESC media;

SELECT * FROM media LIMIT 10;

UPDATE media SET updated_at  = CURRENT_TIMESTAMP() WHERE created_at > updated_at;

-- Проверка. Не должно ничего отобразиться.
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

-- Проверка. Не должно ничего отобразиться. 
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
