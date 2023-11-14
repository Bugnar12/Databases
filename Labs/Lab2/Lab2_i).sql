--i)
--ALL and ANY queries

--print all the locations that appear more than one time - using ALL 
SELECT * FROM Locations
SELECT DISTINCT L2.location_country
FROM Locations L2
WHERE L2.location_country > ALL(
	SELECT L.location_country
	FROM Locations L
	GROUP BY L.location_country 
	HAVING COUNT(location_country) = 1)

--rewritten with IN
SELECT DISTINCT L2.location_country
FROM Locations L2
WHERE L2.location_country IN (
    SELECT L.location_country
    FROM Locations L
    GROUP BY L.location_country
    HAVING COUNT(L.location_country) > 1
);


--select any customer that has at least 2 digits in the password ~ security purposes
--USING ANY
SELECT * FROM Customer
SELECT C.customer_name
FROM Customer C
WHERE C.customer_id = ANY
	(SELECT C1.customer_id
	 FROM Customer C1
	 WHERE PATINDEX('%[0-9]%[0-9]%', C1.passwd) > 0)

--Rewritten using NOT IN
SELECT * FROM Customer
SELECT C.customer_name
FROM Customer C
WHERE C.customer_id NOT IN
	(SELECT C1.customer_id
	 FROM Customer C1
	 WHERE C1.passwd IS NULL OR (PATINDEX('%[0-9]%[0-9]%', C1.passwd) = 0))

--Select only those employees which are not also cutomers using <> ALL
SELECT E.employee_name
FROM Employee E
WHERE E.employee_name <> ALL(
	SELECT C.customer_name
	FROM Customer C)

--Rewritten using COUNT
SELECT E.employee_name
FROM Employee E
LEFT JOIN Customer C ON E.employee_name = C.customer_name
GROUP BY E.employee_name
HAVING COUNT(*) = 1;

--The employees that have the salary more than double the production cost and taxes should get a salary decrease
--using ANY
SELECT E.employee_name, E.salary - 200 as New_Salary
FROM Employee E
WHERE E.employee_id = ANY(
	SELECT C.employee_id
	FROM Cost C
	WHERE (C.production_costs+C.taxes) * 3 < E.salary)

--Rewritten using SUM and INNER JOIN
SELECT E.employee_name, E.salary - 200 AS New_Salary
FROM Employee E
INNER JOIN (
    SELECT C.employee_id, SUM(C.production_costs + C.taxes) AS total_costs
    FROM Cost C
    GROUP BY C.employee_id
) AS Subquery
ON E.employee_id = Subquery.employee_id
WHERE Subquery.total_costs * 3 < E.salary;





