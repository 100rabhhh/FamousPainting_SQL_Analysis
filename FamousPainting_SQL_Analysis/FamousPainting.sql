select * from artist;
select * from canvas_size;
select * from image_link;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from subject;
select * from work;

--1) Fetch all the paintings which are not displayed on any museums?

select * from work
where museum_id is null;

--2) Are there museuems without any paintings?

select *
from museum m
LEFT JOIN work w
ON m.museum_id = w.museum_id
Where w.work_id is NULL
;

select * from museum m
	where not exists (select 1 from work w
					 where w.museum_id=m.museum_id)

--3) How many paintings have an asking price of more than their regular price? 

select * from product_size
where sale_price > regular_price;

select count(*) as total
from product_size
WHERE sale_price > regular_price;

--4) Identify the paintings whose asking price is less than 50% of its regular price

select * from product_size
where sale_price < (regular_price * 0.5);

--5) Which canva size costs the most?

SELECT c.label as canva, p.sale_price as sale_price
FROM product_size AS p
JOIN canvas_size as c ON p.size_id = c.size_id::text
ORDER BY p.sale_price DESC
LIMIT 1;
                       --or--
select c.label as conva, p.sale_price as sale_price
from ( select *,
		rank() over(order by sale_price desc) as rnk
		from product_size) p
join canvas_size as c 
on c.size_id = p.size_id::bigint
where p.rnk=1;

--product size wale mai size_id text format mai hai to usko bhi usko bhi bigint mai type cast kar diya
--ya fir hum canvas size wale mai to size_id hai usko change karke text kar sakte hai to output same dega 

--6) Delete duplicate records from work, product_size, subject and image_link tables
delete from work 
	where ctid not in (select min(ctid)
						from work
						group by work_id );

	delete from product_size 
	where ctid not in (select min(ctid)
						from product_size
						group by work_id, size_id );

	delete from subject 
	where ctid not in (select min(ctid)
						from subject
						group by work_id, subject );

	delete from image_link 
	where ctid not in (select min(ctid)
						from image_link
						group by work_id );

--ctid is a system column in PostgreSQL that uniquely identifies rows based on their
--physical location in the table. The subquery finds the smallest ctid for each work_id,
--while the DELETE query removes all other rows, ensuring only one instance per work_id remains.

--7) Identify the museums with invalid city information in the given dataset

select * from museum 
where city ~ '^[0-9]'

--the ~ operator checks if city starts with a digit, using ^ to mark the beginning 
--and [0-9] to match any digit, returning rows where the city field begins with a number, 
--typically indicating invalid city names.

--8) Museum_Hours table has 1 invalid entry. Identify it and remove it.

delete from museum_hours 
	where ctid not in (select min(ctid)
						from museum_hours
						group by museum_id, day );

--9) Fetch the top 10 most famous painting subject

--1st Ranking with Window Functions (RANK).
SELECT *
FROM (
    SELECT s.subject, 
           COUNT(1) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
		   
    FROM work w
    JOIN subject s ON s.work_id = w.work_id
    GROUP BY s.subject
) x
WHERE rnk <= 10;

--2nd Aggregation with JOIN and Grouping.
select distinct subject, count(*) as subject_count
from subject s
join work w on s.work_id=w.work_id
group by subject
order by subject_count desc
limit 10;

--3rd Simple Aggregation with Grouping
SELECT subject, COUNT(*) AS subject_count
FROM subject
GROUP BY subject
ORDER BY subject_count DESC
LIMIT 10;

--10) Identify the museums which are open on both Sunday and Monday. 
--Display museum name, city.

select m.museum_id, m.name as museum_name, m.city 
from museum_hours mh
join museum m on m.museum_id = mh.museum_id
where day='Sunday'
and exists (select 1 from museum_hours mh2
			where mh2.museum_id = mh.museum_id
			and mh2.day='Monday');
			
--EXISTS is used for subquery filtering, checking if a museum_id is open on both 'Sunday' and 'Monday', 
--with SELECT 1 simply confirming row existence.

--11) How many museums are open every single day?

select count(*) from (
						select museum_id, count(*) 
						from museum_hours
						group by museum_id
						having count(*) =7) x;

--12) Which are the top 5 most popular museum? 
--(Popularity is defined based on most no of paintings in a museum)
						
select m.name as museum, m.city,m.country,x.no_of_painintgs
from (	select m.museum_id, count(1) as no_of_painintgs
		, rank() over(order by count(1) desc) as rnk
		from work w
		join museum m on m.museum_id=w.museum_id
		group by m.museum_id) x
join museum m on m.museum_id=x.museum_id
where x.rnk<=5;

--with CTE
WITH ranked_museums AS (
    SELECT m.museum_id, 
           COUNT(1) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN museum m ON m.museum_id = w.museum_id
    GROUP BY m.museum_id
)
SELECT m.name AS museum, m.city, m.country, rm.no_of_paintings
FROM ranked_museums rm
JOIN museum m ON m.museum_id = rm.museum_id
WHERE rm.rnk <= 5;

