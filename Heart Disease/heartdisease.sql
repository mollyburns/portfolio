SELECT * FROM heartdisease.heart_statlog;
-- dupliacet table so edits aren't made to original data

CREATE TABLE heartdisease.heart_statlog_work
LIKE heartdisease.heart_statlog;

INSERT heartdisease.heart_statlog_work
SELECT * FROM heartdisease.heart_statlog;

SELECT * FROM heartdisease.heart_statlog_work;

-- change sex to 'male' or 'female'

-- create new column with data type varchar
ALTER TABLE heartdisease.heart_statlog_work
ADD COLUMN gender varchar(50)
AFTER sex;

-- add data for gender
-- updating to case statements to simplify work
-- UPDATE heartdisease.heart_statlog_work
-- SET gender = 'female'
-- WHERE sex = 0;

-- UPDATE heartdisease.heart_statlog_work
-- SET gender = 'male'
-- WHERE sex = 1;

UPDATE heartdisease.heart_statlog_work
SET heartdisease.heart_statlog_work.gender =
(CASE
WHEN sex = 0 THEN 'female'
WHEN sex = 1 THEN 'male'
END);

-- delete sex column
ALTER TABLE heartdisease.heart_statlog_work
DROP COLUMN sex;

-- add column for chest pain type with description
ALTER TABLE heartdisease.heart_statlog_work
ADD COLUMN chest_pain_type varchar(50)
AFTER `chest pain type`;

-- add data

UPDATE heartdisease.heart_statlog_work
SET heartdisease.heart_statlog_work.chest_pain_type =
(CASE
WHEN `chest pain type` = 1 THEN 'typical angina'
WHEN `chest pain type` = 2 THEN 'atypical angina'
WHEN `chest pain type` = 3 THEN 'non-anginal pain'
WHEN `chest pain type` = 4 THEN 'asymptomatic'
END);
/*
UPDATE heartdisease.heart_statlog_work
SET chest_pain_type = 'typical angina'
WHERE `chest pain type` = 1;

UPDATE heartdisease.heart_statlog_work
SET chest_pain_type = 'atypical angina'
WHERE `chest pain type` = 2;

UPDATE heartdisease.heart_statlog_work
SET chest_pain_type = 'non-anginal pain'
WHERE `chest pain type` = 3;

UPDATE heartdisease.heart_statlog_work
SET chest_pain_type = 'asymptomatic'
WHERE `chest pain type` = 4;
*/
-- delete original column
ALTER TABLE heartdisease.heart_statlog_work
DROP COLUMN `chest pain type`;


-- update fasting blood sugar column to varchar
ALTER TABLE heartdisease.heart_statlog_work
ADD COLUMN fasting_blood_sugar varchar(50)
AFTER `fasting blood sugar`;

SELECT * FROM heartdisease.heart_statlog_work;
-- add data
UPDATE heartdisease.heart_statlog_work
SET fasting_blood_sugar =
(CASE
WHEN `fasting blood sugar` = 0 THEN 'Less Than 120 mg/dl'
WHEN `fasting blood sugar` = 1 THEN 'Greater Than 120 mg/dl'
END);

/*
UPDATE heartdisease.heart_statlog_work
SET fasting_blood_sugar = 'Less Than 120 mg/dl'
WHERE `fasting blood sugar` = 0;

UPDATE heartdisease.heart_statlog_work
SET fasting_blood_sugar = 'Greater Than 120 mg/dl'
WHERE `fasting blood sugar` = 1;
*/
SELECT * FROM heartdisease.heart_statlog_work;

-- delete original column
ALTER TABLE heartdisease.heart_statlog_work
DROP COLUMN `fasting blood sugar`;


-- update resting ecg column
ALTER TABLE heartdisease.heart_statlog_work
ADD COLUMN resting_ecg varchar(50)
AFTER `resting ecg`;

-- add data
UPDATE heartdisease.heart_statlog_work
SET resting_ecg = 
(CASE
WHEN `resting ecg` = 0 THEN 'normal'
WHEN `resting ecg` = 1 THEN 'ST-T wave abnormality'
WHEN `resting ecg` = 2 THEN 'left ventricular hypertrophy'
END);

/*
UPDATE heartdisease.heart_statlog_work
SET resting_ecg = 'normal'
WHERE `resting ecg` = 0;

UPDATE heartdisease.heart_statlog_work
SET resting_ecg = 'ST-T wave abnormality'
WHERE `resting ecg` = 1;

UPDATE heartdisease.heart_statlog_work
SET resting_ecg = 'left ventricular hypertrophy'
WHERE `resting ecg` = 2;
*/
SELECT * FROM heartdisease.heart_statlog_work;

-- delete original column
ALTER TABLE heartdisease.heart_statlog_work
DROP COLUMN `resting ecg`;

-- update exercise angina column
ALTER TABLE heartdisease.heart_statlog_work
ADD COLUMN exercise_induced_angina varchar(50)
AFTER `exercise angina`;

-- add data
UPDATE heartdisease.heart_statlog_work
SET exercise_induced_angina = 
(CASE
WHEN `exercise angina` = 0 THEN 'no'
WHEN `exercise angina` = 1 THEN 'yes'
END);

