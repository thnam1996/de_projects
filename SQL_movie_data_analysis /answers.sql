-- Segment 1:
-- Q1. Find the total number of rows in each table of the schema?
SELECT COUNT(*)
FROM movie;

SELECT COUNT(*)
FROM genre;

SELECT COUNT(*)
FROM ratings;

SELECT COUNT(*)
FROM director_mapping;

SELECT COUNT(*)
FROM names;

SELECT COUNT(*)
FROM role_mapping;

-- Q2. Which columns in the movie table have null values?

SELECT
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
    SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_nulls,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worldwide_gross_income_nulls,
    SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_nulls,
    SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_nulls
FROM movie;
-- null column: country, worlwide_gross_income,languages, production_company
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
-- Number of movies release each year:
SELECT year, COUNT(DISTINCT (id)) as number_of_movies
FROM movie
GROUP BY year
ORDER BY year;
--Trend over month
SELECT EXTRACT(MONTH FROM date_published) AS Month, COUNT(DISTINCT (id)) as number_of_movies
FROM movie
GROUP BY month
ORDER BY month;

-- Q4. How many movies were produced in the USA or India in the year 2019??
SELECT COUNT(DISTINCT (id))
FROM movie
WHERE (country LIKE '%USA%' OR country LIKE '%India%')
AND year=2019;

-- Q5. Find the unique list of the genres present in the data set?
SELECT DISTINCT(genre)
FROM genre
ORDER BY genre;

-- Q6.Which genre had the highest number of movies produced overall?
SELECT genre, count(DISTINCT(movie_id)) AS number_of_movies
FROM genre
GROUP BY genre
ORDER BY number_of_movies DESC
;

-- Q7. How many movies belong to only one genre?
SELECT COUNT(DISTINCT(g.movie_id))
FROM
(SELECT movie_id, COUNT(DISTINCT(genre)) AS number_of_genres
 FROM genre
 GROUP BY movie_id
 HAVING COUNT(DISTINCT(genre))=1) AS g;

-- Q8.What is the average duration of movies in each genre?
SELECT p1.genre, ROUND(AVG(p2.duration),2) AS AVG_Duration
FROM genre AS p1
INNER JOIN movie AS p2 ON
p1.movie_id=p2.id
GROUP BY p1.genre
ORDER BY AVG_Duration DESC;


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced?
SELECT
    genre,
    COUNT(DISTINCT movie_id) AS number_of_movies,
    DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT movie_id) DESC) AS rank
FROM genre
GROUP BY genre;

-- Segment 2:
-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
SELECT
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM ratings;

-- Q11. Which are the top 10 movies based on average rating?
SELECT
    m.title,
    r.avg_rating,
    DENSE_RANK() OVER (ORDER BY R.avg_rating DESC) AS rank
FROM ratings AS r
INNER JOIN movie AS m ON
    r.movie_id=m.id
ORDER BY r.avg_rating DESC, m.title
LIMIT 10;

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
SELECT median_rating,count(movie_id) as movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
SELECT production_company,
       COUNT(id) AS movie_count,
       DENSE_RANK() OVER (ORDER BY COUNT(ID) DESC) AS prod_company_rank
FROM movie
WHERE id in
(SELECT movie_id
FROM ratings
WHERE avg_rating >8)
AND production_company IS NOT NULL
GROUP BY production_company;


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

SELECT genre, COUNT(DISTINCT movie_id) AS movie_count
FROM genre
WHERE movie_id in
    (SELECT id
     FROM movie AS m
     INNER JOIN ratings AS r ON
                m.id=r.movie_id
     WHERE m.country LIKE '%USA%'
            AND TO_CHAR(m.date_published, 'MM-YYYY') = '03-2017'
            AND r.total_votes>1000)
GROUP BY genre
ORDER BY movie_count DESC;

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
SELECT m.title, r.avg_rating, g.genre
FROM genre AS g
INNER JOIN movie AS m
    on g.movie_id=m.id
INNER JOIN ratings AS r
    on g.movie_id=r.movie_id
WHERE r.avg_rating>8 AND m.title LIKE 'The%'
ORDER BY g.genre,r.avg_rating DESC, m.title;

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
SELECT COUNT(*)
FROM movie
WHERE id IN
    (SELECT movie_id
    FROM ratings
    WHERE median_rating=8)
AND date_published BETWEEN '2018-04-01' AND '2019-04-01';

-- Q17. Do German movies get more votes than Italian movies?
WITH target AS (
    SELECT
    id,
      CASE
        WHEN country LIKE '%Germany%' THEN 'Germnay'
        WHEN country LIKE '%Italy%' THEN 'Italy'
      END AS group
    FROM movie
    WHERE
      CASE
        WHEN country LIKE '%Germany%' THEN 'Germany'
        WHEN country LIKE '%Italy%' THEN 'Italy'
      END IS NOT NULL)

SELECT t.group, SUM(total_votes)
FROM target t
INNER JOIN ratings r ON
    t.id=r.movie_id
