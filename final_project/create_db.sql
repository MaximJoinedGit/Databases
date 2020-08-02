DROP DATABASE IF EXISTS whoscored;
CREATE DATABASE IF NOT EXISTS whoscored;
USE whoscored;

DROP TABLE IF EXISTS tournaments;
CREATE TABLE IF NOT EXISTS tournaments(
  id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'id турнира',
  name VARCHAR(100) NOT NULL COMMENT 'Название турнира',
  begin_at DATE NOT NULL COMMENT 'Дата начала турнира',
  finish_at DATE NOT NULL COMMENT 'Дата окончания турнира',
  UNIQUE unique_name(name)
) COMMENT 'Таблица по чемпионатам и сезонам. Новый сезон чемпионата - новая запись';

DROP TABLE IF EXISTS teams;
CREATE TABLE IF NOT EXISTS teams(
  id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'id команды',
  name VARCHAR(100) NOT NULL COMMENT 'Название команды',
  country VARCHAR(100) NOT NULL COMMENT 'Страна команды',
  UNIQUE unique_name(name)
) COMMENT 'Таблица с перечнем и краткой информацией о командах';

DROP TABLE IF EXISTS participants;
CREATE TABLE IF NOT EXISTS participants(
  tournament_id INT UNSIGNED NOT NULL COMMENT 'id турнира из таблицы tournaments',
  team_id INT UNSIGNED NOT NULL COMMENT 'id команды из таблицы teams',
  PRIMARY KEY (tournament_id, team_id) COMMENT 'Составной первичный ключ'
) COMMENT 'Объединение предыдущих двух таблиц. Отображает, какие команды в каком году и в каком чемпионате играли';

