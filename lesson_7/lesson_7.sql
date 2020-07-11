-- Lesson 7.
-- Для начала создадим все таблицы и заполним их.

CREATE DATABASE IF NOT EXISTS shop;
USE shop;

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

DROP TABLE IF EXISTS rubrics;
CREATE TABLE rubrics (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела'
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO rubrics VALUES
  (NULL, 'Видеокарты'),
  (NULL, 'Память');

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id INT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
) COMMENT = 'Скидки';

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Склады';

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

-- Создадим внешние ключи.

-- orders
-- Для успешного создания первичного ключа нам необходимо поменять тип данных в таблице orders в столбце user_id. 
ALTER TABLE orders CHANGE user_id user_id BIGINT UNSIGNED;

ALTER TABLE orders
  ADD CONSTRAINT orders_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

-- orders-products
-- Также поменяем тип данных.
ALTER TABLE orders_products CHANGE product_id product_id BIGINT UNSIGNED;
ALTER TABLE orders_products CHANGE order_id order_id BIGINT UNSIGNED;

ALTER TABLE orders_products
  ADD CONSTRAINT orders_products_order_id_fk
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT orders_products_product_id_fk
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON DELETE CASCADE;

-- discounts
-- Меняем тип данных.
ALTER TABLE discounts CHANGE user_id user_id BIGINT UNSIGNED;
ALTER TABLE discounts CHANGE product_id product_id BIGINT UNSIGNED;

ALTER TABLE discounts
  ADD CONSTRAINT discounts_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT discounts_product_id_fk
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON DELETE CASCADE;

-- products
-- Меняем тип данных
ALTER TABLE products CHANGE catalog_id catalog_id BIGINT UNSIGNED;

ALTER TABLE products
  ADD CONSTRAINT products_catalog_id_fk
    FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
      ON DELETE SET NULL;

-- storehouses_products
-- Меняем тип данных
ALTER TABLE storehouses_products CHANGE storehouse_id storehouse_id BIGINT UNSIGNED;
ALTER TABLE storehouses_products CHANGE product_id product_id BIGINT UNSIGNED;

ALTER TABLE storehouses_products
  ADD CONSTRAINT storehouses_products_storehouse_id_fk
    FOREIGN KEY (storehouse_id) REFERENCES storehouses(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT storehouses_products_product_id_fk
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON DELETE CASCADE;
      
-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
-- Добавим несколько заказов в таблицу orders.
INSERT INTO orders (user_id) VALUES 
  (CEIL(RAND() * 6)),
  (CEIL(RAND() * 6)),
  (CEIL(RAND() * 6)),
  (CEIL(RAND() * 6)),
  (CEIL(RAND() * 6));

SELECT
	DISTINCT u.id,
	u.name
FROM
	orders o
JOIN users u ON
	u.id = o.user_id;

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT
	c.name,
	p.name
FROM
	products p
JOIN catalogs c ON
	c.id = p.catalog_id;

-- 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.
CREATE DATABASE IF NOT EXISTS flights;

USE flights;

CREATE TABLE IF NOT EXISTS flights (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `from` VARCHAR(255) NOT NULL,
  `to` VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS cities (
  label VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL
);

INSERT INTO flights (`from`, `to`) VALUES
  ('moscow', 'omsk'),
  ('novgorod', 'kazan'),
  ('irkutsk', 'moscow'),
  ('omsk', 'irkutsk'),
  ('moscow', 'kazan');

INSERT INTO cities VALUES
  ('moscow', 'Москва'),
  ('irkutsk', 'Иркутск'),
  ('novgorod', 'Новгород'),
  ('kazan', 'Казань'),
  ('omsk', 'Омск');

SELECT
	c_dep.name AS depart,
	c_arr.name AS arrive
FROM
	flights AS f
JOIN cities AS c_dep ON
	f.`from` = c_dep.label
JOIN cities as c_arr ON
	f.`to` = c_arr.label
ORDER BY
	f.id;