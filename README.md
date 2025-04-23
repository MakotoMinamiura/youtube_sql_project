# Youtube Movies and TV Shows Data Analysis using SQL
『SQLを用いたYoutube映画・テレビ番組のデータ分析』

![YouTube Banner](https://upload.wikimedia.org/wikipedia/commons/b/b8/YouTube_Logo_2017.svg)

---

## 📖 Overview  
This project involves a comprehensive analysis of YouTube-style movie and TV show data using SQL.  
The goal is to extract insights and solve real-world business problems by using SQL techniques such as aggregation, window functions, date processing, string manipulation, and conditional logic.  

本プロジェクトは、YouTube風のデータを使ってSQLによる実践的なビジネス課題の分析を行うものです。集計・文字列処理・日付処理・条件分岐・ウィンドウ関数などのSQL技術を活用しています。

---

## 🎯 Objectives  
- Analyze distribution of Movies vs TV Shows  
- Identify most frequent ratings  
- Explore trends by country, year, genre, duration  
- Filter by directors, actors, keywords  
- Categorize content based on violent keywords  

- 映画とテレビ番組の比率を分析  
- 最も多く使われるレーティングを特定  
- 国・年・ジャンル・上映時間別の傾向を分析  
- 監督・俳優・キーワードによるフィルタリング  
- 暴力的キーワードの有無による作品分類

---

## 🗂️ Dataset  
The dataset is a mock version of Netflix-format data customized for YouTube-style content.  
データセットはNetflix形式を参考にした、YouTube風の架空データです。

---

## 🔧 Technologies Used  
- PostgreSQL  
- SQL functions: `UNNEST`, `STRING_TO_ARRAY`, `SPLIT_PART`, `TO_DATE`, `CASE`, `RANK()`  
- DBeaver (interface)

---

## 📖 Business Problems and SQL Solutions / ビジネス問題とSQL解決

# 🎥 YouTube Movies and TV Shows Data Analysis with SQL

This project presents a comprehensive SQL-based analysis of YouTube-style content data (similar to Netflix), aiming to address real-world business questions and improve data handling skills. Each SQL query is accompanied by a clear business problem statement and Japanese translation.

---

## 📖 Business Problems and SQL Solutions / ビジネス問題とSQL解決

### 1. Count the number of Movies and TV Shows
**JP:** 映画とテレビ番組の数をそれぞれ数えなさい
```sql
SELECT type, COUNT(*) AS total_content
FROM youtube
GROUP BY type;
```

### 2. Count the number of nations
**JP:** 国の数を数えなさい
```sql
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
```

### 3. Find the most common rating for movies and TV shows
**JP:** 映画とテレビ番組の中で最も多い評価を見つけなさい
```sql
SELECT 
    type,
    rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*),
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM youtube
    GROUP BY type, rating
) AS sub
WHERE ranking = 1;
```

### 4. Find the top 3 ratings for movies and TV shows
**JP:** 映画とテレビ番組の中で最も多い評価のトップ3を見つけなさい
```sql
SELECT 
    type,
    rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*),
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM youtube
    GROUP BY type, rating
) AS sub
WHERE ranking <= 3
ORDER BY type, rating;
```

### 5. List all movies released in 2020
**JP:** 2020年にリリースされた映画をすべて一覧にしなさい
```sql
SELECT * FROM youtube
WHERE type = 'Movie' AND release_year = 2020;
```

### 6. List all TV Shows released in 2021
**JP:** 2021年にリリースされたテレビ番組をすべて一覧にしなさい
```sql
SELECT * FROM youtube
WHERE type = 'TV Show' AND release_year = 2021;
```

### 7. Top 5 countries with most content
**JP:** YouTubeで最も多くのコンテンツを提供している国トップ5を見つけなさい
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
    COUNT(show_id) AS total_content
FROM youtube
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

### 8. Top 5 countries with least content
**JP:** YouTubeで最も少ないコンテンツを提供している国トップ5を見つけなさい
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
    COUNT(show_id) AS total_content
FROM youtube
GROUP BY 1
ORDER BY 2 ASC
LIMIT 5;
```

### 9. Identify the longest movie
**JP:** 最も長い映画を特定しなさい
```sql
SELECT * FROM youtube
WHERE type = 'Movie'
  AND duration LIKE '%min'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) = (
    SELECT MAX(CAST(SPLIT_PART(duration, ' ', 1) AS INT))
    FROM youtube
    WHERE type = 'Movie' AND duration LIKE '%min'
);
```

### 10. Identify the second longest movie
**JP:** 二番目に長い映画を特定しなさい
```sql
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
```

### 11. Identify the longest movies based on the national name
**JP:** 国別に最長の映画を特定しなさい
```sql
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
```

### 12. Find content added in the last 5 years
**JP:** ここ5年間で追加されたコンテンツを見つけなさい
```sql
SELECT * 
FROM youtube
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

