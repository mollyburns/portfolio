SELECT * FROM capstone.capstone;
SELECT distinct `left` FROM capstone.capstone;

CREATE TABLE `capstone2` (
  `satisfaction_level` double DEFAULT NULL,
  `last_evaluation` double DEFAULT NULL,
  `number_project` int DEFAULT NULL,
  `average_montly_hours` int DEFAULT NULL,
  `time_spend_company` int DEFAULT NULL,
  `Work_accident` int DEFAULT NULL,
  `left` int DEFAULT NULL,
  `promotion_last_5years` int DEFAULT NULL,
  `Department` text,
  `salary` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM capstone.capstone2;
INSERT INTO capstone.capstone2
SELECT * FROM capstone.capstone;


SELECT * FROM capstone.capstone2;

-- remove duplicates
WITH CTE_capstone AS
(SELECT *, dense_rank() OVER (PARTITION BY time_spend_company, department, salary) row_num
FROM capstone.capstone2)

SELECT *
FROM CTE_capstone
HAVING row_num > 1;

-- no duplicates are returned, data is good to use as-is

-- verify that department and salary don't have any duplicate values, or see if any descriptions can be combined
SELECT distinct department
FROM capstone.capstone2
ORDER BY department asc;

SELECT distinct salary
FROM capstone.capstone2;

SELECT `left`, count(`left`) FROM capstone.capstone2
GROUP BY `left`;

ALTER TABLE capstone.capstone2
ADD COLUMN `Status` VARCHAR(50) AFTER `left`;

UPDATE capstone.capstone2
SET `Status` = 'quit' 
WHERE `left` = 1;

UPDATE capstone.capstone2
SET `Status` = 'current' 
WHERE `left` = 0;

ALTER TABLE capstone.capstone2
DROP COLUMN `left`;

SELECT status, count(Status) FROM capstone.capstone2;



