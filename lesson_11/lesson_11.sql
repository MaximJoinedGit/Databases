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

-- 2. Без использования цикла.

CREATE TABLE samples (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO samples (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29'),
  ('Аркадий', '1994-03-17'),
  ('Ольга', '1981-07-10'),
  ('Владимир', '1988-06-12'),
  ('Екатерина', '1992-09-20');

SELECT
  COUNT(*)
FROM
  samples AS fst,
  samples AS snd,
  samples AS thd,
  samples AS fth,
  samples AS fif,
  samples AS sth;

SELECT COUNT(*) FROM users;

SELECT * FROM users LIMIT 10;


-- Практическое задание тема "NoSQL"
-- 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.
HINCRBY addresses '127.0.0.1' 1
HGETALL addresses

HINCRBY addresses '127.0.0.2' 1
HGETALL addresses

HGET addresses '127.0.0.1'

-- 2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному
-- адресу и наоборот, поиск электронного адреса пользователя по его имени.
HSET emails 'igor' 'igorsimdyanov@gmail.com'
HSET emails 'sergey' 'sergey@gmail.com'
HSET emails 'olga' 'olga@mail.ru'

HGET emails 'igor'

HSET users 'igorsimdyanov@gmail.com' 'igor'
HSET users 'sergey@gmail.com' 'sergey'
HSET users 'olga@mail.ru' 'olga'

HGET users 'olga@mail.ru'

-- 3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.
-- Предлагаемый вариант

show dbs

use shop

db.createCollection('catalogs')
db.createCollection('products')

db.catalogs.insert({name: 'Процессоры'})
db.catalogs.insert({name: 'Мат.платы'})
db.catalogs.insert({name: 'Видеокарты'})

db.products.insert(
  {
    name: 'Intel Core i3-8100',
    description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
    price: 7890.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'Intel Core i5-7400',
    description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
    price: 12700.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'ASUS ROG MAXIMUS X HERO',
    description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX',
    price: 19310.00,
    catalog_id: new ObjectId("5b56c74788f700498cbdc56c")
  }
);

db.products.find()

db.products.find({catalog_id: ObjectId("5b56c73f88f700498cbdc56bdb")})