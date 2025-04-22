DROP TABLE DISTANCES;
CREATE TABLE DISTANCES
(
Source VARCHAR(150),
Destination VARCHAR(150),
Distance FLOAT
);
INSERT INTO DISTANCES VALUES
('A','B',21),
('B','A',28),
('A','B',19),
('C','D',15),
('C','D',17),
('D','C',16.5),
('D','C',18);

SELECT * FROM DISTANCES


--Calculate average distance between the locations like, for example if we take A to B route 1
--21 miles etc

WITH CTE AS
(

	SELECT Source, Destination, SUM(Distance) Total_distance, COUNT(*) No_of_routes, ROW_NUMBER() OVER(ORDER BY Source) AS id
	FROM DISTANCES
	GROUP BY Source, Destination
)

SELECT t1.Source, t1.destination, ((t1.Total_distance + t2.Total_distance)/(t1.No_of_routes + t2.No_of_routes)) as avg_distance
FROM CTE t1
JOIN CTE t2 ON t1.source = t2.destination AND t1.id < t2.id
