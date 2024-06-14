-- DATA CLEANING
SELECT * FROM world_life_expectancy.world_life_expectancy;


-- check for duplicate entries 
-- will need to use country and year since each row has a unique row number
SELECT country, year, concat(country, year), count(concat(country, year))
FROM world_life_expectancy.world_life_expectancy
group by country, year, concat(country, year)
HAVING count(concat(country, year)) > 1;

-- Identify row ids for 3 duplicates that were found above
SELECT * FROM
(SELECT row_id, concat(country, year), row_number() OVER(Partition by concat(country, year) ORDER BY row_id) row_num
FROM world_life_expectancy.world_life_expectancy) as row_num_table
WHERE row_num > 1;
-- row ids to delete are 1252, 2265, 2929

-- delete duplicates based on row id found above
DELETE FROM world_life_expectancy.world_life_expectancy
WHERE row_id IN (
	SELECT row_id FROM
	(SELECT row_id, concat(country, year), row_number() OVER(Partition by concat(country, year) ORDER BY row_id) row_num
	FROM world_life_expectancy.world_life_expectancy) as row_num_table
	WHERE row_num > 1
)
;
-- re run query above and you should not see any output because duplicates have been removed

SELECT * FROM world_life_expectancy.world_life_expectancy;

-- fill in any status that is empty
SELECT country, status
FROM world_life_expectancy.world_life_expectancy
WHERE status = "";

-- update each instance by country where status has no value
SELECT country, status
FROM world_life_expectancy.world_life_expectancy
WHERE country = 'Afghanistan';

UPDATE world_life_expectancy.world_life_expectancy
SET
status = "Developing"
WHERE country = 'Afghanistan';

SELECT country, status
FROM world_life_expectancy.world_life_expectancy
WHERE country = 'Albania';

UPDATE world_life_expectancy.world_life_expectancy
SET
status = "Developing"
WHERE country = 'Albania';

SELECT country, status
FROM world_life_expectancy.world_life_expectancy
WHERE country = 'Georgia';

UPDATE world_life_expectancy.world_life_expectancy
SET
status = "Developing"
WHERE country = 'Georgia';

SELECT country, status
FROM world_life_expectancy.world_life_expectancy
WHERE country = 'United States of America';

UPDATE world_life_expectancy.world_life_expectancy
SET
status = "Developed"
WHERE country = 'United States of America';

SELECT country, status
FROM world_life_expectancy.world_life_expectancy
WHERE country = 'Vanuatu';

UPDATE world_life_expectancy.world_life_expectancy
SET
status = "Developing"
WHERE country = 'Vanuatu';

SELECT country, status
FROM world_life_expectancy.world_life_expectancy
WHERE country = 'Zambia';

UPDATE world_life_expectancy.world_life_expectancy
SET
status = "Developing"
WHERE country = 'Zambia';

-- verify that all rows have a year value / there is no blank values
-- since number of years ins't that large, can return distinct year values and review manually
SELECT DISTINCT(year)
FROM world_life_expectancy.world_life_expectancy;
-- or can add row numbers to each distinct year and check if there are any values greater than 1
SELECT * FROM (SELECT year, row_number() OVER (partition by year) row_num
FROM world_life_expectancy.world_life_expectancy
group by year) row_num_table
WHERE row_num > 1;

-- Updating blank values in life expectancy column 
-- looks like life expectancy is slowy increasing every year, for blank values use prior year and next year to find the avg
-- use avg for the blank values

SELECT * FROM 
world_life_expectancy.world_life_expectancy
WHERE `life expectancy` = '';
-- blank values are in afghanistan and albania

-- find the average to use to fill in the blank values using lead and lag
SELECT country, year, `life expectancy`, ROUND((lead(`life expectancy`,1) OVER() + lag(`life expectancy`,1) OVER())/2,2) avg_exp
FROM world_life_expectancy.world_life_expectancy;

-- use above average calculation to fill in the missing values using an update statement
WITH avg_lag AS
(SELECT row_id, country, year, `life expectancy`, ROUND((lead(`life expectancy`,1) OVER() + lag(`life expectancy`,1) OVER())/2,2) avg_exp
FROM world_life_expectancy.world_life_expectancy)

