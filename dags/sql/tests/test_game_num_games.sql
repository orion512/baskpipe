/* This tests that no team has had more than 41 home games in a season */

SELECT season, home_team, COUNT(*)
FROM game g
WHERE
	g.is_playoff = 0
GROUP BY season, home_team
HAVING COUNT(*) > 41
-- need to remove play-in