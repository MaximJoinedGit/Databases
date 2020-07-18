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

-- Хранимые процедуры и функции, триггеры.
-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DROP FUNCTION IF EXISTS hello;

DELIMITER //

CREATE FUNCTION hello() 
RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
    DECLARE greeting VARCHAR(20);
    IF (HOUR(NOW()) BETWEEN 6 AND 11) THEN
      SELECT 'Доброе утро!' INTO greeting;
    END IF;
    IF (HOUR(NOW()) BETWEEN 12 AND 17) THEN
      SELECT 'Добрый день!' INTO greeting;
    END IF;
    IF (HOUR(NOW()) BETWEEN 18 AND 23) THEN
      SELECT 'Добрый вечер!' INTO greeting;
    END IF;
    IF (HOUR(NOW()) BETWEEN 0 AND 5) THEN
      SELECT 'Доброй ночи!' INTO greeting;
    END IF;
RETURN greeting;
END //

DELIMITER ;

SELECT hello();

-- 2. 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

DROP TRIGGER IF EXISTS not_null_goods;

DELIMITER //

CREATE TRIGGER not_null_goods BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    IF NEW.name IS NULL AND NEW.description IS NULL THEN
      SIGNAL SQLSTATE '45000' SET message_text = 'Недопустимая операция, вставка отменена';
    END IF;
END //

DELIMITER ;
