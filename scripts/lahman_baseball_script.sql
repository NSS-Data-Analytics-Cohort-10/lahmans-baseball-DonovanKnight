## Lahman Baseball Database Exercise
- this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
- A data dictionary is included with the files for this project.

### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.

SELECT * 
FROM allstarfull

SELECT *
FROM appearances

SELECT *
FROM awardsmanagers

SELECT *
FROM homegames

SELECT *
FROM collegeplaying

SELECT DISTINCT(yearid) 
FROM teams





**Initial Questions**

1. What range of years for baseball games played does the provided database cover? 
--- looking for years, seem to be in same table

SELECT MIN(yearid), MAX(yearid)
FROM teams

--- Answer: 1871-2016


2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
 SELECT *
 FROM people
 
 SELECT *
 FROM teams
 
 SELECT *
 FROM appearances
 --- main issue was trying to get the team name along with the rest of the information needed
 
 SELECT DISTINCT p.namefirst,
 	p.namelast,
	p.namegiven,
	p.height, 
	a.teamid, 
 	a.g_all,
	t.name
 FROM people AS p
 INNER JOIN appearances AS a
 USING (playerid)
 INNER JOIN teams AS t
 USING (teamid)
 WHERE height IS NOT NULL
 ORDER BY height;
 
 --- used this to see where i needed to pull the team name from and what the team was
 SELECT DISTINCT name, teamid
 FROM teams
 WHERE teamid = 'SLA';
 
 ---ANSWER: Eddie Gaedel AKA. Edward Carl, listed at 43 inches tall or 3'9". He played one game for the St. Louis Browns.

3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
	SELECT schoolid,
	namefirst,
	namelast,
	salaries.yearid,
	SUM(salaries.salary) as total_sal
	FROM people
	LEFT JOIN collegeplaying
	USING (playerid)
	LEFT JOIN salaries
	USING (playerid)
	LEFT JOIN schools
	USING (schoolid)
	WHERE schoolid = 'vandy' AND salary IS NOT NULL
	GROUP BY namefirst, namelast, schoolid, salaries.yearid
	ORDER BY total_sal DESC;
	
	--ANSWER David Price, not sure how to get rid of duplicates

4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT SUM(po) as total_putout, 
yearid,
CASE
	WHEN pos IN ('OF') THEN 'Outfield'
	WHEN pos IN ('P','C') THEN 'Battery'
	ELSE 'Infield'
	END AS player_group
	FROM fielding
	WHERE yearid = 2016
	GROUP BY pos, yearid
	ORDER BY total_putout;
	
	--- this out put gave me multiple rows for infield, 4 specifically, due to me not being specific enough with the else statement in my query
	
	
SELECT
SUM(po) as total_putout, 
fielding.yearid,
CASE
WHEN pos IN ('OF') THEN 'Outfield'
WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
WHEN pos IN ('P', 'C') THEN 'Battery'
END AS position_played
FROM fielding
WHERE fielding.yearid = 2016
GROUP BY position_played, fielding.yearid
ORDER BY total_putout;


-- ANSWER : Battery: 41424 , Infield: 58934 , Outfield: 29560

   
5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?


SELECT *
FROM teams

SELECT yearid
FROM teams


---Learned about the FLOOR function through a classmate. 


SELECT 
FLOOR(yearid) AS decade
FROM teams
WHERE yearid >=1920
GROUP BY decade
ORDER BY decade


SELECT
FLOOR((yearid/10)*10) AS decade
FROM teams
WHERE yearid >= 1920
GROUP BY decade 
ORDER BY decade;


--- Added strikeout per game and home runs per game

SELECT
	FLOOR(yearid) AS decade,
	ROUND(AVG(so/g), 2) AS avg_strikeouts,
	ROUND(AVG(hr/g), 2) AS avg_homeruns
FROM teams
WHERE yearid >= 1920
GROUP BY decade 
ORDER BY decade;

--- ANSWER: AS the years go on there are more strikeouts and homeruns per game



   

6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

--- CTE for this question because there will be multiple aggregate functions to solve this question 

SELECT *
FROM batting

WITH stolen_bases AS ( 
	SELECT
	playerID,
	SUM(sb::numeric) AS stolen_bases,
	SUM(cs::numeric) AS caught_stealing,
	((SUM(sb)/((SUM(sb::numeric))+(SUM(cs::numeric))))*100) AS percent_stolen
	--- this gives us the percentage of bases stole nby each player
FROM batting
WHERE sb IS NOT NULL
AND cs IS NOT NULL
AND yearid = 2016
GROUP BY playerID
HAVING (SUM(sb)+SUM(cs)) >= 20
	---this gathers all of the total bases that each player attempted to steal, regardless of outcome
)
SELECT 
	namefirst,
	namelast,
	stolen_bases,
	caught_stealing,
	percent_stolen
FROM people 
INNER JOIN stolen_bases
USING(playerid)
ORDER BY percent_stolen DESC;

--- ANSWER: Chris Owings


	
	

