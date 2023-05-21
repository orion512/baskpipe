/* This tests that no team in a playoff series has had more than 4 home games */

SELECT season, home_team, away_team, COUNT(*)
FROM game g
WHERE
	g.is_playoff = 1
GROUP BY season, home_team, away_team
HAVING COUNT(*) > 4