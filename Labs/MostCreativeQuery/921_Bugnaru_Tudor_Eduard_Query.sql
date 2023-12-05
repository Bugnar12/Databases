--Because Florin Talpes released a very efficient new antivirus version,
--all opposition that use an antivirus on Linux OS owned by him will go up one position in the charts
SELECT O1.oppositon_name, O1.position_in_antivirus_chart
FROM Opposition O1
SELECT O.oppositon_name, O.position_in_antivirus_chart - 1 AS updated_antivirus_chart_position
FROM Opposition O
WHERE EXISTS(
	SELECT A.opposition_id
	FROM Antivirus_soft A inner join Works_on W ON A.antivirus_id = W.antivirus_id
		INNER JOIN Operating_system O1 ON O1.os_id = w.[os_i d]
	WHERE A.manager = 'Florin Talpes' AND O.opposition_id = A.opposition_id AND O1.os_name = 'Linux')
