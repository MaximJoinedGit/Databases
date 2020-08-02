USE whoscored;

-- Результаты матчей команды в турнире.

SELECT
  t.name AS 'Home team',
  CONCAT(g3.goals_home_team, ':', g3.goals_away_team) AS 'Score',
  t2.name AS 'Away team',
  g2.date_of_the_game AS 'Date'
FROM
  games g2
JOIN goals g3 ON
  (g3.game_id = g2.id
  AND g2.tournament_id = 5
  AND g2.away_team_id = 35)
  OR (g3.game_id = g2.id
  AND g2.tournament_id = 5
  AND g2.home_team_id = 35)
JOIN teams t ON
  g2.home_team_id = t.id
JOIN teams t2 ON
  g2.away_team_id = t2.id;

-- Самый молодой игрок в команде.

SELECT
  CONCAT(name, ' ', surname) AS `Youngest player`
FROM
  players_and_coaches pac
WHERE
  team_id = 35
  AND pac.player_role_id != 5
ORDER BY
  pac.birthday DESC
LIMIT 1;

-- Самый молодой игрок в турнире.

SELECT
  CONCAT(pac.name, ' ', pac.surname) AS `Youngest player`,
  t.name AS `From team`,
  pac.country AS `From country`
FROM
  participants p
JOIN teams t ON
  t.id = p.team_id
JOIN players_and_coaches pac ON
  pac.team_id = p.team_id
WHERE
  tournament_id = 5
ORDER BY
  pac.birthday DESC
LIMIT 1;

-- 5 лучших бомбардиров в турнире.

SELECT
  DISTINCT pac.name AS `Name`,
  pac.surname AS `Surname`,
  t2.name AS `From team`,
  SUM(pms.goals) OVER(PARTITION BY pac.id) AS `Scored`
FROM
  participants p
JOIN teams t2 ON
  t2.id = p.team_id
JOIN players_and_coaches pac ON
  pac.team_id = p.team_id
JOIN player_main_stats pms ON
  pms.player_id = pac.id
WHERE
  p.tournament_id = 5
  AND pac.player_role_id != 5
ORDER BY
  `Scored` DESC
LIMIT 5;

-- Сколько всего голов забила команда.

SELECT
  team_goals(5, 35) AS `Total goals`;

-- Сколько голов в среднем за матч она забивала.

SELECT
  team_goals(5, 35) / COUNT(*) AS `Avg per game`
FROM
  games g
WHERE
  (g.tournament_id = 5
  AND g.home_team_id = 35)
  OR (g.tournament_id = 5
  AND g.away_team_id = 35);

-- 5 игроков, которые сыграли больше всех в турнире.

SELECT
  DISTINCT pac.name AS `Name`,
  pac.surname AS `Surname`,
  t.name AS `From team`,
  SUM(pms.minutes_played) OVER(PARTITION BY pac.id) AS `Minutes played`
FROM
  participants p
JOIN teams t ON
  t.id = p.team_id
JOIN players_and_coaches pac ON
  pac.team_id = p.team_id
JOIN player_main_stats pms ON
  pms.player_id = pac.id
WHERE
  p.tournament_id = 5
  AND pac.player_role_id != 5
ORDER BY
  `Minutes played` DESC
LIMIT 5;