--13) Who are the top 5 most popular artist? 
--(Popularity is defined based on most no of paintings done by an artist)

SELECT a.full_name AS artist, a.nationality, x.no_of_paintings
FROM (
    SELECT a.artist_id, COUNT(1) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN artist a ON a.artist_id = w.artist_id
    GROUP BY a.artist_id
) x
JOIN artist a ON a.artist_id = x.artist_id
WHERE x.rnk <= 5;

--with CTE

WITH ranked_artists AS (
    SELECT a.artist_id, 
           COUNT(1) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN artist a ON a.artist_id = w.artist_id
    GROUP BY a.artist_id
)
SELECT a.full_name AS artist, a.nationality, ra.no_of_paintings
FROM ranked_artists ra
JOIN artist a ON a.artist_id = ra.artist_id
WHERE ra.rnk <= 5;


--14) Display the 3 least popular canva sizes
--WITH Derived Table
SELECT label, ranking, no_of_paintings
FROM (
    SELECT cs.size_id, cs.label, COUNT(1) AS no_of_paintings,
           DENSE_RANK() OVER (ORDER BY COUNT(1)) AS ranking
    FROM work w
    JOIN product_size ps ON ps.work_id = w.work_id
    JOIN canvas_size cs ON cs.size_id::text = ps.size_id
    GROUP BY cs.size_id, cs.label
) x
WHERE x.ranking <= 3;

--WITH CTE

WITH ranked_sizes AS (
    SELECT cs.size_id, cs.label, COUNT(1) AS no_of_paintings,
           DENSE_RANK() OVER (ORDER BY COUNT(1)) AS ranking
    FROM work w
    JOIN product_size ps ON ps.work_id = w.work_id
    JOIN canvas_size cs ON cs.size_id::text = ps.size_id
    GROUP BY cs.size_id, cs.label
)
SELECT label, ranking, no_of_paintings
FROM ranked_sizes
WHERE ranking <= 3;

--15) Which museum is open for the longest during a day. 
--Dispay museum name, state and hours open and which day?
SELECT museum_name, state AS city, day, open, close, duration
FROM (
    SELECT m.name AS museum_name, m.state, day, open, close,
           to_timestamp(open, 'HH:MI AM') AS open_time,
           to_timestamp(close, 'HH:MI PM') AS close_time,
           to_timestamp(close, 'HH:MI PM') - to_timestamp(open, 'HH:MI AM') AS duration,
           RANK() OVER (ORDER BY (to_timestamp(close, 'HH:MI PM') - to_timestamp(open, 'HH:MI AM')) DESC) AS rnk
    FROM museum_hours mh
    JOIN museum m ON m.museum_id = mh.museum_id
) x
WHERE x.rnk = 1;

--WITH CTE
WITH ranked_museum_hours AS (
    SELECT m.name AS museum_name, m.state, day, open, close,
           to_timestamp(open, 'HH:MI AM') AS open_time,
           to_timestamp(close, 'HH:MI PM') AS close_time,
           to_timestamp(close, 'HH:MI PM') - to_timestamp(open, 'HH:MI AM') AS duration,
           RANK() OVER (ORDER BY (to_timestamp(close, 'HH:MI PM') - to_timestamp(open, 'HH:MI AM')) DESC) AS rnk
    FROM museum_hours mh
    JOIN museum m ON m.museum_id = mh.museum_id
)
SELECT museum_name, state AS city, day, open, close, duration
FROM ranked_museum_hours
WHERE rnk = 1;

--16) Which museum has the most no of most popular painting style?
WITH pop_style AS 
    (SELECT style,
            RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
     FROM work
     GROUP BY style),
cte AS
    (SELECT w.museum_id,
            m.name AS museum_name,
            w.style,
            COUNT(1) AS no_of_paintings,
            RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
     FROM work w
     JOIN museum m ON m.museum_id = w.museum_id
     JOIN pop_style ps ON ps.style = w.style
     WHERE w.museum_id IS NOT NULL
       AND ps.rnk = 1
     GROUP BY w.museum_id, m.name, w.style)
SELECT museum_name, style, no_of_paintings
FROM cte 
WHERE rnk = 1;

--17) Identify the artists whose paintings are displayed in multiple countries.
WITH cte AS (
    SELECT DISTINCT a.full_name AS artist,
           m.country
    FROM work w
    JOIN artist a ON a.artist_id = w.artist_id
    JOIN museum m ON m.museum_id = w.museum_id
)
SELECT artist, COUNT(1) AS no_of_countries
FROM cte
GROUP BY artist
HAVING COUNT(1) > 1
ORDER BY no_of_countries DESC;

--18) Display the country and the city with most no of museums. 
--Output 2 seperate columns to mention the city and country. 
--If there are multiple value, seperate them with comma.

WITH cte_country AS (
    SELECT country,
           COUNT(1) AS country_count,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM museum
    GROUP BY country
),
cte_city AS (
    SELECT city,
           COUNT(1) AS city_count,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM museum
    GROUP BY city
)
SELECT 
    STRING_AGG(DISTINCT country.country, ', ') AS countries,
    STRING_AGG(city.city, ', ') AS cities