7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
	
	with cte AS(SELECT yearid, (MAX(w))AS maxw
			   FROM teams
			   WHERE yearid BETWEEN  1970 and 2016 AND yearid NOT IN (1981)
			   GROUP BY yearid
			   ORDER BY yearid DESC),
			   
	cte2 AS (SELECT teamid, 
			yearid,
			w,
			wswin
			FROM teams
			WHERE yearid BETWEEN 1970 AND 2016 AND yearid NOT IN (1981)
			ORDER BY w DESC)
SELECT
SUM(CASE WHEN wswin= 'Y' THEN 1 ELSE 0 END) AS total_wins,
COUNT(DISTINCT cte.yearid),
ROUND(SUM(CASE WHEN wswin='Y' THEN 1 ELSE 0 END)/COUNT(DISTINCT cte.yearid)::numeric, 2)*100 AS win_percentage
FROM cte2
LEFT JOIN cte
ON cte.yearid=cte2.yearid AND cte2.w=cte.maxw
WHERE cte.maxw IS NOT NULL;

---ANSWER: 26% of the time for the last part of the question... Got this answer from a classmate from breakout rooms, it was not coming to my brain. Tried to play around with it and study it to help my thought process


8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT *
FROM homegames

SELECT * 
FROM parks

SELECT *
FROM teams

SELECT team, park,(SELECT AVG(attendance/games) AS average_attendance FROM homegames)
FROM homegames

SELECT team,park_name,year,
AVG(attendance/games) AS average_attendance
FROM homegames
INNER JOIN parks
USING (park)
WHERE year = '2016' AND games>=10
GROUP BY team, parks.park_name, year
ORDER BY average_attendance DESC
LIMIT 5;

--- got the team abbreviation but now trying to add the team name.

SELECT team, teams.name, park_name,year,
AVG(homegames.attendance/homegames.games) AS average_attendance
FROM homegames
INNER JOIN parks
USING (park)
INNER JOIN teams
ON  teams.teamid = homegames.team
WHERE year = '2016' AND games>=10
GROUP BY team,teams.name, parks.park_name, year
ORDER BY average_attendance DESC
LIMIT 5;

---added names, these are the top averages for attedance.

SELECT team, teams.name, park_name,year,
AVG(homegames.attendance/homegames.games) AS average_attendance
FROM homegames
INNER JOIN parks
USING (park)
INNER JOIN teams
ON  teams.teamid = homegames.team
WHERE year = '2016' AND games>=10
GROUP BY team,teams.name, parks.park_name, year
ORDER BY average_attendance 
LIMIT 5;

-- ANSWER: these are the bottom 5 average percentages


9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--need CTE because 

SELECT *
FROM awardsmanagers

SELECT *
FROM teams

SELECT *
FROM people

SELECT *
FROM managers

SELECT playerid, awardid, SELECT lgid
FROM awardsmanagers
WHERE awardid LIKE 'TSN%' 



SELECT playerid, namegiven, awardid,lgid
FROM awardsmanagers
INNER JOIN people
USING (playerid)
---this inner join is helping me place names with the coaches and attempted in adding the criteria for the awards received by each manager
WHERE awardid LIKE 'TSN%' and lgid NOT LIKE '%ML' 









10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players first and last names and the number of home runs they hit in 2016.


SELECT hr,p.namefirst, p.namelast, a.yearid
FROM batting
INNER JOIN appearances AS a
USING (playerid)
INNER JOIN people AS p
USING (playerid)
WHERE a.yearid = '2016'
ORDER BY hr DESC;

--- this query above gives me the players with the most homeruns in 2016... how to get CAREER HOMERUNS in 2016

SELECT yearid, namefirst, namelast
FROM appearances AS a
INNER JOIN people
USING (playerid)
WHERE a.yearid >= '2006'

--- this query gives me all players that have been in the league for at least 10 years.





SELECT MAX(hr) 
FROM batting

SELECT MAX(b.hr), b.playerid, p.namefirst, p.namelast
FROM batting AS b
INNER JOIN people AS p
USING (playerid)
WHERE yearid = '2016' AND hr >=1
GROUP BY b.playerid, p.namefirst,p.namelast
ORDER BY MAX(b.hr) DESC;

--- this query above gives me the players with the most homeruns in 2016... how to get CAREER HOMERUNS in 2016 (used different tables.. might help with CTE later ?)



SELECT p.namefirst, p.namelast, b.HR
FROM batting AS b
INNER JOIN people as p
USING (playerid)
WHERE b.yearid = 2016
	AND b.HR = (SELECT MAX(HR) FROM batting WHERE playerid =b.playerid)
	AND b.HR > 0
	AND (SELECT COUNT(yearid) FROM batting WHERE playerid = b.playerid) >= 10
ORDER BY hr DESC;
	








**Open-ended questions**

11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

12. In this question, you will explore the connection between number of wins and attendance.
    <ol type="a">
      <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
      <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
    </ol>


13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
