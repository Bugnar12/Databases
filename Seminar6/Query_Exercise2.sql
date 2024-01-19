CREATE TABLE TrainTypes(
	train_type_id INT PRIMARY KEY,
	train_type_name VARCHAR(200),
	train_type_description VARCHAR(MAX)
)

CREATE TABLE Trains(
	train_id INT PRIMARY KEY,
	train_name VARCHAR(200),
	train_type INT FOREIGN KEY REFERENCES TrainTypes(train_type_id)
)
CREATE TABLE Stations(
	station_id INT PRIMARY KEY,
	station_name VARCHAR(200) UNIQUE
)

CREATE TABLE Routes(
	route_id INT PRIMARY KEY,
	route_name VARCHAR(200) UNIQUE,
	train_id INT FOREIGN KEY REFERENCES Trains(train_id)
)

CREATE TABLE RoutesStations(
	station_id INT FOREIGN KEY REFERENCES Stations(station_id),
	route_id INT FOREIGN KEY REFERENCES Routes(route_id),
	PRIMARY KEY(station_id, route_id),
	departation_time TIME,
	arrival_time TIME
)
-- Insert into TrainTypes
INSERT INTO TrainTypes (train_type_id, train_type_name, train_type_description)
VALUES
(1, 'Express', 'High-speed express trains'),
(2, 'Local', 'Local commuter trains'),
(3, 'Cargo', 'Freight trains');

-- Insert into Trains
INSERT INTO Trains (train_id, train_name, train_type)
VALUES
(101, 'Express Train A', 1),
(102, 'Local Train B', 2),
(103, 'Cargo Train C', 3);

-- Insert into Stations
INSERT INTO Stations (station_id, station_name)
VALUES
(501, 'Station X'),
(502, 'Station Y'),
(503, 'Station Z');

-- Insert into Routes
INSERT INTO Routes (route_id, route_name, train_id)
VALUES
(1001, 'Route 1', 101),
(1002, 'Route 2', 102),
(1003, 'Route 3', 103);

-- Insert into RoutesStations
INSERT INTO RoutesStations (station_id, route_id, departation_time, arrival_time)
VALUES
(501, 1001, '08:00:00', '09:30:00'),
(502, 1001, '10:00:00', '12:00:00'),
(503, 1001, '13:00:00', '15:00:00'),

(501, 1002, '07:30:00', '08:45:00'),
(502, 1002, '09:15:00', '10:30:00'),
(503, 1002, '11:00:00', '12:15:00'),

(501, 1003, '14:30:00', '16:00:00'),
(502, 1003, '17:00:00', '19:00:00'),
(503, 1003, '20:00:00', '22:00:00');

GO
CREATE OR ALTER PROCEDURE USP_Add_or_Update_RouteStation (@rName VARCHAR(200), @sName VARCHAR(200), @arrival TIME, @departure TIME)
AS
BEGIN
	DECLARE @rid INT = (SELECT route_id FROM Routes R WHERE R.route_name = @rName)
	DECLARE @sid INT = (SELECT station_id FROM Stations S WHERE S.station_name = @sName)

	IF(EXISTS ( SELECT * FROM RoutesStations RS WHERE RS.route_id = @rid AND RS.station_id = @sid))
		UPDATE RoutesStations SET arrival_time=@arrival, departation_time = @departure WHERE route_id = @rid AND station_id = @sid
	ELSE
		INSERT INTO RoutesStations VALUES(@sid, @rid, @departure, @arrival)
END
GO

EXEC USP_Add_or_Update_RouteStation 'Route4', 'Station4', '10:00am', '12:00am'

GO
CREATE OR ALTER VIEW AllRoutes
AS
	SELECT route_name
	FROM Routes
	WHERE route_id IN
		(SELECT route_id
		FROM RoutesStations
		GROUP BY route_id
		HAVING COUNT(*) = (SELECT COUNT(*) FROM Stations))
GO

SELECT * FROM AllRoutes

GO
CREATE OR ALTER FUNCTION NamesOfStations (@R INT)
	RETURNS TABLE AS RETURN
	BEGIN
		SELECT station_name
		FROM Stations
		WHERE station_id IN
		(SELECT station_id
		FROM RoutesStations
		GROUP BY station_id
		HAVING COUNT(*) > @R)
	END
go

