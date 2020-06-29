-- lesson 5. Part 1.
SHOW DATABASES;

USE shop_3;

/**********************************************************************************/
-- 1. ����� � ������� users ���� created_at � updated_at ��������� ��������������. ��������� �� �������� ����� � ��������.

SELECT * FROM users;

-- ��������� ��� ���� � ������� ���� ��������� �������������, ������� �������� NULL �������.
UPDATE users SET created_at = NULL 
  WHERE name = '��������' 
  OR name = '���������' 
  OR name = '����';

UPDATE users SET updated_at = NULL 
  WHERE name = '�������' 
  OR name = '������' 
  OR name = '�����';

-- �������� ����, � ������� ������� NULL ������� ��������.
UPDATE users SET created_at = CURRENT_TIMESTAMP() WHERE created_at IS NULL;
UPDATE users SET updated_at = CURRENT_TIMESTAMP() WHERE updated_at IS NULL;

-- ��������, ��� ��� ���� ���������.
SELECT * FROM users WHERE updated_at IS NULL;

/**********************************************************************************/
-- 2. ������� users ���� �������� ��������������. ������ created_at � updated_at ���� ������ ����� VARCHAR 
-- � � ��� ������ ����� ���������� �������� � ������� 20.10.2017 8:10. ���������� ������������� ���� � ���� DATETIME, 
-- �������� �������� ����� ��������.

DESC users;

SELECT * FROM users;

-- ������� �������������� ������, �� ����������� ��������, ������� ������� � ������.
-- �������� ������� created_at � updated_at � ���� VARCHAR.
ALTER TABLE users MODIFY COLUMN created_at VARCHAR(255);
ALTER TABLE users MODIFY COLUMN updated_at VARCHAR(255);

-- ���������� ������, ������� ������� ����� � �������� �������.
SELECT DATE_FORMAT(created_at, '%d.%m.%Y %k:%i') FROM users;

-- ���������� ������ ���� ��� ��������� ������� updated_at � created_at.
UPDATE users SET created_at = DATE_FORMAT(created_at, '%d.%m.%Y %k:%i');
UPDATE users SET updated_at = DATE_FORMAT(updated_at, '%d.%m.%Y %k:%i');

-- �� ������ ������ ������� ��� ������ �� ������� � �������.
INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES ('������', '1977-11-29', '20.10.2017 8:10', '20.10.2017 8:10');

-- ������ �� ���� �����, ������ � �������� �������.
SELECT STR_TO_DATE(created_at, '%d.%m.%Y %k:%i') FROM users;

UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i');
UPDATE users SET updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');

ALTER TABLE users MODIFY COLUMN created_at datetime;
ALTER TABLE users MODIFY COLUMN updated_at datetime;

/**********************************************************************************/
-- 3. � ������� ��������� ������� storehouses_products � ���� value ����� ����������� ����� ������ �����: 
-- 0, ���� ����� ���������� � ���� ����, ���� �� ������ ������� ������. ���������� ������������� ������ ����� �������, 
-- ����� ��� ���������� � ������� ���������� �������� value. ������ ������� ������ ������ ���������� � �����, ����� ���� �������.

DESC storehouses_products;

SELECT * FROM storehouses_products;

-- ��� ����, ����� ��������� ������� �������� ������� storehouses_products ����������. � ����� ������� ������������� ��� ������� �� ������� ��������.
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES
  (1, 1, CEIL(RAND() * 100)),
  (1, 2, CEIL(RAND() * 100)),
  (2, 3, CEIL(RAND() * 100)),
  (2, 4, CEIL(RAND() * 100)),
  (3, 5, CEIL(RAND() * 100)),
  (4, 6, CEIL(RAND() * 100)),
  (4, 7, CEIL(RAND() * 100)),
  (5, 8, 0),
  (5, 9, 0);
  
-- ����������� ���, ��� ������� � ������� (�� ����������� � ������� �������� � �����).
SELECT * FROM storehouses_products ORDER BY value IS FALSE, value;

/**********************************************************************************/
-- 4. (�� �������) �� ������� users ���������� ������� �������������, ���������� � ������� � ���. 
-- ������ ������ � ���� ������ ���������� �������� (may, august)

SELECT name FROM users WHERE MONTHNAME(birthday_at) = 'may' OR MONTHNAME(birthday_at) = 'august';

/**********************************************************************************/
-- 5. (�� �������) �� ������� catalogs ����������� ������ ��� ������ �������. SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
-- ������������ ������ � �������, �������� � ������ IN.

SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);

-- lesson 5. Part 2.

/**********************************************************************************/
-- 1. ����������� ������� ������� ������������� � ������� users.

SELECT AVG(FLOOR(YEAR(NOW()) - YEAR(birthday_at))) AS 'AVERAGE AGE' FROM users;
-- ������� ������� - 30,5 ���.

/**********************************************************************************/
-- 2. ����������� ���������� ���� ��������, ������� ���������� �� ������ �� ���� ������. 
-- ������� ������, ��� ���������� ��� ������ �������� ����, � �� ���� ��������.

SELECT DAYNAME(CONCAT(YEAR(NOW()), DATE_FORMAT(birthday_at, '-%m-%d'))) AS BORN_AT, COUNT(*) AS TIMES FROM users GROUP BY BORN_AT;

/**********************************************************************************/
-- 3. (�� �������) ����������� ������������ ����� � ������� �������.
-- ��� �������� ������������ � ������� ������� ������� value � ������� storehouses_products.

SELECT value FROM storehouses_products;

-- ������� ������� �������� �� ���������, ����� ������������ ����� ����� ���������. 
-- ��� ������� ����������� ������� � ��������� �������� �� ������� (������ 10).
UPDATE storehouses_products SET value = CEIL(RAND() * 10);

-- ������ �������� ������������ ���� �������� � �������.
SELECT FLOOR(EXP(SUM(LOG(value)))) AS mul FROM storehouses_products;