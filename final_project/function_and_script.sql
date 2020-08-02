DROP FUNCTION IF EXISTS team_goals;

DELIMITER *

CREATE FUNCTION team_goals(tournament_id_in INT, team_id_in INT)
RETURNS INT NO SQL
BEGIN
  DECLARE home INT DEFAULT 0;
  DECLARE away INT DEFAULT 0;
  DECLARE total INT DEFAULT 0;
  SELECT DISTINCT SUM(g2.goals_home_team) OVER ()
    FROM games g 
    JOIN goals g2 ON g.id = g2.game_id AND g.tournament_id = tournament_id_in AND g.home_team_id = team_id_in
    INTO home;
  SELECT DISTINCT SUM(g2.goals_away_team) OVER ()
    FROM games g 
    JOIN goals g2 ON g.id = g2.game_id AND g.tournament_id = tournament_id_in AND g.away_team_id = team_id_in
    INTO away;
  SET total = home + away;
  RETURN total;
END *

DELIMITER ;

DROP TRIGGER IF EXISTS check_date;

DELIMITER *

CREATE TRIGGER check_date 
BEFORE INSERT ON games 
  FOR EACH ROW 
  BEGIN 
    IF NEW.date_of_the_game NOT BETWEEN 
      (SELECT DISTINCT t.begin_at FROM games g JOIN tournaments t ON t.id = g.tournament_id WHERE g.tournament_id = NEW.tournament_id) 
    AND 
      (SELECT DISTINCT t.finish_at FROM games g JOIN tournaments t ON t.id = g.tournament_id WHERE g.tournament_id = NEW.tournament_id) 
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong date';
  END IF;
END *

DELIMITER ;