/*
UPDATE heartdisease.heart_statlog_work
SET exercise_induced_angina = 'no'
WHERE `exercise angina` = 0;

UPDATE heartdisease.heart_statlog_work
SET exercise_induced_angina = 'yes'
WHERE `exercise angina` = 1;
*/
SELECT * FROM heartdisease.heart_statlog_work;

-- delete original column
ALTER TABLE heartdisease.heart_statlog_work
DROP COLUMN `exercise angina`;

-- delete oldpeak column, there is no data in documentation so I don't know what this column is referring to
ALTER TABLE heartdisease.heart_statlog_work
DROP COLUMN `oldpeak`;

-- update class column
ALTER TABLE heartdisease.heart_statlog_work
ADD COLUMN `status` varchar(50)
AFTER `target`;

-- add data
UPDATE heartdisease.heart_statlog_work
SET `status` = 
(CASE
WHEN `target` = 0 THEN 'normal'
WHEN `target` = 1 THEN 'heart disease'
END);

/*
UPDATE heartdisease.heart_statlog_work
SET `status` = 'normal'
WHERE `target` = 0;

UPDATE heartdisease.heart_statlog_work
SET `status` = 'heart disease'
WHERE `target` = 1;
*/
SELECT * FROM heartdisease.heart_statlog_work;

-- delete original column
ALTER TABLE heartdisease.heart_statlog_work
DROP COLUMN `target`;

-- update st slope column 
ALTER TABLE heartdisease.heart_statlog_work
ADD COLUMN exercise_slope varchar(50)
AFTER `ST slope`;

-- documentation doesn't have a value for 0, check how many zeros are in the table
SELECT DISTINCT `st slope`, COUNT(`st slope`) FROM heartdisease.heart_statlog_work
GROUP BY `st slope`;
-- only one 0 is returned, will ignore for now and not update the 0 values

-- add data
UPDATE heartdisease.heart_statlog_work
SET exercise_slope =
(CASE
WHEN `ST slope` = 1 THEN 'upsloping'
WHEN `ST slope` = 2 THEN 'flat'
WHEN `ST slope` = 3 THEN 'downsloping'
END);

SELECT * FROM heartdisease.heart_statlog_work;

-- delete original column
ALTER TABLE heartdisease.heart_statlog_work
DROP COLUMN `ST slope`;

-- there was one slope value that was zero, check that rows data
SELECT * FROM heartdisease.heart_statlog_work
WHERE exercise_slope IS NULL;

-- update above value to none, since there is data in every other column
UPDATE heartdisease.heart_statlog_work
SET exercise_slope = 'none'
WHERE exercise_slope IS NULL;

SELECT * FROM heartdisease.heart_statlog_work
WHERE exercise_slope ='none';

-- check for duplicates by adding the row number 
SELECT * FROM (SELECT *, 
ROW_NUMBER() OVER (PARTITION BY age, gender, chest_pain_type, `resting bp s`, fasting_blood_sugar, resting_ecg, exercise_induced_angina, exercise_slope, `status`) row_num
FROM heartdisease.heart_statlog_work) subquery
WHERE row_num > 1
ORDER BY row_num desc;

-- verify count of how many duplicates are returned
WITH duplicates_check AS 
(
SELECT * FROM (SELECT *, 
ROW_NUMBER() OVER (PARTITION BY age, gender, chest_pain_type, `resting bp s`, fasting_blood_sugar, resting_ecg, exercise_induced_angina, exercise_slope, `status`) row_num
FROM heartdisease.heart_statlog_work) subquery
WHERE row_num > 1
)
SELECT COUNT(row_num) FROM duplicates_check;
-- 299 duplicates returned
-- delete duplicates, any row with row_num greater than 1
-- create new table with a column for row number
CREATE TABLE `heart_statlog_work2` (
  `age` int DEFAULT NULL,
  `gender` varchar(50) DEFAULT NULL,
  `chest_pain_type` varchar(50) DEFAULT NULL,
  `resting bp s` int DEFAULT NULL,
  `cholesterol` int DEFAULT NULL,
  `fasting_blood_sugar` varchar(50) DEFAULT NULL,
  `resting_ecg` varchar(50) DEFAULT NULL,
  `max heart rate` int DEFAULT NULL,
  `exercise_induced_angina` varchar(50) DEFAULT NULL,
  `exercise_slope` varchar(50) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM heart_statlog_work2;
-- insert data including row number into new table

INSERT INTO heart_statlog_work2
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY age, gender, chest_pain_type, `resting bp s`, fasting_blood_sugar, resting_ecg, exercise_induced_angina, exercise_slope, `status`) row_num
FROM heartdisease.heart_statlog_work;
-- verify how many rows there are
SELECT COUNT(age) FROM heart_statlog_work2; -- 1190

-- delete data with duplicate row numbers
DELETE FROM heart_statlog_work2
WHERE row_num > 1;
-- verify count again to see how many rows were removed
SELECT COUNT(age) FROM heart_statlog_work2; -- 891

-- drop column with row number we don't need that data any more
ALTER TABLE heart_statlog_work2 DROP COLUMN `row_num`;

SELECT * FROM heart_statlog_work2;

-- check for null values
SELECT * FROM heartdisease.heart_statlog_work
WHERE `status` is null;

-- went thru each column, don't see any null values
-- remove any uncessary rows/columns
-- did this during the initial cleanup phase

SELECT * FROM heartdisease.heart_statlog_work;