FROM cte_country country
CROSS JOIN cte_city city
WHERE country.rnk = 1
  AND city.rnk = 1;


--WITH SUBQUERY
SELECT 
    STRING_AGG(DISTINCT country, ', ') AS countries,
    STRING_AGG(city, ', ') AS cities
FROM (
    SELECT country, 
           COUNT(1) AS country_count,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM museum
    GROUP BY country
) AS country_data
JOIN (
    SELECT city,
           COUNT(1) AS city_count,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM museum
    GROUP BY city
) AS city_data ON country_data.rnk = 1 AND city_data.rnk = 1
GROUP BY country_data.rnk, city_data.rnk;

--19) Identify the artist and the museum where the most expensive and least expensive painting is placed. 
--Display the artist name, sale_price, painting name, museum name, museum city and canvas label.
SELECT w.name AS painting,
       ps.sale_price,
       a.full_name AS artist,
       m.name AS museum,
       m.city,
       cz.label AS canvas
FROM work w
JOIN product_size ps ON ps.work_id = w.work_id
JOIN museum m ON m.museum_id = w.museum_id
JOIN artist a ON a.artist_id = w.artist_id
JOIN canvas_size cz ON cz.size_id = ps.size_id::NUMERIC
WHERE ps.sale_price = (SELECT MAX(sale_price) FROM product_size) 
   OR ps.sale_price = (SELECT MIN(sale_price) FROM product_size);

--WITH CTE
WITH cte AS (
    SELECT *,
           RANK() OVER (ORDER BY sale_price DESC) AS rnk,
           RANK() OVER (ORDER BY sale_price) AS rnk_asc
    FROM product_size
)
SELECT w.name AS painting,
       cte.sale_price,
       a.full_name AS artist,
       m.name AS museum,
       m.city,
       cz.label AS canvas
FROM cte
JOIN work w ON w.work_id = cte.work_id
JOIN museum m ON m.museum_id = w.museum_id
JOIN artist a ON a.artist_id = w.artist_id
JOIN canvas_size cz ON cz.size_id = cte.size_id::NUMERIC
WHERE rnk = 1 OR rnk_asc = 1;

--20) Which country has the 5th highest no of paintings?
WITH cte AS (
    SELECT m.country,
           COUNT(1) AS no_of_Paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN museum m ON m.museum_id = w.museum_id
    GROUP BY m.country
)
SELECT country, 
       no_of_Paintings
FROM cte 
WHERE rnk = 5;

--WITH SUBQUERY
SELECT country,
       no_of_Paintings
FROM (
    SELECT m.country,
           COUNT(1) AS no_of_Paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN museum m ON m.museum_id = w.museum_id
    GROUP BY m.country
) AS ranked_countries
WHERE rnk = 5;

--21) Which are the 3 most popular and 3 least popular painting styles?
WITH cte AS (
    SELECT style,
           COUNT(1) AS cnt,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk,
           COUNT(1) OVER () AS no_of_records
    FROM work
    WHERE style IS NOT NULL
    GROUP BY style
)
SELECT style,
       CASE 
           WHEN rnk <= 3 THEN 'Most Popular' 
           ELSE 'Least Popular' 
       END AS remarks 
FROM cte
WHERE rnk <= 3
   OR rnk > no_of_records - 3;

--WITH SUBQUERY
SELECT style,
       CASE 
           WHEN rnk <= 3 THEN 'Most Popular' 
           ELSE 'Least Popular' 
       END AS remarks 
FROM (
    SELECT style,
           COUNT(1) AS cnt,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk,
           COUNT(1) OVER () AS no_of_records
    FROM work
    WHERE style IS NOT NULL
    GROUP BY style
) AS ranked_styles
WHERE rnk <= 3
   OR rnk > no_of_records - 3;

--22) Which artist has the most no of Portraits paintings outside USA?. 
--Display artist name, no of paintings and the artist nationality.
WITH artist_paintings AS (
    SELECT a.full_name,
           a.nationality,
           COUNT(1) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN artist a ON a.artist_id = w.artist_id
    JOIN subject s ON s.work_id = w.work_id
    JOIN museum m ON m.museum_id = w.museum_id
    WHERE s.subject = 'Portraits'
      AND m.country != 'USA'
    GROUP BY a.full_name, a.nationality
)
SELECT full_name AS artist_name,
       nationality,
       no_of_paintings
FROM artist_paintings
WHERE rnk = 1;

--WITH SUBQUERY
SELECT full_name AS artist_name,
       nationality,
       no_of_paintings
FROM (
    SELECT a.full_name,
           a.nationality,
           COUNT(1) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM work w
    JOIN artist a ON a.artist_id = w.artist_id
    JOIN subject s ON s.work_id = w.work_id
    JOIN museum m ON m.museum_id = w.museum_id
    WHERE s.subject = 'Portraits'
      AND m.country != 'USA'
    GROUP BY a.full_name, a.nationality
) AS x
WHERE rnk = 1;





	