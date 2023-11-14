--e)
--Queries with IN operator in subquery

--1 subquery
--gets the employees name that work in a departament with low importance or few workers ~ low level employees
--OR used in the condition
SELECT employee_name as low_priority_employee, salary
FROM Employee
WHERE departament_id IN(
	SELECT departament_id
	FROM Departament
	WHERE importance = 'low' OR nr_of_workers < 15)

--2 subqueries in WHERE clause
--gets the customers that use an antivirus which work on the operating system with id NOT 1
--NOT in the where clause
SELECT * FROM Customer
SELECT * FROM Antivirus_soft
SELECT * FROM Works_on
SELECT customer_name
FROM Customer
WHERE antivirus_id IN(
	SELECT antivirus_id
	FROM Antivirus_soft
	WHERE antivirus_id IN(
		SELECT antivirus_id
		FROM Works_on
		WHERE NOT os_id = 1)
		)

--f)EXISTS operator
--Find 3 customers who have subscribed to antivirus software with a specific opposition ID(=1)
--which have the shortest password (for cracking purposes)
SELECT TOP 3 C.customer_id, C.customer_name, len(C.passwd)
FROM Customer C
WHERE EXISTS (
    SELECT A.antivirus_id
    FROM Antivirus_soft A
    WHERE A.antivirus_id = C.antivirus_id
    AND A.opposition_id = 1 AND C.passwd IS NOT NULL
)
ORDER BY len(C.passwd) ASC

SELECT * FROM Departament
select * from Location_of_Departaments
select * from Locations

--Because Florin Talpes implemented a very efficient new antivirus version,
--all opposition that use an antivirus owned by him will go up one position in the charts
--ARITHMETIC operation "-" in SELECT
SELECT O1.oppositon_name, O1.position_in_antivirus_chart
FROM Opposition O1
SELECT O.oppositon_name, O.position_in_antivirus_chart - 1 AS antivirus_chart
FROM Opposition O
WHERE EXISTS(
	SELECT A.opposition_id
	FROM Antivirus_soft A
	WHERE A.manager = 'Florin Talpes' AND O.opposition_id = A.opposition_id)