GROUP BY t.group;

-- Segment 3:
-- Q18. Which columns in the names table have null values??
SELECT
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth,
    SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies
FROM names;

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
WITH top_genre AS
    (SELECT g.genre
      FROM genre g
      INNER JOIN ratings r ON
          g.movie_id=r.movie_id
      WHERE r.avg_rating > 8
      GROUP BY g.genre
      ORDER BY COUNT(g.movie_id) DESC
      LIMIT 3),
    top_movie AS
    (SELECT g.movie_id
    FROM genre g
    INNER JOIN ratings r ON
          g.movie_id=r.movie_id
    INNER JOIN top_genre t ON
          g.genre=t.genre
    WHERE r.avg_rating > 8)
SELECT n.name, COUNT(DISTINCT d.movie_id)
FROM director_mapping d
INNER JOIN names n ON
    d.name_id = n.id
WHERE movie_id IN (SELECT movie_id FROM top_movie)
GROUP BY n.name
ORDER BY COUNT(d.movie_id) DESC
LIMIT 3;

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
SELECT name, number_of_movies
FROM (SELECT n.name,
       COUNT(DISTINCT(ro.movie_id)) AS number_of_movies,
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT(ro.movie_id)) DESC) AS rnk
FROM role_mapping ro
INNER JOIN ratings ra ON ro.movie_id=ra.movie_id
INNER JOIN names n ON ro.name_id=n.id
WHERE ra.median_rating>=8 AND ro.category='actor'
GROUP BY n.name) t
WHERE rnk <=2;

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
SELECT production_company,vote_count, prod_comp_rank
FROM (
    SELECT m.production_company,
       SUM(r.total_votes) AS vote_count,
       DENSE_RANK() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
    FROM movie m
    INNER JOIN ratings r ON m.id=r.movie_id
    WHERE m.production_company IS NOT NULL
    GROUP BY m.production_company
    ) AS t
WHERE prod_comp_rank <=3;

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
WITH actor AS (
        SELECT n.name, SUM(ra.total_votes) AS total_votes, COUNT(DISTINCT m.id) AS movie_count, SUM(ra.total_votes*ra.avg_rating)/SUM(ra.total_votes) AS actor_avg_rating
        FROM movie m
        INNER JOIN ratings ra ON m.id=ra.movie_id
        INNER JOIN role_mapping ro ON m.id=ro.movie_id
        INNER JOIN names n ON ro.name_id=n.id
        WHERE m.country LIKE '%India%'
            AND ro.category='actor'
        GROUP BY n.name
        HAVING COUNT(DISTINCT m.id) >= 5)
