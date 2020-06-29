-- lesson 5. Part 1.
SHOW DATABASES;

USE shop_3;

/**********************************************************************************/
-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

SELECT * FROM users;

-- Поскольку все поля в таблице были заполнены автоматически, зададим значение NULL вручную.
UPDATE users SET created_at = NULL 
  WHERE name = 'Геннадий' 
  OR name = 'Александр' 
  OR name = 'Иван';

UPDATE users SET updated_at = NULL 
  WHERE name = 'Наталья' 
  OR name = 'Сергей' 
  OR name = 'Мария';

-- Заполним поля, в которых зачения NULL текущим временем.
UPDATE users SET created_at = CURRENT_TIMESTAMP() WHERE created_at IS NULL;
UPDATE users SET updated_at = CURRENT_TIMESTAMP() WHERE updated_at IS NULL;

-- Проверим, что все поля заполнены.
SELECT * FROM users WHERE updated_at IS NULL;

/**********************************************************************************/
-- 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR 
-- и в них долгое время помещались значения в формате 20.10.2017 8:10. Необходимо преобразовать поля к типу DATETIME, 
-- сохранив введённые ранее значения.

DESC users;

SELECT * FROM users;

-- Таблица спроектирована удачно, но смоделируем ситуацию, которая описана в задаче.
-- Приведем колонки created_at и updated_at к типу VARCHAR.
ALTER TABLE users MODIFY COLUMN created_at VARCHAR(255);
ALTER TABLE users MODIFY COLUMN updated_at VARCHAR(255);

-- Сформируем запрос, который выведет время в НЕнужном формате.
SELECT DATE_FORMAT(created_at, '%d.%m.%Y %k:%i') FROM users;

-- Используем запрос выше для изменения стобцов updated_at и created_at.
UPDATE users SET created_at = DATE_FORMAT(created_at, '%d.%m.%Y %k:%i');
UPDATE users SET updated_at = DATE_FORMAT(updated_at, '%d.%m.%Y %k:%i');

-- На всякий случай вставим еще строку из примера в задании.
INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES ('Андрей', '1977-11-29', '20.10.2017 8:10', '20.10.2017 8:10');

-- Делаем всё тоже самое, только в обратном порядке.
SELECT STR_TO_DATE(created_at, '%d.%m.%Y %k:%i') FROM users;

UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i');
UPDATE users SET updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');

ALTER TABLE users MODIFY COLUMN created_at datetime;
ALTER TABLE users MODIFY COLUMN updated_at datetime;

/**********************************************************************************/
-- 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
-- 0, если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, 
-- чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.

DESC storehouses_products;

SELECT * FROM storehouses_products;

-- Для того, чтобы выполнить задание заполним таблицу storehouses_products значениями. В конце добавим дополнительно два нулевых по остатку продукта.
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
  
-- Отсортируем так, как сказано в условии (по возрастанию и нулевые значения в конце).
SELECT * FROM storehouses_products ORDER BY value IS FALSE, value;

/**********************************************************************************/
-- 4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
-- Месяцы заданы в виде списка английских названий (may, august)

SELECT name FROM users WHERE MONTHNAME(birthday_at) = 'may' OR MONTHNAME(birthday_at) = 'august';

/**********************************************************************************/
-- 5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
-- Отсортируйте записи в порядке, заданном в списке IN.

SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);

-- lesson 5. Part 2.

/**********************************************************************************/
-- 1. Подсчитайте средний возраст пользователей в таблице users.

SELECT AVG(FLOOR(YEAR(NOW()) - YEAR(birthday_at))) AS 'AVERAGE AGE' FROM users;
-- Средний возраст - 30,5 лет.

/**********************************************************************************/
-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.

SELECT DAYNAME(CONCAT(YEAR(NOW()), DATE_FORMAT(birthday_at, '-%m-%d'))) AS BORN_AT, COUNT(*) AS TIMES FROM users GROUP BY BORN_AT;

/**********************************************************************************/
-- 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.
-- Для подсчета произведений в столбце возьмем столбец value в таблице storehouses_products.

SELECT value FROM storehouses_products;

-- Заменим нулевые значения на случайные, чтобы произведение имело смысл выполнять. 
-- Для большей наглядности заменим и остальные значения на меньшие (меньше 10).
UPDATE storehouses_products SET value = CEIL(RAND() * 10);

-- Теперь выполним произведение всех значений в столбце.
SELECT FLOOR(EXP(SUM(LOG(value)))) AS mul FROM storehouses_products;