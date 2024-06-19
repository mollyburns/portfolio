
SELECT * FROM capstone.capstone2;

SELECT department, status, count(department) FROM capstone.capstone2
GROUP BY department, status
ORDER BY department;

-- count how many poeple have been with the company 
SELECT time_spend_company, count(time_spend_company) employee_count
FROM capstone.capstone2
GROUP BY time_spend_company
ORDER BY time_spend_company;
-- the company has grown a lot in the last few years
-- do employees who have worked with the company longer work more hours?
SELECT time_spend_company, count(time_spend_company) employee_count, avg(average_montly_hours/4) avg_hours_worked_per_wk
FROM capstone.capstone2
GROUP BY time_spend_company
ORDER BY time_spend_company;
-- there isn't a difinitive difference in hours worked and years with the company, avg hours worked per week is above 40 hours for all tenures
-- employees who have been working at the company for 4-6 years work the most hours on average
-- these people are probably working harder trying to get looked at for promotions 
-- look at average rating from last review cycle > employees who have worked 4-6 years have the highest ratings
SELECT time_spend_company, count(time_spend_company) employee_count, avg(average_montly_hours/4) avg_hours_worked_per_wk, avg(last_evaluation) ReviewRating, avg(number_project) NumofProjects
FROM capstone.capstone2
GROUP BY time_spend_company
ORDER BY ReviewRating DESC;

-- investigate how many hours are worked per week on average by department
SELECT department, (average_montly_hours/4) avg_weekly_hours
FROM capstone.capstone2
GROUP BY department
ORDER BY avg_weekly_hours DESC;
-- IT, R&D, techical and management depts work significantly more than other departments in the company
-- consider adding more headcount to these departments  

-- do number of projects correlate to hours worked?
SELECT department, avg(number_project), (average_montly_hours/4) avg_weekly_hours
FROM capstone.capstone2
GROUP BY department
ORDER BY avg_weekly_hours DESC;
-- there is a similar number of projects worked on by each dept
-- projects in the busier depts take longer to complete

-- how does the satisfaction level relate to salary
SELECT salary, round(avg(satisfaction_level),2)
FROM capstone.capstone2
GROUP BY salary;

-- what is the breakdown of salary level by employee
SELECT salary, count(salary)
FROM capstone.capstone2
GROUP BY salary;
-- most employees are in the low salary category, the least amount of employees have a high salary

-- what is the breakdown of employee count by salary level
-- comparing salary levels by number of employees and years working at company
SELECT time_spend_company, salary, count(salary) EmployeeCount, count(salary)/(SELECT COUNT(*) FROM capstone.capstone2)*100 `%ofTotal`
FROM capstone.capstone2
GROUP BY time_spend_company, salary
ORDER BY time_spend_company, salary;

SELECT time_spend_company, salary, count(salary) EmployeeCount, count(salary)/(SELECT COUNT(*) FROM capstone.capstone2)*100 `%ofTotal`
FROM capstone.capstone2
WHERE salary = 'low'
GROUP BY time_spend_company, salary
ORDER BY time_spend_company, salary;
-- the longer an employee has been at the company, the less are in the low salary category

SELECT time_spend_company, salary, count(salary) EmployeeCount, count(salary)/(SELECT COUNT(*) FROM capstone.capstone2)*100 `%ofTotal`
FROM capstone.capstone2
WHERE salary = 'medium'
GROUP BY time_spend_company, salary
ORDER BY time_spend_company, salary;

SELECT time_spend_company, salary, count(salary) EmployeeCount, count(salary)/(SELECT COUNT(*) FROM capstone.capstone2)*100 `%ofTotal`
FROM capstone.capstone2
WHERE salary = 'high'
GROUP BY time_spend_company, salary
ORDER BY time_spend_company, salary;

-- employees who have been at the company for 3 years make up the largest percent of total among all salary categories
-- could be a sign that after two years a lot of employees get a raise HOWEVER the largets group is people
-- who have worked for 3 years and are in the low salary category
-- looking at above queries this analysis is reflected - people who work 4-6 years have the highest average hours per week worked
-- have the highest review rating and have the highest number of projects, so poeple in the 3 year bucket are looking at moving to a new role and working more

-- if goal is to reduce expenses and cut roles, recommendation would be to weed out employees who have worked at the company less than 4 years
-- the company has seen a lot of grown in the last 2-3 years, and the people who have worked at the company 4-6 years make up the largest group in the company
-- this group is working the most and the most eligible for promotions and raises. Before the 2-3 year group gets more established, work on retaining the star employees
-- and moving them into higher prodcution roles

