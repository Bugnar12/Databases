--c)Query with EXCEPT and NOT IN

--using EXCEPT
--Select those employees for which the position in company is NOT low - use EXCEPT
SELECT * FROM Departament
SELECT D.departament_name
FROM Departament AS D
EXCEPT
SELECT D.departament_name
FROM Departament AS D
WHERE importance = 'low'

--NOT IN
--Find the employees that do not work for the departament with ID 2
SELECT E.employee_name
FROM Employee AS E
WHERE E.departament_id NOT IN(
	SELECT D.departament_id
	FROM Departament AS D
	WHERE departament_id = 2)

--d)Query with JOIN

--Left join to see employees and their departaments even though one might not have a departament
SELECT E.employee_name, E.position_in_company, D.departament_name
FROM Employee E
			LEFT JOIN Departament D ON E.departament_id = D.departament_id 

--Inner join to see all customers and their antivirus(if any) and which OS(if any) supports them
--DISTINCT usage 1
SELECT DISTINCT C.customer_name, A.antivirus_name, O.os_name as supported_os
FROM Customer C INNER JOIN Antivirus_soft A ON C.antivirus_id = A.antivirus_id
				INNER JOIN Works_on W ON A.antivirus_id = W.antivirus_id
				INNER JOIN Operating_system O ON W.os_id = O.os_id

--Right join to see all the opposition and (if exists) the antivirus that our company also uses
--ORDER BY the profit
SELECT O.oppositon_name, O.oppositon_profit, A.antivirus_name
FROM Antivirus_soft A RIGHT JOIN Opposition O ON A.opposition_id = O.opposition_id
ORDER BY O.oppositon_profit DESC

--FULL join with 2 separate many-to-many relationships
--See all the headquarters of both OS and antivirus, as well as the locations of the departaments
--Purpose : opening new departments close to headquarters
--Distinct 2
SELECT DISTINCT A.headquarters, O.headquarters, L.location_city, D.departament_name
FROM Antivirus_soft A FULL JOIN Operating_system O ON A.headquarters = O.headquarters
	FULL JOIN Locations L ON L.location_city = A.headquarters
		FULL JOIN Location_of_Departaments L2 ON L.location_id = L2.location_id
			FULL JOIN Departament D ON L2.departament_id = D.departament_id