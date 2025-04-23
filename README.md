# Youtube Movies and TV Shows Data Analysis using SQL
(日本語訳：『SQLを用いたYoutube映画・テレビ番組のデータ分析』)

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

## 💡 Sample Business Questions & SQL Solutions

### 1. Count the number of Movies and TV Shows  
映画とテレビ番組の数を数える  
```sql
SELECT type, COUNT(*) AS total_content
FROM youtube
GROUP BY type;


