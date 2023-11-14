--g)
-- 2 queries with a subquery in the FROM clause

--show antiviruses + version that work on operating systems with a hybrid kernel type
--subquery in FROM and WHERE clauses
SELECT * FROM Antivirus_soft
SELECT * FROM Operating_system
SELECT * FROM Works_on
SELECT antivirus_name, antivirus_version
FROM Antivirus_soft A
WHERE A.antivirus_id IN
(
	SELECT a.antivirus_id
	FROM(
		SELECT W.antivirus_id
		FROM Works_on W INNER JOIN Operating_system O ON W.os_id = O.os_id
		WHERE O.kernel_type = 'hybrid'
	)a
)

--find the top 2 opposition which use at least one antivirus as our company and are top 5 in all companies
--using DISTINCT (because otherwise a company would be selected for every antivirus)
--using TOP and ORDER BY to see them ordered
SELECT * FROM Opposition
SELECT * FROM Antivirus_soft

SELECT DISTINCT TOP 2 o.oppositon_name, o.position_in_antivirus_chart
FROM
(
	SELECT O.oppositon_name, O.position_in_antivirus_chart
	FROM Opposition O INNER JOIN Antivirus_soft A ON A.opposition_id = O.opposition_id
	WHERE O.position_in_antivirus_chart < 5
)o
ORDER BY position_in_antivirus_chart

--h) GROUP BY

--group employees by gender using count
SELECT E.gender, COUNT(*) AS gender_count
FROM Employee E
GROUP BY E.gender

--GROUP BY with simple HAVING
--The operating systems that support only 64-bits and not below
SELECT O.os_name, COUNT(O.os_name) AS count_os
FROM Operating_system O
GROUP BY O.os_name
HAVING MIN(O.bits) = 64

--GROUP BY with subquery in select
--lowest no. of workers from a departament
SELECT D.departament_name, D.nr_of_workers
FROM Departament D
GROUP BY D.departament_name, D.nr_of_workers
HAVING D.nr_of_workers = 
				(SELECT MIN(A.nr_of_workers) FROM
					(SELECT D.nr_of_workers FROM Departament D) A);

--Select the antiviruses id and name for which their count is higher than the count of an OS(id=3) that works on antiviruses
--Purpose : seeing performant antiviruses
--Using GROUP BY and subquery in HAVING

SELECT A.antivirus_id, A.antivirus_name, COUNT(*) AS count_of_antivirus
FROM Antivirus_soft A INNER JOIN Works_on W ON A.antivirus_id = W.antivirus_id
GROUP BY A.antivirus_id, A.antivirus_name
HAVING count(*) >
		(SELECT COUNT(*)
		FROM Works_on W1
		WHERE W1.os_id = 3)
