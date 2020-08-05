-- Lesson 10.


-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы.
SHOW TABLES;

-- Индекс по почтовому ящику
CREATE UNIQUE INDEX users_email_uq ON users(email);

-- Составной индекс по имени и фамилии.
CREATE INDEX users_first_name_last_name_idx ON users(first_name, last_name);

-- Индекс по номеру телефона.
CREATE INDEX users_phone_uq ON users(phone);

-- Составной индекс по дате рождения, городу и стране.
CREATE INDEX profiles_birthday_city_country_idx ON profiles(birthday, city, country);

-- Составной индекс по входящим/исходящим сообщениям.
CREATE INDEX messages_from_user_id_to_user_id_idx ON messages (from_user_id, to_user_id);

-- Индекс по названию медиафайлов.
CREATE INDEX media_filename_idx ON media(filename);

-- Индекс по названию групп.
CREATE INDEX communities_name_uq ON communities(name);


-- 2. Задание на оконные функции. Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый старший пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

USE vk;

SELECT DISTINCT c.name AS `Community name`,
-- Для того, чтобы посчитать среднее количество пользователей в группах мы возмем сумму всех записей в таблице communities_users 
-- (нам не важна уникальность пользователя) и разделим на последний номер id в таблице communities, 
-- потому что группу удалить нельзя по структуре таблицы, а id идет по возрастанию с шагом 1 с каждой новой группой.
COUNT(cu.user_id) OVER() / MAX(c.id) OVER() AS `Avg members`,
FIRST_VALUE(CONCAT(u.first_name, ' ', u.last_name)) OVER(PARTITION BY cu.community_id ORDER BY p.birthday DESC) AS `Youngest`,
FIRST_VALUE(CONCAT(u.first_name, ' ', u.last_name)) OVER(PARTITION BY cu.community_id ORDER BY p.birthday) AS `Oldest`,
COUNT(cu.user_id) OVER(PARTITION BY cu.community_id) AS `Total in community`,
COUNT(p.user_id) OVER() AS `Total users`,
CONCAT((COUNT(cu.user_id) OVER(PARTITION BY cu.community_id) / COUNT(p.user_id) OVER() * 100), '%') AS `%%`
FROM communities c
LEFT JOIN communities_users cu ON c.id = cu.community_id
LEFT JOIN profiles p ON cu.user_id = p.user_id
LEFT JOIN users u ON u.id = p.user_id;

-- Корректный вариант.

SELECT DISTINCT 
  communities.name AS group_name,
  COUNT(communities_users.user_id) OVER() 
    / (SELECT COUNT(*) FROM communities) AS avg_users_in_groups,
  FIRST_VALUE(users.first_name) OVER birthday_desc AS youngest_first_name,
  FIRST_VALUE(users.last_name) OVER birthday_desc AS youngest_last_name,
  FIRST_VALUE(users.first_name) OVER birthday_asc AS oldest_first_name,
  FIRST_VALUE(users.last_name) OVER birthday_asc AS oldest_last_name,
  COUNT(communities_users.user_id) OVER(PARTITION BY communities.id) AS users_in_group,
  (SELECT COUNT(*) FROM users) AS users_total,
  COUNT(communities_users.user_id) OVER(PARTITION BY communities.id) 
    / (SELECT COUNT(*) FROM users) *100 AS '%%'
    FROM communities
      LEFT JOIN communities_users 
        ON communities_users.community_id = communities.id
      LEFT JOIN users 
        ON communities_users.user_id = users.id
      LEFT JOIN profiles 
        ON profiles.user_id = users.id
      WINDOW birthday_desc AS (PARTITION BY communities.id ORDER BY profiles.birthday DESC),
             birthday_asc AS (PARTITION BY communities.id ORDER BY profiles.birthday);  

/* 3. (по желанию) Задание на денормализацию. Разобраться как построен и работает следующий запрос:
Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

SELECT users.id,
COUNT(DISTINCT messages.id) +
COUNT(DISTINCT likes.id) +
COUNT(DISTINCT media.id) AS activity
FROM users
LEFT JOIN messages
ON users.id = messages.from_user_id
LEFT JOIN likes
ON users.id = likes.user_id
LEFT JOIN media
ON users.id = media.user_id
GROUP BY users.id
ORDER BY activity
LIMIT 10;

Правильно-ли он построен?
Какие изменения, включая денормализацию, можно внести в структуру БД чтобы существенно повысить скорость работы этого запроса?*/

/* В данном запросе сначала происходит объединение 4х таблиц (ресурсоёмкая операция), а затем происходит тройной подсчет активностей 
одного и того же пользоателя с помощью агрегатной функции COUNT() (также ресурсоёмкая операция). Для того, чтобы тратить ресурсы системы 
экономнее разумно было бы сделать отдельную таблицу для активностей пользователей. Да, это будет дублирование некоторых данных, но обращение к этой
таблице будет происходить быстрее, так как это будет одна таблица, а не соединение четырех разных. Затем, один раз сгруппировав таблицу по user_id и 
применив один раз функцию COUNT() мы сможем вывести активность не только 10-ти самых активных или неактивных, но и узнать активность конкретного 
пользователя по его user_id. 

Сама таблица будет состоять из четырех столбцов - user_id, is_message, is_like, is_media. Последние три столбца по умолчанию равны 0. 
Для заполнения таблицы можно прибегнуть к процедуре, которая исходя из запроса на вставку данных будет проставлять в таблице единицу (Истина) 
в нужном столбце. */
