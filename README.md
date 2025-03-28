# SQLExercises
A practice of my SQL Game for Beginners
#The following SQL Queries were written here for the purpose of those who cant download the file
#When done reading you can rate my work











--How many olympics games have been held?
SELECT COUNT(games)
FROM athlete_events

--List down all Olympics games held so far
SELECT DISTINCT(games)
FROM athlete_events

--Mention the total no of nations who participated in each olympics game?
SELECT TOP 10 games, COUNT(NOC)
FROM athlete_events
GROUP BY Games
ORDER BY COUNT(NOC) DESC

--Which year saw the highest and lowest no of countries participating in olympics?

--SELECT Year, MAX(No_of_countries), MIN(No_of_countries)
--FROM

SELECT TOP 1 Year, COUNT(NOC) No_of_countries
FROM athlete_events
GROUP BY Year
ORDER BY COUNT(NOC) DESC

SELECT TOP 1 Year, COUNT(NOC) No_of_countries
FROM athlete_events
GROUP BY Year
ORDER BY COUNT(NOC) ASC

--Which nation has participated in all of the olympic games?
WITH 
T1 AS
		(SELECT COUNT(DISTINCT(Games)) Gamesdis
		 FROM athlete_events),
T2 AS
		(SELECT DISTINCT NOC, Games
		 FROM athlete_events),
T3 AS
		(
		SELECT NOC, COUNT(Games) as no_of_games
		FROM T2
		GROUP BY NOC
		)

SELECT * 
FROM T3
JOIN T1
ON T3.no_of_games=T1.Gamesdis


--identify the sport which was played in all summer olympics
--Find the total number of summer olympic games
--find for each sport, how many games where they played in
--compare 1&2

WITH b1 as
	(
	SELECT COUNT(DISTINCT(Games)) total_summer_games
	FROM athlete_events
	WHERE Season = 'Summer'
	),
	b2 as
	(
	SELECT DISTINCT Sport, games
	FROM athlete_events
	WHERE Season = 'Summer' 
	
	
	),
b3 as
	(
	SELECT Sport, COUNT(Games) as no_of_games
	FROM b2
	GROUP BY Sport
	)
SELECT *
FROM b3
JOIN b1
ON b1.total_summer_games = b3.no_of_games

--Fetch the top 5 atheletes who have won the most gold medals
WITH T1 AS
	(SELECT Name, COUNT(*) as total_medals
	FROM athlete_events
	WHERE Medal = 'Gold'
	GROUP BY Name
	),

T2 AS
	(
	--USING DENSE_RANK TO FIND THE ORDER INSTEAD OF TOP
	SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) AS RNK
	FROM T1
	)

SELECT * FROM T2
WHERE RNK <= 5;


----list down total gold, silver and bronze medals won by each country
--SELECT country, [Gold] as gold_medals, [Silver] as silver_medals, [Bronze] as bronze_medals
--FROM
--(
--SELECT nr.region as country, Medal, COUNT(1) as total_medals
--FROM athlete_events ae
--JOIN noc_regions nr
--ON ae.NOC = nr.NOC
--WHERE Medal <> 'NA'
--GROUP BY nr.region, Medal
--) AS firsttable
--PIVOT
--(
--	COUNT(Medal)
--	FOR Medal IN ([Gold], [Silver], [Bronze])
--) AS Pivottable
--GROUP BY [Gold],[Silver],[Bronze]
--ORDER BY country

-- List down total gold, silver, and bronze medals won by each country
SELECT country, 
       ISNULL([Gold], 0) AS gold_medals, 
       ISNULL([Silver], 0) AS silver_medals, 
       ISNULL([Bronze], 0) AS bronze_medals
FROM
(
    SELECT nr.region AS country, Medal, COUNT(*) AS total_medals
    FROM athlete_events ae
    JOIN noc_regions nr ON ae.NOC = nr.NOC
    WHERE Medal <> 'NA'
    GROUP BY nr.region, Medal
) AS firsttable
PIVOT
(
    SUM(total_medals) -- Using SUM instead of COUNT inside PIVOT
    FOR Medal IN ([Gold], [Silver], [Bronze])
) AS Pivottable
ORDER BY country
;

--Which Sports were just played only once in the olympics?
SELECT Sport, COUNT(DISTINCT Games) AS gamesplayed
FROM athlete_events
GROUP BY Sport
HAVING COUNT(DISTINCT Games) = 1

--Fetch the total no of sports played in each olympic games.
SELECT Games, COUNT(DISTINCT Sport) AS Sportsplayed
FROM athlete_events
GROUP BY Games
ORDER BY Games

--Fetch oldest athletes to win a gold medal
SELECT Name, Age
FROM athlete_events
WHERE Medal = 'Gold'
	  AND Age = 
(SELECT MAX(Age) maxage 
 FROM athlete_events 
 WHERE Medal = 'Gold' AND Age NOT LIKE 'NA'
);

--Find the Ratio of male and female athletes participated in all olympic games.
SELECT ROUND(Male_female_Ratio, 2) MALE_TO_FEMALE_RATIO
FROM
(
SELECT 
    CAST(COUNT(CASE WHEN Sex = 'M' THEN 1 END) AS FLOAT) /
    NULLIF(COUNT(CASE WHEN Sex = 'F' THEN 1 END), 0) AS Male_Female_Ratio
FROM athlete_events) AS RATIO;

--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
WITH T1 AS
(
SELECT nr.region Region, COUNT(Medal) no_of_medals
FROM athlete_events ae
JOIN noc_regions nr
ON ae.NOC = nr.NOC
WHERE Medal NOT LIKE 'NA'
GROUP BY nr.region
--ORDER BY COUNT(Medal) DESC
),
T2 AS
(SELECT *, DENSE_RANK() OVER(ORDER BY no_of_medals DESC) AS RNK
FROM T1)

SELECT *
FROM T2
WHERE RNK <= 5

--List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
SELECT Games, Regions,
	   ISNULL([Gold],0) AS Gold_medals,
	   ISNULL([Silver],0) AS Silver_medals,
	   ISNULL([Bronze],0) AS Bronze_medals
FROM
(
	SELECT Games, nr.region Regions, Medal, COUNT(Medal) total_medals
	FROM athlete_events ae
	JOIN noc_regions nr
	ON ae.NOC = nr.NOC
	WHERE Medal <> 'NA'
	GROUP BY Games, nr.region, Medal
	--ORDER BY Games
) AS Table1
PIVOT
(
	SUM(total_medals)
	FOR Medal IN ([Gold],[Silver],[Bronze])
) AS Pivottable
ORDER BY Games
