CREATE TABLE youtube (
  show_id VARCHAR(20),
  type VARCHAR(10),
  title VARCHAR(150),
  director VARCHAR(208),
  casts VARCHAR(1000),
  country VARCHAR(150),
  date_added VARCHAR(50),
  release_year INT,
  rating VARCHAR(10),
  duration VARCHAR(15),
  listed_in VARCHAR(25),
  description VARCHAR(250)
);

ALTER TABLE youtube
ALTER COLUMN listed_in TYPE VARCHAR(100);

SELECT * FROM youtube;

SELECT COUNT(*) as total_content
FROM youtube;

SELECT DISTINCT Type 
FROM youtube;

SELECT * FROM youtube;

--Business Problems--
(日本語訳『YouTubeデータから読み解くビジネス課題』)

--1.Count the number of Movies and TV Shows
(日本語訳：『映画とテレビ番組の数をそれぞれ数えなさい』)

SELECT 
	type,
	COUNT(*) as total_content
FROM youtube
GROUP BY type

--2.Count the number of nations
(日本語訳：『国の数をかぞえなさい』)

SELECT 
  TRIM(country_clean) AS country,
  COUNT(*) AS total_content
FROM (
  SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country_clean
  FROM youtube
  WHERE country IS NOT NULL
) AS sub
GROUP BY TRIM(country_clean)
ORDER BY total_content DESC;

	
--3.Find the most common rating for movies and TV shows
（日本語訳：『映画とテレビ番組の中で最も多い評価を見つけなさい』）
	
SELECT 
	type,
	rating
FROM
(	
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK()OVER (PARTITION BY type ORDER BY COUNT (*) DESC) as ranking
	FROM youtube
	GROUP BY 1,2
)as sub
WHERE 
	ranking=1;

--4.Find the top 3 rating for movies and TV shows
（日本語訳：『映画とテレビ番組の中で最も多い評価の３つを見つけなさい」）

SELECT 
	type,
	rating
FROM
(
SELECT type,rating,count(*),RANK()OVER (PARTITION BY type ORDER BY COUNT(*) DESC) 
	as rankingranking
FROM youtube
	GROUP BY 1,2
)as sub
WHERE rankingranking<=3
	ORDER BY type,rating;

--5.List all movies released in a specific year(e.g.2020)
(日本語訳：『特定の一年にリリースされた映画を全て一覧にしなさい』)

SELECT * FROM youtube
WHERE type = 'Movie' and release_year=2020;

--6.List all TV Shows released in a specific year(e.g.2021)
(日本語訳：『特定の一年にリリースされたテレビ番組を全て一覧にしなさい』)

SELECT * FROM youtube
WHERE type='TV Show' and release_year='2021';

--7.Find the top 5 countries with the most content on YOUTUBE
(日本語訳：『YOUTUBEで最も多い内容を提供している国のトップ5を見つけなさい』)

SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_content
FROM youtube
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--8.Find the top 5 countries with the least content on YOUTUBE
(日本語訳：『YOUTUBEで最も少ない内容を提供している国のトップ5を見つけなさい』)

SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) as newnew_country,
	COUNT(show_id) as total_total_content
FROM youtube
GROUP BY 1
ORDER BY 2 ASC
LIMIT 5

--9.Identify the longest movie?
(日本語訳：『最も長い映画を特定せよ』)

SELECT * FROM youtube
WHERE type = 'Movie'
  AND duration LIKE '%min'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) = (
    SELECT MAX(CAST(SPLIT_PART(duration, ' ', 1) AS INT))
    FROM youtube
    WHERE type = 'Movie' AND duration LIKE '%min'
);

--10.Identify the second longest movie?
（日本語訳：『二番目に長い映画を特定せよ』）

SELECT * FROM youtube
WHERE type = 'Movie'
  AND duration LIKE '%min'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) = (
    SELECT MAX(duration_int)
    FROM (
        SELECT DISTINCT CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS duration_int
        FROM youtube
        WHERE type = 'Movie' AND duration LIKE '%min'
    ) AS sub
    WHERE duration_int < (
        SELECT MAX(CAST(SPLIT_PART(duration, ' ', 1) AS INT))
        FROM youtube
        WHERE type = 'Movie' AND duration LIKE '%min'
    )
);