ALTER TABLE participants
  ADD CONSTRAINT participants_tournament_id_fk
    FOREIGN KEY (tournament_id) REFERENCES tournaments(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT participants_team_id_fk
    FOREIGN KEY (team_id) REFERENCES teams(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS roles;
CREATE TABLE IF NOT EXISTS roles(
  id TINYINT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'id амплуа',
  player_role VARCHAR(15) NOT NULL COMMENT 'Амплуа'
) COMMENT 'Разделение на игроков и тренеров, а также игроков по амплуа';

DROP TABLE IF EXISTS players_and_coaches;
CREATE TABLE IF NOT EXISTS players_and_coaches(
  id SERIAL PRIMARY KEY COMMENT 'id игрока или тренера',
  name VARCHAR(50) NOT NULL COMMENT 'Имя игрока или тренера',
  surname VARCHAR(50) NOT NULL COMMENT 'Фамилия игрока или тренера',
  birthday DATE NOT NULL COMMENT 'Дата рождения',
  country VARCHAR(50) NOT NULL COMMENT 'Страна игрока или тренера',
  team_id INT UNSIGNED NOT NULL COMMENT 'Команда из таблицы teams',
  player_role_id TINYINT UNSIGNED NOT NULL COMMENT 'Амплуа из таблицы roles'
) COMMENT 'Таблица с информацией об игроке или тренере';

ALTER TABLE players_and_coaches
  ADD CONSTRAINT players_and_coaches_team_id_fk
    FOREIGN KEY (team_id) REFERENCES teams(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT players_and_coaches_player_role_id_fk
    FOREIGN KEY (player_role_id) REFERENCES roles(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS games;
CREATE TABLE IF NOT EXISTS games(
  id SERIAL PRIMARY KEY COMMENT 'id игры',
  tournament_id INT UNSIGNED NOT NULL COMMENT 'id турнира из таблицы tournaments',
  home_team_id INT UNSIGNED NOT NULL COMMENT 'id домашней команды из таблицы teams',
  away_team_id INT UNSIGNED NOT NULL COMMENT 'id гостевой команды из таблицы teams',
  date_of_the_game DATETIME NOT NULL COMMENT 'Дата игры'
) COMMENT 'Таблица игр с указанием какая команда играла против какой и когда';

ALTER TABLE games
  ADD CONSTRAINT games_tournament_id_fk
    FOREIGN KEY (tournament_id) REFERENCES tournaments(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT games_home_team_id_fk
    FOREIGN KEY (home_team_id) REFERENCES teams(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT games_away_team_id_fk
    FOREIGN KEY (away_team_id) REFERENCES teams(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS goals;
CREATE TABLE IF NOT EXISTS goals(
  game_id SERIAL PRIMARY KEY COMMENT 'id игры из таблицы games',
  goals_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Голы домашней команды',
  goals_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Голы гостевой команды'
) COMMENT 'Информация по забитым голам в игре';

ALTER TABLE goals
  ADD CONSTRAINT goals_game_id_fk
    FOREIGN KEY (game_id) REFERENCES games(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS ratings;
CREATE TABLE IF NOT EXISTS ratings(
  game_id SERIAL PRIMARY KEY COMMENT 'id игры из таблицы games',
  rating_home_team DECIMAL(5, 2) UNSIGNED NOT NULL COMMENT 'Рейтинг домашней команды',
  rating_away_team DECIMAL(5, 2) UNSIGNED NOT NULL COMMENT 'Рейтинг гостевой команды'
) COMMENT 'Информация о рейтинге игроков, который был присвоен за игру по версии портала whoscored';

ALTER TABLE ratings
  ADD CONSTRAINT ratings_game_id_fk
    FOREIGN KEY (game_id) REFERENCES games(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS shots;
CREATE TABLE IF NOT EXISTS shots(
  game_id SERIAL PRIMARY KEY COMMENT 'id игры из таблицы games',
  shots_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Удары домашней команды',
  shots_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Удары гостевой команды',
  shots_og_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Удары в створ домашней команды',
  shots_og_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Удары в створ гостевой команды'
) COMMENT 'Информация об ударах в матче';

ALTER TABLE shots
  ADD CONSTRAINT shots_game_id_fk
    FOREIGN KEY (game_id) REFERENCES games(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS ball_possession;
CREATE TABLE IF NOT EXISTS ball_possession(
  game_id SERIAL PRIMARY KEY COMMENT 'id игры из таблицы games',
  possession_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Владение мячом домашней команды',
  possession_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Владение мячом гостевой команды'
) COMMENT 'Информация о владении мячом в матче';

ALTER TABLE ball_possession
  ADD CONSTRAINT ball_possession_game_id_fk
    FOREIGN KEY (game_id) REFERENCES games(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS fouls_and_cards;
CREATE TABLE IF NOT EXISTS fouls_and_cards(
  game_id SERIAL PRIMARY KEY COMMENT 'id игры из таблицы games',
  fouls_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Фолы у домашней команды',
  fouls_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Фолы у гостевой команды',
  yellow_cards_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Желтые карточки у домашней команды',
  yellow_cards_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Желтые карточки у гостевой команды',
  red_cards_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Красные карточки у домашней команды',
  red_cards_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Красные карточки у гостевой команды'
) COMMENT 'Информация о нарушениях правил и полученных карточках';

ALTER TABLE fouls_and_cards
  ADD CONSTRAINT fouls_and_cards_game_id_fk
    FOREIGN KEY (game_id) REFERENCES games(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS offsides;
CREATE TABLE IF NOT EXISTS offsides(
  game_id SERIAL PRIMARY KEY COMMENT 'id игры из таблицы games',
  offsides_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Оффсайды у домашней команды',
  offsides_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Оффсайды у гостевой команды'
) COMMENT 'Информация об офсайдах в матче';

ALTER TABLE offsides
  ADD CONSTRAINT offsides_game_id_fk
    FOREIGN KEY (game_id) REFERENCES games(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS corners;
CREATE TABLE IF NOT EXISTS corners(
  game_id SERIAL PRIMARY KEY COMMENT 'id игры из таблицы games',
  corners_home_team TINYINT UNSIGNED NOT NULL COMMENT 'Угловые домашней команды',
  corners_away_team TINYINT UNSIGNED NOT NULL COMMENT 'Угловые гостевой команды'
) COMMENT 'Информация об угловых ударах';

ALTER TABLE corners
  ADD CONSTRAINT corners_game_id_fk
    FOREIGN KEY (game_id) REFERENCES games(id)
      ON DELETE CASCADE;

DROP TABLE IF EXISTS player_main_stats;
CREATE TABLE IF NOT EXISTS player_main_stats(
  player_id BIGINT UNSIGNED NOT NULL COMMENT 'id игрока из таблицы players',
  game_id BIGINT UNSIGNED NOT NULL COMMENT 'id игры из таблицы games',
  rating DECIMAL(5, 2) UNSIGNED NOT NULL COMMENT 'Рейтинг игрока',
  minutes_played TINYINT UNSIGNED NOT NULL COMMENT 'Сыграно минут',
  goals TINYINT UNSIGNED NOT NULL COMMENT 'Забито голов',
  assists TINYINT UNSIGNED NOT NULL COMMENT 'Отдано голевых передач',
  PRIMARY KEY (player_id, game_id) COMMENT 'Составной первичный ключ'
) COMMENT 'Краткая статистика по каждому отдельному игроку';

ALTER TABLE player_main_stats
  ADD CONSTRAINT player_main_stats_player_id_fk
    FOREIGN KEY (player_id) REFERENCES players_and_coaches(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT player_main_stats_game_id_fk
    FOREIGN KEY (game_id) REFERENCES games(id)
      ON DELETE CASCADE;

CREATE INDEX players_and_coaches_name_surname_idx ON players_and_coaches(name, surname);