UPDATE world_life_expectancy.world_life_expectancy wl
JOIN avg_lag al
ON wl.row_id = al.row_id
SET wl.`life expectancy` = al.avg_exp
WHERE wl.`life expectancy` = '' ;

SELECT *
FROM world_life_expectancy.world_life_expectancy;









-- EXPLORATORY DATA ANALYSIS, find insights and trends in the data

-- find out the min and max life expectancy by country to see who has changed the most
SELECT country, min(`life expectancy`), max(`life expectancy`), round((max(`life expectancy`)-min(`life expectancy`)),1) agechange
FROM world_life_expectancy.world_life_expectancy
GROUP BY country
HAVING min(`life expectancy`) <> 0 AND max(`life expectancy`) <> 0
ORDER BY agechange DESC;

-- look at the average life expectancy for each year
SELECT year, round(avg(`life expectancy`),1) avglifespan
FROM world_life_expectancy.world_life_expectancy
WHERE `life expectancy` <> 0
GROUP BY year
ORDER BY year;
-- average lifespan for all years and all countries is about 68

-- review if there is a correlation between GDP and life expectancy
SELECT country, ROUND(avg(`life expectancy`),1) AvgLifespan, ROUND(AVG(GDP),1) AvgGDP
FROM world_life_expectancy.world_life_expectancy
GROUP BY country
HAVING AvgLifespan > 0 AND AvgGDP > 0
order by avggdp asc;
-- looking through the data it seems like countries with lower GDP also have a lower than avg lifespan
-- drill down further to group lifespan and gdp into low/high buckets and filter based on those groups

-- look at countries who have low lifespan and low GDP
-- most of the avg GDPs are way below the midline of 1500 when corresponding to a low avg lifespan
-- this matches what I would expect
-- the average lifespan for low GDP countries has a 21 year gap, i think this shows that countries with low GDP vary drastically in their healthcare systems and availbility of resouces
SELECT country, 
ROUND(avg(`life expectancy`),1) AvgLifespan, 
CASE
	WHEN avg(`life expectancy`) < 68 THEN 'Low' ELSE 'High'
END LifespanRank, 
ROUND(AVG(GDP),1) AvgGDP, 
CASE
	WHEN avg(GDP) < 1500 THEN 'Low' ELSE 'High'
END GDPRank
FROM world_life_expectancy.world_life_expectancy
GROUP BY country
HAVING LifespanRank = 'Low' AND GDPRank = 'Low' AND avg(`life expectancy`) > 0 AND avg(GDP) > 0
order by avg(`life expectancy`) asc
;

-- now review the inverse for countries who have high lifespan and high GDP
-- GDP for this group is significantly higher than the midline which is as expected
-- avg lifespan vaires from right at the midline and goes up to 82 which is a 14 year difference
SELECT country, 
ROUND(avg(`life expectancy`),1) AvgLifespan, 
CASE
	WHEN avg(`life expectancy`) < 68 THEN 'Low' ELSE 'High'
END LifespanRank, 
ROUND(AVG(GDP),1) AvgGDP, 
CASE
	WHEN avg(GDP) < 1500 THEN 'Low' ELSE 'High'
END GDPRank
FROM world_life_expectancy.world_life_expectancy
GROUP BY country
HAVING LifespanRank = 'high' AND GDPRank = 'high' AND avg(`life expectancy`) > 0 AND avg(GDP) > 0
order by avg(`life expectancy`) asc;

-- find the average infant death and under-five death rate by country during the data period
SELECT country, status, avg(`infant deaths`), avg(`under-five deaths`)
FROM world_life_expectancy.world_life_expectancy
GROUP BY country
ORDER BY avg(`infant deaths`) DESC;


-- find percent of countries with no infant deaths
-- 28% of the countries reported zero infant deaths during the data period
SELECT (count(`infant deaths`)/(SELECT count(*) FROM world_life_expectancy.world_life_expectancy))*100 `% countries with zero infant deaths`
FROM world_life_expectancy.world_life_expectancy
WHERE `infant deaths` = 0;

