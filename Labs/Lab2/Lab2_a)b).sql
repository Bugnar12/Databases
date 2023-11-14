--a)UNION + OR

--UNION
--Union all the headquarters of the antivirus and operating system that we are working with(just once) - multiple times using UNION ALL
SELECT * FROM Antivirus_soft
SELECT * FROM Operating_system
SELECT headquarters FROM Antivirus_soft
UNION 
SELECT headquarters FROM Operating_system --check the headquarters of the operating systems and the antiviruses companies used by our company

--OR : select operating systems which are Linux OR have a XNU kernel
SELECT O.os_id, O.os_name, O.kernel_type
FROM Operating_system O
WHERE O.os_name = 'Linux' OR O.kernel_type = 'XNU kernel'


--b)INTERSECT + IN

--Intersect to see those customers which are also employees (INTERSECT)
SELECT * FROM Employee
SELECT * FROM Customer
SELECT customer_name AS CustomerAndEmployee
FROM Customer
INTERSECT
SELECT E.employee_name
FROM Employee E


--Print the locations which have at least one departament assignated
SELECT * FROM Departament
SELECT * FROM Location_of_Departaments
SELECT * FROM Locations
SELECT L.location_id, L.location_city
FROM Locations L
WHERE L.location_id
IN
	(SELECT L2.location_id
	 FROM Location_of_Departaments L2)
-- Arithmetic expression in SELECT '+'
-- ORDER BY descending
-- TOP

-- RANDOM QUERY
-- Select the customers which has spent the most money inside the company on the month March
SELECT * FROM Cost

SELECT TOP 2 production_costs, taxes, taxes + production_costs AS total
FROM Cost
WHERE month_count = 'March'
