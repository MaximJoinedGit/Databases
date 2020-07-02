USE vk;

CREATE TABLE posts(
  id SERIAL PRIMARY KEY COMMENT "Порядковый номер поста",
  user_id SERIAL UNSIGNED NOT NULL COMMENT "Автор поста",
  text_data MEDIUMTEXT NOT NULL COMMENT "Текст поста",
  media_id INT UNSIGNED COMMENT "Допустим, что файл может быть прикреплен только один. Для нескольких файлов нужно будет создать еще колонки media_id.",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания поста",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления поста"
  );

CREATE TABLE likes(
  posts_id SERIAL PRIMARY KEY COMMENT "Пост, который понравился",
  user_id SERIAL PRIMARY KEY COMMENT "Кому понравился",
);