### 13. Find content added in the first 3 years
**JP:** 最初の3年間で追加されたコンテンツを見つけなさい
```sql
SELECT *
FROM youtube
WHERE TO_DATE(date_added, 'Month DD, YYYY') BETWEEN
  (SELECT MIN(TO_DATE(date_added, 'Month DD, YYYY')) FROM youtube)
  AND
  (SELECT MIN(TO_DATE(date_added, 'Month DD, YYYY')) FROM youtube) + INTERVAL '3 years';
```

### 14. Find all the movies/TV shows by director 'Rajiv Chilaka'
**日本語訳:** 'Rajiv Chilaka'監督の映画およびテレビ番組をすべて見つけなさい
```sql
SELECT * FROM youtube
WHERE director ILIKE '%Rajiv Chilaka%';
```

### 15. List all TV shows with more than 5 seasons
**日本語訳:** 5シーズン以上のテレビ番組を一覧にしなさい
```sql
SELECT *
FROM youtube
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;
```

### 16. Count all TV shows with more than 5 seasons
**日本語訳:** 5シーズン以上のテレビ番組を数えなさい
```sql
SELECT COUNT(*)
FROM youtube
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INT) > 5;
```

### 17. Count the number of content items in each genre
**日本語訳:** ジャンルごとにコンテンツの数を数えなさい
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM youtube
GROUP BY 1;
```

### 18. Average number of content releases by India each year (Top 5)
**日本語訳:** インドが毎年リリースするコンテンツの平均数を年ごとに集計し、平均が高い上位5年を表示しなさい
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        COUNT(*)::numeric / 
        (SELECT COUNT(*) FROM youtube WHERE country = 'India')::numeric * 100, 2
    ) AS avg_content_per_year
FROM youtube
WHERE country = 'India'
GROUP BY 1
ORDER BY avg_content_per_year DESC
LIMIT 5;
```

### 19. List all movies that are documentaries
**日本語訳:** ドキュメンタリーの映画をすべて一覧にしなさい
```sql
SELECT *
FROM youtube
WHERE type = 'Movie'
  AND listed_in ILIKE '%Documentary%';
```

### 20. Find all content without a director
**日本語訳:** 監督のいないコンテンツをすべて見つけなさい
```sql
SELECT * FROM youtube
WHERE director IS NULL;
```

### 21. Count movies featuring 'Salman Khan' in the last 10 years
**日本語訳:** 過去10年間に映画俳優'Salman Khan'が出演した映画の数を求めなさい
```sql
SELECT *
FROM youtube
WHERE casts ILIKE '%Salman Khan%'
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
  AND type = 'Movie';
```

### 22. Top 10 actors in Indian movies
**日本語訳:** インドで制作された映画に最も多く出演している俳優トップ10を見つけなさい
```sql
SELECT
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
    COUNT(*) AS total_content
FROM youtube
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY total_content DESC
LIMIT 10;
```

### 23. Categorize content as 'Good' or 'Bad' based on keywords
**日本語訳:** 'kill'や'violence'という単語の有無に応じて、コンテンツを'Good'または'Bad'に分類し、それぞれの数を数えなさい
```sql
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
```




