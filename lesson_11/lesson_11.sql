-- Lesson 11.

-- Практическое задание по теме “Оптимизация запросов”
-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs 
-- помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

USE shop;

DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата и время создания',
  tbl VARCHAR(100) NOT NULL COMMENT 'Название таблицы',
  id INT UNSIGNED NOT NULL COMMENT 'ID товара, пользователя или раздела каталога',
  name VARCHAR(255) NOT NULL COMMENT 'Название товара, раздела каталога или имя пользователя'
) COMMENT = 'Таблица логов' ENGINE=Archive;

DROP TRIGGER IF EXISTS logs_tbl_users;
DROP TRIGGER IF EXISTS logs_tbl_catalogs;
DROP TRIGGER IF EXISTS logs_tbl_products;

DELIMITER //

CREATE TRIGGER logs_tbl_users AFTER INSERT ON shop.users 
  FOR EACH ROW 
  BEGIN
	  INSERT INTO shop.logs (tbl, id, name) VALUES ('users', NEW.id, NEW.name);
  END//

CREATE TRIGGER logs_tbl_catalogs AFTER INSERT ON shop.catalogs
  FOR EACH ROW 
  BEGIN
	  INSERT INTO shop.logs (tbl, id, name) VALUES ('catalogs', NEW.id, NEW.name);
  END//

CREATE TRIGGER logs_tbl_products AFTER INSERT ON shop.products
  FOR EACH ROW 
  BEGIN
	  INSERT INTO shop.logs (tbl, id, name) VALUES ('products', NEW.id, NEW.name);
  END//

DELIMITER ;

INSERT INTO shop.users (name, birthday_at) VALUES ('Марат Сафин', '1988-01-01');
INSERT INTO shop.users (name, birthday_at) VALUES ('Мадонна', '1980-11-28');
INSERT INTO shop.users (name, birthday_at) VALUES ('Билл Гейтс', '1990-12-31');
INSERT INTO shop.catalogs (id, name) VALUES (6, 'Ноутбуки');
INSERT INTO shop.catalogs (id, name) VALUES (7, 'Телефоны');
INSERT INTO shop.products (name, description, price, catalog_id) VALUES ('Процессор', 'Обычный процессор', 1999.99, 1);
INSERT INTO shop.products (name, description, price, catalog_id) VALUES ('Телефон', 'Обычный телефон', 5999.99, 7);

SELECT * FROM logs;

-- 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

DESC users;

DELIMITER //

DROP PROCEDURE IF EXISTS insert_users//
CREATE PROCEDURE insert_users()
  BEGIN
	DECLARE cnt INT DEFAULT 0;
    WHILE cnt < 1000000 DO
      INSERT INTO shop.users (name, birthday_at) VALUES (CONCAT('name ', cnt), NOW());
      SET cnt = cnt + 1;
    END WHILE;
  END

DELIMITER ;

CALL insert_users();
SELECT * FROM users;

