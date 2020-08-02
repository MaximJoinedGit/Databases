USE whoscored;

-- Игроков из каких стран больше всего в чемпионате.

CREATE OR REPLACE
VIEW players_from_countries AS
SELECT
  COUNT(*) AS `Players`,
  pac.country
FROM
  participants p
JOIN teams t ON
  p.team_id = t.id
JOIN players_and_coaches pac ON
  pac.team_id = t.id
WHERE
  p.tournament_id = 5
GROUP BY
  pac.country
ORDER BY
  `Players` DESC;

-- Какие матчи были сыграны в чемпионате и их краткая статистика.
 
CREATE OR REPLACE
VIEW all_games AS
SELECT DISTINCT 
  CONCAT(t.name, ' : ', t2.name) AS `Game`,
  CONCAT(g2.goals_home_team, ' : ', g2.goals_away_team) AS `Score`,
  CONCAT(s.shots_home_team, ' : ', s.shots_away_team) AS `Shots`,
  CONCAT(s.shots_og_home_team, ' : ', s.shots_og_away_team) AS `Shots OG`,
  CONCAT(r.rating_home_team, ' : ', r.rating_away_team) AS `Ratings`,
  CONCAT(fac.fouls_home_team, ' : ', fac.fouls_away_team) AS `Fouls`,
  CONCAT(fac.yellow_cards_home_team, ' : ', fac.yellow_cards_away_team) AS `Yellow cards`,
  CONCAT(fac.red_cards_home_team, ' : ', fac.red_cards_away_team) AS `Red cards`,
  CONCAT(c.corners_home_team, ' : ', c.corners_away_team) AS `Corners`,
  CONCAT(o.offsides_home_team, ' : ', o.offsides_away_team) AS `Offsides`
FROM
  participants p
JOIN games g ON
  g.tournament_id = p.tournament_id
JOIN teams t ON
  t.id = g.home_team_id
JOIN teams t2 ON
  t2.id = g.away_team_id
JOIN goals g2 ON
  g2.game_id = g.id
JOIN shots s ON
  s.game_id = g.id
JOIN ratings r ON
  r.game_id = g.id
JOIN fouls_and_cards fac ON
  fac.game_id = g.id
JOIN corners c ON
  c.game_id = g.id
JOIN offsides o ON
  o.game_id = g.id
WHERE
  p.tournament_id = 5;