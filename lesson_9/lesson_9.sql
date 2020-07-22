-- Lesson 9.
-- Транзакции, переменные, представления.

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

-- Для того, чтобы перенести строчку из одной таблицы в другую проверим для начала совместимость этих таблиц.
USE shop;

DESC users;

SELECT * FROM users;

USE sample;

DESC users;

SELECT * FROM users;

/* Таблицы не совместимы. В БД sample таблица users отличается от аналогичной, которая лежит в БД shop. 
 Таблица, которая находится в БД sample не содержит данных, связей и является единственной таблицей в данной БД. 
 Мы можем смело ее удалить и создать новую, которая по структуре будет идентична таблице users из БД shop. */

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

-- Теперь мы имеем таблицу, аналогичную users в БД shop. Можем приступить к переносу.

START TRANSACTION;

INSERT
	INTO
	sample.users (
	SELECT
		*
	FROM
		shop.users
	WHERE
		id = 1);

SELECT * FROM users;

DELETE FROM shop.users WHERE id = 1;

SELECT * FROM shop.users;

-- Строка была сначала вставлена в таблицу в БД sample, а затем удалена из БД shop. Завершаем транзакцию.
COMMIT;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

USE shop;

SHOW TABLES;

SELECT * FROM products;

CREATE OR REPLACE
VIEW goods AS
SELECT
	p.name AS `Product`,
	c.name AS `Catalogue ID`
FROM
	products p
LEFT JOIN catalogs c ON
	p.catalog_id = c.id;

SELECT * FROM goods;

-- 3. 3. (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи 
-- за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август, 
-- выставляя в соседнем поле значение 1, если дата присутствует в исходной таблице и 0, если она отсутствует.

CREATE TABLE IF NOT EXISTS posts_9 (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATE NOT NULL
);

INSERT INTO posts_9 VALUES
(NULL, 'первая запись', '2018-08-01'),
(NULL, 'вторая запись', '2018-08-04'),
(NULL, 'третья запись', '2018-08-16'),
(NULL, 'четвертая запись', '2018-08-17');

CREATE TEMPORARY TABLE last_days (
  day INT
);

INSERT INTO last_days VALUES
(0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(11), (12), (13), (14), (15), (16), (17), (18), (19), (20),
(21), (22), (23), (24), (25), (26), (27), (28), (29), (30);

SELECT
  DATE(DATE('2018-08-31') - INTERVAL l.day DAY) AS day,
  NOT ISNULL(p.name) AS order_exist
FROM
  last_days AS l
LEFT JOIN
  posts_9 AS p
ON
  DATE(DATE('2018-08-31') - INTERVAL l.day DAY) = p.created_at
ORDER BY
  day;

DROP TABLE IF EXISTS posts_9;

-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, 
-- который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

DROP TABLE IF EXISTS posts;
CREATE TABLE IF NOT EXISTS posts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATE NOT NULL
);

INSERT INTO posts VALUES
(NULL, 'первая запись', '2018-11-01'),
(NULL, 'вторая запись', '2018-11-02'),
(NULL, 'третья запись', '2018-11-03'),
(NULL, 'четвертая запись', '2018-11-04'),
(NULL, 'пятая запись', '2018-11-05'),
(NULL, 'шестая запись', '2018-11-06'),
(NULL, 'седьмая запись', '2018-11-07'),
(NULL, 'восьмая запись', '2018-11-08'),
(NULL, 'девятая запись', '2018-11-09'),
(NULL, 'десятая запись', '2018-11-10');

DELETE
  posts
FROM
  posts
JOIN
 (SELECT
    created_at
  FROM
    posts
  ORDER BY
    created_at DESC
  LIMIT 5, 1) AS delpst
ON
  posts.created_at <= delpst.created_at;

SELECT * FROM posts;

-- Хранимые процедуры и функции, триггеры.
-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DROP FUNCTION IF EXISTS hello;

DELIMITER //

CREATE FUNCTION hello() 
RETURNS VARCHAR(20) NO SQL
BEGIN
    DECLARE greeting VARCHAR(20);
    DECLARE h INT;
    SET h = HOUR(NOW());
    IF (h BETWEEN 6 AND 11) THEN
      SELECT 'Доброе утро!' INTO greeting;
    END IF;
    IF (h BETWEEN 12 AND 17) THEN
      SELECT 'Добрый день!' INTO greeting;
    END IF;
    IF (h BETWEEN 18 AND 23) THEN
      SELECT 'Добрый вечер!' INTO greeting;
    END IF;
    IF (h BETWEEN 0 AND 5) THEN
      SELECT 'Доброй ночи!' INTO greeting;
    END IF;
RETURN greeting;
END //

DELIMITER ;

SELECT hello();

-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

DROP TRIGGER IF EXISTS not_null_goods;

DELIMITER //

CREATE TRIGGER not_null_goods_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    IF NEW.name IS NULL AND NEW.description IS NULL THEN
      SIGNAL SQLSTATE '45000' SET message_text = 'Недопустимая операция, вставка отменена';
    END IF;
END //

CREATE TRIGGER not_null_goods_update BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.name IS NULL AND NEW.description IS NULL THEN
      SIGNAL SQLSTATE '45000' SET message_text = 'Недопустимая операция, вставка отменена';
    END IF;
END //

DELIMITER ;

-- 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
-- Вызов функции FIBONACCI(10) должен возвращать число 55.

DELIMITER //

CREATE FUNCTION FIBONACCI(num INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE fs DOUBLE;
  SET fs = SQRT(5);

  RETURN (POW((1 + fs) / 2.0, num) + POW((1 - fs) / 2.0, num)) / fs;
END//

SELECT FIBONACCI(10)//