-- find percent of countries with no under-five deaths
-- 26% of the countries reported zero infant deaths during the data period
-- comparing this to above shows that there are more infant deaths worldwide than deaths of children under 5, so children have a higher chance of living once they make it past infancy
SELECT (count(`under-five deaths`)/(SELECT count(*) FROM world_life_expectancy.world_life_expectancy))*100 `% cuntries with zero under 5 deaths`
FROM world_life_expectancy.world_life_expectancy
WHERE `under-five deaths` = 0;

-- what is the average life expectancy by country
SELECT country, round(avg(`life expectancy`),2), avg(`life expectancy`)
FROM world_life_expectancy.world_life_expectancy
GROUP BY country
ORDER BY avg(`life expectancy`) desc;


-- how many countryies have an avg life expectancy greater than 80 years
-- 24 countries out of the 193 included in the data set have an avg life exp greater than 80 years

SELECT count(distinct(country))
FROM world_life_expectancy.world_life_expectancy;

WITH avglife AS
(SELECT country, avg(`life expectancy`) avglifeexp FROM world_life_expectancy.world_life_expectancy GROUP BY country)

SELECT * FROM avglife
WHERE avglifeexp > 80
ORDER BY avglifeexp DESC;

-- did any countries change from developing to developed during the data collection period
-- this query returns nothing which tells me that all countries kept the same status during the data collection time period
SELECT wl1.country, wl1.year, wl1.status, wl2.country, wl2.year, wl2.status
FROM world_life_expectancy.world_life_expectancy wl1
JOIN world_life_expectancy.world_life_expectancy wl2
ON wl1.country = wl2.country AND wl1.year = wl2.year
WHERE wl1.status = 'Developing' AND wl2.status = 'Developed'
order by wl1.country, wl1.year
;

-- find the average life expectancy for all countries depending on their status	
-- there is a 13 year gap between the average lifespans in developing v developed countries

SELECT status, ROUND(avg(`life expectancy`),1)
FROM world_life_expectancy.world_life_expectancy
GROUP BY status
ORDER BY `life expectancy` DESC;

-- add count of countries in each category for the above query to determine if the averages are a good reflection of the pool of countries
-- there are a lot less developed countries in the data set, so assuming their average reported lifespan is higher (as seen above) then the average lifespan is going to be skew on the high side comapred to the deveoping countries which have lower lifespans in general and a much larger spread in avg lifespans
SELECT status, count(distinct(country)) `countries by status`, ROUND(avg(`life expectancy`),1) `average lifespan`
FROM world_life_expectancy.world_life_expectancy
GROUP BY status
ORDER BY `life expectancy` DESC;

-- review data to evaluate correlation between avg bmi and avg lifespan
-- assuming BMI ranges are the same in all countries the data isn't what I would expect. This is showing that severely obese BMI ratings are falling into the higher avg lifespan range. There is no direct and obvious correlation that I'm seeing, but underwight BMIs seem to fall into the lower end of the lifespan range and obese fall into the higher range of lifespan
SELECT country, ROUND(avg(`life expectancy`),1) AvgLifespan, ROUND(AVG(BMI),1) AvgBMI, CASE
WHEN AVG(BMI) < 18.5 THEN 'Underweight'
WHEN AVG(BMI) >= 18.5 AND AVG(BMI) <= 24.9 THEN 'Healthy'
WHEN AVG(BMI) >= 25 AND AVG(BMI) <= 29.9 THEN 'Overweight'
WHEN AVG(BMI) >= 30 AND AVG(BMI) < 40 THEN 'Obesity'
WHEN AVG(BMI) >= 40 THEN 'Severe Obesity'
END BMI
FROM world_life_expectancy.world_life_expectancy
GROUP BY country
HAVING AvgLifespan > 0 AND AvgBMI > 0
order by AvgBMI DESC;


-- Compare lifespan to the mortality rate and add the rolling total for each country
SELECT country, year, `life expectancy`, `adult mortality`,
sum(`adult mortality`) OVER (PARTITION BY country ORDER BY year) RollingTotal
FROM world_life_expectancy.world_life_expectancy;

-- look at united states specifically
SELECT country, year, `life expectancy`, `adult mortality`,
sum(`adult mortality`) OVER (PARTITION BY country ORDER BY year) RollingTotal
FROM world_life_expectancy.world_life_expectancy
WHERE country LIKE 'United S%';



