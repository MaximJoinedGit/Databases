-- Lesson 8.

USE vk;

-- 1. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT
	p.gender,
	COUNT(p.gender) AS `Итого`
FROM
	likes l
JOIN profiles p ON
	p.user_id = l.user_id
GROUP BY
	p.gender
ORDER BY `Итого` DESC
LIMIT 1;

-- 2. Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).

SELECT
	SUM(total_likes) AS `Likes to youngest`
FROM
	(
	SELECT
		COUNT(l.target_id) AS `total_likes`
	FROM
		profiles p
	LEFT JOIN likes l ON
		l.target_id = p.user_id
		AND l.target_type_id = 2
	GROUP BY
		p.user_id
	ORDER BY
		p.birthday DESC
	LIMIT 10) AS `total`;

-- 3. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
-- (критерии активности необходимо определить самостоятельно).

SELECT
	CONCAT(u.first_name, ' ', u.last_name) AS `User`,
	(COUNT(DISTINCT m.id) + COUNT(DISTINCT l.id) + COUNT(DISTINCT m2.id)) AS `Activity index`
FROM
	users u
LEFT JOIN messages m ON
	u.id = m.from_user_id
LEFT JOIN likes l ON
	u.id = l.user_id
LEFT JOIN media m2 ON
	u.id = m2.user_id
GROUP BY
	u.id
ORDER BY
	`Activity index`
LIMIT 10;