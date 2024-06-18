-- DATA CLEANING


SELECT * FROM USIncome.usincome;
SELECT * FROM USIncome.usincome_stats;

-- check for duplicates
SELECT id, COUNT(id)
FROM USIncome.usincome
GROUP BY id
HAVING COUNT(id) > 1;
-- no duplicate ids are showing up so there is nothing to delete from income table

SELECT id
FROM USIncome.usincome_stats;

-- id column returned in * output, but not returned when searching 'id' - shows up in schema tree, but not in object info
-- delete current table, create new table, then import data to include the id column
CREATE TABLE usincome_stats (
  id int,
  State_Name text,
  Mean int,
  Median int,
  Stdev int,
  sum_w double
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT id
FROM usincome.usincome_stats;

-- check to see if there are any duplicates in the stats table
SELECT id, COUNT(id)
FROM USIncome.usincome_stats
GROUP BY id
HAVING COUNT(id) > 1;


-- check if there are any states names that need to be updated (can see an instance where state starts with lowercase letter)
SELECT distinct(state_name)
FROM USIncome.usincome;

SELECT distinct(state_code), state_name
FROM USIncome.usincome;

-- I noticed that there are two entries for Georgia, but there is a spelling error, update where state name is spelled wrong
UPDATE USIncome.usincome
SET state_name = 'Georgia'
WHERE state_name = 'georia';

-- update states names so all start with capital letters
SELECT CONCAT(UCASE(LEFT(state_name,1)),LCASE(substring(state_name,2)))
FROM USIncome.usincome;

UPDATE USIncome.usincome
SET state_name = CONCAT(UCASE(LEFT(state_name,1)),LCASE(substring(state_name,2)));

-- verify if it looks like any couties or state abreviations need to be udpated
SELECT distinct(county)
FROM USIncome.usincome
order by county ASC;

SELECT distinct(state_ab)
FROM USIncome.usincome;


-- I noticed that a field in the Place column is empty, check if there are others
SELECT *
FROM USIncome.usincome
WHERE Place = '';
-- there is only one instance where Place has no value, look at other similar couty/city and see if you can fill it in
SELECT county, city, place
FROM USIncome.usincome
WHERE county = 'Autauga County';
-- all places in Autauga County are marked with Autaugaville, so update empty filed to match
UPDATE USIncome.usincome
SET place = 'Autaugaville'
WHERE place = '';
-- verify update is reflected
SELECT * 
FROM USIncome.usincome
WHERE city = 'vinemont';

-- review type and place for duplicates or errors
SELECT type, count(type)
FROM USIncome.usincome
GROUP BY type;

SELECT `primary`, count(`primary`)
FROM USIncome.usincome
GROUP BY `primary`;

-- verify if allen county and allen parish should be the same 
-- Allen Parish is in LA, Allen County is in KS, these should be as they are
SELECT * 
FROM USIncome.usincome
WHERE county = 'Allen Parish' OR county = 'Allen County';

SELECT distinct(place)
FROM USIncome.usincome;

-- At a glance I noticed that there are 0 values for AWater, verify if there are rows with no value for aland and awater
SELECT ALand, AWater
FROM USIncome.usincome
WHERE awater = 0 OR awater = '' OR awater IS NULL;
-- there are quite a few where there is no water, now check if there are any with 0 values for both land and water
SELECT ALand, AWater
FROM USIncome.usincome
WHERE (awater = 0 OR awater = '' OR awater IS NULL)
AND (aland = 0 OR aland = '' OR aland IS NULL);
-- Nothing is returned from above so there aren't any rows with 0 for aland and awater, no need to worry about deleting any of that data






-- DATA EXPLORATION

SELECT * FROM USIncome.usincome;
SELECT * FROM USIncome.usincome_stats;

-- confirm how many states are included in data set, only 31 are included
SELECT count(distinct(State_name))
FROM  usincome.usincome;

-- 315 instances where there is no data recorded in the stats table
SELECT COUNT(*)
FROM USIncome.usincome_stats
WHERE mean = 0;

-- look at the area of land and water by state/county/city 
SELECT state_name, county, city, sum(aland), sum(awater)
FROM usincome.usincome
GROUP BY city;

-- look at states with the most land
SELECT state_name, sum(aland), sum(awater)
FROM usincome.usincome
GROUP BY state_name
ORDER BY 2 desc;

-- look at top 10 states with the most land
SELECT state_name, sum(aland) totalland, sum(awater)totalwater, row_number() over(ORDER BY sum(aland) DESC) Ranking
FROM usincome.usincome
GROUP BY state_name
ORDER BY 2 desc
LIMIT 10;

-- look at states with the most water
SELECT state_name, sum(aland), sum(awater)
FROM usincome.usincome
GROUP BY state_name
ORDER BY 3 desc;

-- look at top 10 states with the most water 
SELECT state_name, sum(aland) totalland, sum(awater)totalwater, row_number() over(ORDER BY sum(awater) DESC) Ranking
FROM usincome.usincome
GROUP BY state_name
ORDER BY 3 desc
LIMIT 10;


-- Join both tables 
SELECT * 
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
WHERE MEAN <> 0;

-- determind average icomes based on state, city and couty

-- find the five states with lowest avg household income
SELECT state_name, ROUND(avg(mean),2) AvgMeanIncome, ROUND(avg(median),2) AvgMedianIncome
FROM usincome.usincome_stats
WHERE MEAN <> 0
GROUP BY state_name
ORDER BY 2
LIMIT 5;

-- find the five states with highest avg household income
SELECT state_name, ROUND(avg(mean),2) AvgMeanIncome, ROUND(avg(median),2) AvgMedianIncome
FROM usincome.usincome_stats
WHERE MEAN <> 0
GROUP BY state_name
ORDER BY 2 DESC
LIMIT 5;
-- find the 10 states with highest avg household income
SELECT state_name, ROUND(avg(mean),2) AvgMeanIncome, ROUND(avg(median),2) AvgMedianIncome
FROM usincome.usincome_stats
WHERE MEAN <> 0
GROUP BY state_name
ORDER BY 2 DESC
LIMIT 10;

-- find the 5 states with highest median household income
SELECT state_name, ROUND(avg(mean),2) AvgMeanIncome, ROUND(avg(median),2) AvgMedianIncome
FROM usincome.usincome_stats
WHERE MEAN <> 0
GROUP BY state_name
ORDER BY 3 DESC
LIMIT 5;
-- median incomes shown above are quite a bit higher than the mean

-- find the 5 states with lowest median household income
SELECT state_name, ROUND(avg(mean),2) AvgMeanIncome, ROUND(avg(median),2) AvgMedianIncome
FROM usincome.usincome_stats
WHERE MEAN <> 0
GROUP BY state_name
ORDER BY 3
LIMIT 5;
-- in this group, the median is pretty close to the mean incomes



-- look at the highest mean incomes by city
SELECT s.state_name, i.city, ROUND(avg(s.mean),2) AvgMeanIncome
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
WHERE MEAN <> 0
GROUP BY i.city
ORDER BY avg(s.mean) DESC;

-- look at the highest median incomes by city
SELECT s.state_name, i.city, ROUND(avg(s.median),2) AvgMedianIncome
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
WHERE MEAN <> 0
GROUP BY i.city
ORDER BY avg(s.median) DESC;
-- 300000 is reported a lot, so not sure if that is a data error or if that is true, seems odd to have exact median of 300000 reported so many times

-- look at the lowest incomes by city
SELECT s.state_name, i.city, ROUND(avg(s.mean),2) AvgMeanIncome, ROUND(avg(s.median),2) AvgMedianIncome
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
WHERE MEAN <> 0
GROUP BY i.city
HAVING avg(s.mean) <> 0
ORDER BY avg(s.mean) ASC;

-- look at how many cities are under the federal poverty line of $25,926 for a two-adult, two-child family unit (we don't know cencus details so we will assume the income is for a household of 4
-- based on the query below there are 44 cities that reported a mean income less than the federal poverty line, and there are 5002 total cities that par part of the data set 
SELECT count(*) povertycount
FROM (SELECT s.state_name, i.city, ROUND(avg(s.mean),2) AvgMeanIncome, ROUND(avg(s.median),2) AvgMedianIncome
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
GROUP BY i.city
HAVING avg(s.mean) < 25926 AND avg(s.mean) > 0) avgincomes;

SELECT COUNT(DISTINCT(i.city))
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
WHERE i.city IS NOT NULL
;


-- list of cities that fall below the federal povery line
SELECT s.state_name, i.city, ROUND(avg(s.mean),2) AvgMeanIncome, ROUND(avg(s.median),2) AvgMedianIncome
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
GROUP BY i.city
HAVING avg(s.mean) < 25926 AND avg(s.mean) > 0
ORDER BY avg(s.mean) ASC;


-- avg mean and median incomes broken out by county and state
SELECT s.state_name, i.county, ROUND(avg(s.mean),2) AvgMeanIncome, ROUND(avg(s.median),2) AvgMedianIncome
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
GROUP BY i.county
ORDER BY avg(s.mean) DESC;


-- look at number of types for each state
SELECT state_name, type, count(type) CountOfType
FROM usincome.usincome
GROUP BY state_name, type
WITH ROLLUP;

-- look at types with avg mean and median details
SELECT i.type, count(i.type) CountOfType, AVG(s.mean), AVG(s.median)
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
WHERE mean <> 0 AND type IS NOT NULL
GROUP BY i.type
ORDER BY 3 DESC;

SELECT i.type, count(i.type) CountOfType, AVG(s.mean), AVG(s.median)
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
WHERE mean <> 0 AND type IS NOT NULL
GROUP BY i.type
ORDER BY 4 DESC;

-- use above query but filter out types that have a count of less than 100, will remove the outliers and give more substantiated output
SELECT type, count(type) CountOfType, AVG(s.mean), AVG(s.median)
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
WHERE mean <> 0 AND type IS NOT NULL
GROUP BY type
HAVING count(type) > 100
ORDER BY 3 DESC;

-- review above query with mean & median information
SELECT i.state_name, i.type, count(i.type) CountOfType, ROUND(avg(s.mean),2) AvgMeanIncome, ROUND(avg(s.median),2) AvgMedianIncome
FROM usincome.usincome_stats s
LEFT JOIN usincome.usincome i
ON s.id = i.id
GROUP BY i.state_name, i.type
WITH ROLLUP
;

-- determine what the high and low ranges for income are using median and stdev by state
SELECT *, mean-stdev low, mean+stdev high 
FROM USIncome.usincome_stats
GROUP BY state_name;
-- this shows that some counties have negative income according to this data