SELECT name, total_votes, movie_count, ROUND(actor_avg_rating,2) AS actor_avg_rating,
       DENSE_RANK() OVER (ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM actor;

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings?

WITH actress AS (
        SELECT n.name, SUM(ra.total_votes) AS total_votes, COUNT(DISTINCT m.id) AS movie_count, SUM(ra.total_votes*ra.avg_rating)/SUM(ra.total_votes) AS actor_avg_rating
        FROM movie m
        INNER JOIN ratings ra ON m.id=ra.movie_id
        INNER JOIN role_mapping ro ON m.id=ro.movie_id
        INNER JOIN names n ON ro.name_id=n.id
        WHERE m.languages LIKE '%Hindi%'
            AND m.country LIKE '%India%'
            AND ro.category='actress'
        GROUP BY n.name
        HAVING COUNT(DISTINCT m.id) >= 3),
     rank AS (
        SELECT name, total_votes, movie_count, ROUND(actor_avg_rating,2) AS actress_avg_rating,
               DENSE_RANK() OVER (ORDER BY actor_avg_rating DESC, total_votes DESC) AS actress_rank
        FROM actress)
SELECT name, total_votes, movie_count, actress_avg_rating, actress_rank
FROM rank
WHERE actress_rank<=5;

/* Q24. Select thriller movies as per avg rating and classify them in the following category:

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
SELECT m.title,r.avg_rating,
    CASE WHEN r.avg_rating>8 THEN 'Superhit movies'
         WHEN r.avg_rating>7 THEN 'Hit movies'
         WHEN r.avg_rating>5 THEN 'One-time-watch movies'
         ELSE 'Flop movies' END AS category

FROM movie m
INNER JOIN ratings r ON m.id=r.movie_id
INNER JOIN genre g ON m.id= g.movie_id
WHERE g.genre='Thriller'
ORDER BY r.avg_rating DESC, m.title;

-- Q25. What is the genre-wise running total and moving average of the average movie duration?
WITH duration AS    (
    SELECT g.genre, AVG(m.duration) AS avg_duration
    FROM movie m
    INNER JOIN genre g ON m.id=g.movie_id
    GROUP BY g.genre)
SELECT genre,
       avg_duration,
        ROUND(SUM(avg_duration) OVER (ORDER BY genre ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS running_total_duration,
        ROUND(AVG(avg_duration) OVER (ORDER BY genre ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),2) AS moving_avg_duration
FROM duration;

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres?
-- Top 3 Genres based on most number of movies
SELECT genre, COUNT(DISTINCT movie_id) AS total_movies
FROM genre
GROUP BY genre
ORDER BY total_movies DESC
LIMIT 3;
--check currency in worldwide_gross_income
SELECT DISTINCT
    REGEXP_REPLACE(worlwide_gross_income, '[0-9., ]', '', 'g') AS currency_symbol
FROM movie
WHERE worlwide_gross_income IS NOT NULL;
-- 2 currency: INR & USD -> TRANSLATE TO $
-- five highest-grossing movies of each year that belong to the top three genres?
WITH income AS (
        SELECT
            id,year,title,
            CASE
                WHEN worlwide_gross_income LIKE 'INR%' THEN
                    REGEXP_REPLACE(worlwide_gross_income, '[^0-9.]', '', 'g')::numeric * 0.012
                WHEN worlwide_gross_income LIKE '$%' THEN
                    REGEXP_REPLACE(worlwide_gross_income, '[^0-9.]', '', 'g')::numeric
                ELSE NULL
            END AS worlwide_gross_income_USD
        FROM movie)

SELECT genre,year,movie_name, worlwide_gross_income_USD,movie_rank
FROM (SELECT g.genre,
       i.year,
       i.title as movie_name,
       i.worlwide_gross_income_USD,
       DENSE_RANK() OVER (PARTITION BY g.genre, i.year ORDER BY i.worlwide_gross_income_USD DESC) AS movie_rank
FROM income i
INNER JOIN genre g ON i.id=g.movie_id
WHERE i.worlwide_gross_income_USD IS NOT NULL
AND g.genre in (
    SELECT genre
    FROM genre
    GROUP BY genre
    ORDER BY COUNT(DISTINCT movie_id) DESC
    LIMIT 3
    )
    ) AS t
WHERE movie_rank <= 5;

-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
SELECT production_company, movie_count, prod_comp_rank
FROM
    (SELECT m.production_company,
            COUNT(DISTINCT m.id) AS movie_count,
            DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT m.id) DESC) AS prod_comp_rank
     FROM movie m
     INNER JOIN ratings r ON m.id = r.movie_id
     WHERE position(',' IN languages) > 0
            AND r.median_rating >= 8
            AND m.production_company IS NOT NULL
     GROUP BY m.production_company
     ) AS t
WHERE prod_comp_rank <=2;

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
WITH actress AS (
        SELECT n.name, SUM(ra.total_votes) AS total_votes, COUNT(DISTINCT ro.movie_id) AS movie_count, SUM(ra.total_votes*ra.avg_rating)/SUM(ra.total_votes) AS actor_avg_rating
        FROM role_mapping ro
        INNER JOIN ratings ra ON ro.movie_id=ra.movie_id
        INNER JOIN genre g ON ro.movie_id=g.movie_id
        INNER JOIN names n ON ro.name_id=n.id
        WHERE ra.avg_rating > 8
            AND ro.category='actress'
            AND g.genre = 'Drama'
        GROUP BY n.name),
     rank AS (
            SELECT name, total_votes, movie_count, ROUND(actor_avg_rating,2) AS actress_avg_rating,
                   DENSE_RANK() OVER (ORDER BY movie_count DESC) AS actress_rank
            FROM actress)
SELECT name, total_votes, movie_count, actress_avg_rating, actress_rank
FROM rank
WHERE actress_rank <=3;

-- Q29. Get the following details for top 9 directors (based on number of movies)

WITH base AS (
        SELECT d.name_id,
               n.name,
               d.movie_id,
               r.avg_rating,
               r.total_votes,
               m.duration,
               m.date_published,
               LEAD(date_published) OVER (PARTITION BY d.name_id ORDER BY m.date_published NULLS LAST) - m.date_published AS diff_days

        FROM director_mapping d
        INNER JOIN ratings r ON d.movie_id=r.movie_id
        INNER JOIN names n ON d.name_id=n.id
        INNER JOIN movie m ON d.movie_id=m.id),
      top_director AS (
        SELECT name_id
        FROM base
        GROUP BY name_id
        ORDER BY count(DISTINCT (movie_id)) DESC
        LIMIT 9
      )

SELECT name_id AS director_id,
       name AS director_name,
       COUNT(DISTINCT movie_id) AS number_of_movies,
       ROUND(AVG(diff_days),2) As avg_inter_movie_days,
       ROUND(AVG(avg_rating),2) AS avg_rating,
       SUM(total_votes) AS total_votes,
       MIN(avg_rating) AS min_rating,
       MAX(avg_rating) AS max_rating,
       SUM(duration) AS total_duration
FROM base
WHERE name_id IN (
    SELECT *
    FROM top_director
    )
GROUP BY name_id, name;

SELECT g.genre, avg(r.avg_rating);