--11.Identify the longest movies based on the national name
（日本語：『国別に最長の映画を特定せよ』）

SELECT
  country_clean,
  title,
  duration
FROM (
  SELECT
    title,
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_clean,
    duration,
    CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS duration_min,
    RANK() OVER (
      PARTITION BY TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))
      ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INT) DESC
    ) AS ranking
  FROM youtube
  WHERE type = 'Movie' AND duration LIKE '%min'
) AS ranked_movies
WHERE ranking = 1;

--12.Find content added in the last 5years
(日本語：『ここ5年間で加えられたコンテンツを見つけなさい』)

SELECT * 
FROM youtube
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

SELECT *
FROM youtube
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= 
  (
    SELECT MAX(TO_DATE(date_added, 'Month DD, YYYY'))
    FROM youtube
  ) - INTERVAL '5 years';

--13.Find content added in the first 3years
（『はじめの３年間で加えられたコンテンツを見つけなさい』）

SELECT *
FROM youtube
WHERE TO_DATE(date_added, 'Month DD, YYYY') BETWEEN
  (SELECT MIN(TO_DATE(date_added, 'Month DD, YYYY')) FROM youtube)
  AND
  (SELECT MIN(TO_DATE(date_added, 'Month DD, YYYY')) FROM youtube) + INTERVAL '3 years';

--14.Find all the movies/TV shows by director 'Rajiv Chilaka'
（日本語訳：『'Rajiv Chilaka'監督の映画もしくはテレビ番組を全て見つけなさい』）

SELECT * FROM youtube
WHERE director ILIKE '%Rajiv Chilaka%'

--15.List all TV shows with more than 5 seasons
（日本語訳：『5シーズン以上のテレビ番組を一覧にしなさい』）
	
SELECT *
FROM youtube
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;

--16.Count all TV shows with more than 5 sessions
（日本語訳：『5シーズン以上のテレビ番組を数えなさい』）

SELECT COUNT(*)
FROM youtube
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;

--17.Count the number of content items in each genre
（日本語訳：『ジャンルごとにコンテンツの数を数えなさい』）

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(show_id) as total_content
FROM youtube
GROUP BY 1

--18.Find each year and the average numbers of content release by India on
	youtube. return top 5 year with highest avg content release
（日本語訳：『それぞれの年にYoutubeインドでリリースされたコンテンツの数の平均を見つけなさい。その平均の
	中で最も高いものを５つ求めなさい』）

	
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY'))as year,	
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*)FROM youtube WHERE country='India')::numeric*100
	,2)as avg_content_per_year
FROM youtube
WHERE country='India'
GROUP BY 1

--19.List all movies that are documentaries
（日本語訳：『ドキュメンタリーの映画すべてを一覧にしなさい』）
SELECT *
FROM youtube
WHERE type = 'Movie'
  AND listed_in ILIKE '%Documentary%';

--20.Find all content without a director
（日本語訳：『監督のいないコンテンツを全て見つけなさい』）

SELECT * FROM youtube
WHERE director is NULL

--21.Find how many movies actor 'Salman Khan' appeared in last 10 years
（日本語訳：『ここ10年間で映画俳優'Salman Khan'はどれだけ出演しましたか』）
	
SELECT * 
FROM youtube
WHERE casts ILIKE '%Salman Khan%'
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
  AND type = 'Movie';

--22.Find the top 10 actors who have appeared in the highest number of movies producted
	in India
（日本語訳：『インド映画に最も多く出演した10人の俳優を見つけなさい』）

		
SELECT
	UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
	COUNT(*) as total_content
FROM youtube
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--23.Categorize the content based on the presence of the keywords 'kill' and 'violence'
in the description field. Label content containing these keywords as 'Bad' and all other
content as 'Good'. Count how many items fall into each category.
（日本語訳：『'kill'や'violent'というキーワードのコンテンツには'Bad'、それ以外には'Good'評価をして、
		それぞれのカテゴリーの数を数えなさい』）

		
WITH new_table AS (
  SELECT *,
    CASE
      WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
      ELSE 'Good'
    END AS category
  FROM youtube
)

SELECT
  category,
  COUNT(*) AS total_content
FROM new_table
GROUP BY category;









