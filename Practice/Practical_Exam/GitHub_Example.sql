create table R(
	RID int PRIMARY KEY,
	A1 VARCHAR(MAX),
	K2 int UNIQUE,
	A2 INT,
	A3 INT,
	A4 INT,
	A5 VARCHAR(2),
	A6 INT)


-- Insert data with reversed order of the third and second fields
INSERT INTO R (RID, A1, K2, A2, A3, A4, A5, A6) VALUES
(2, 'Punctu-acela de miscare', 100, 1, 3, 3, 'M1', 22),
(3, 'E stapanul fara margini peste marginile lumii...', 200, 1, 3, 3, 'M1', 22),
(4, 'De-atunci negura eterna se desface in fasii', 150, 2, 3, 4, 'M1', 23),
(5, 'De atunci rasare lumea, luna, soare si stihii...', 700, 2, 4, 4, 'M2', 29),
(6, 'De atunci si pana astazi colonii de lumi pierdute', 300, 3, 4, 5, 'M2', 29),
(7, 'Vin din sure vai de chaos pe carari necunoscute', 350, 3, 4, 5, 'M5', 23),
(8, 'Si in roiuri luminoase izvorand din infinit', 400, 3, 5, 7, 'M5', 29),
(9, 'Sunt atrase in viata de un dor nemarginit', 500, 4, 5, 7, 'M2', 30),
(10, 'Iar in lumea asta mare, noi copii ai lumii mici', 450, 4, 5, 7, 'M7', 30),
(11, 'Facem pe pamantul nostru musunoaie de furnici;', 250, 4, 6, 7, 'M7', 30),
(12, 'Microscopice popoare, regi, osteni si invatati', 800, 5, 6, 7, 'M6', 22),
(13, 'Ne succedem generatii si ne credem minunati;', 750, 5, 6, 7, 'M6', 23);


SELECT r1.RID, r1.K2, COUNT(*) NoRows
FROM R r1 inner join R r2 on r1.A2 = r2.A3
inner join R r3 ON r2.A3 = r3.A4
WHERE r1.A1 LIKE '_%'
group by r1.RID, r1.K2
HAVING count(*) >= 6

SELECT r1.A6, MAX(r1.A2) MaxA2
FROM R r1
WHERE r1.A5 IN ('M1', 'M2')
GROUP BY r1.A6
EXCEPT
SELECT DISTINCT r2.A6, r2.A2
FROM R r2

GO
CREATE OR ALTER FUNCTION ufF1(@A5 CHAR(2))
RETURNS INT
BEGIN
RETURN
 (SELECT COUNT(*)
 FROM R
 WHERE A5 = @A5)
END
go



go
CREATE OR ALTER TRIGGER TrOnInsert
 ON R
 FOR INSERT
AS
 INSERT InsertLog(A5Value, NumRows, DateTimeOp)
 SELECT i.A5, dbo.ufF1(i.A5), GETDATE()
 FROM inserted i
GO

INSERT R(RID, K2, A5) VALUES
 (14, 14, 'M1'), (15, 15, 'M1'), (16, 16, 'M2')
INSERT R(RID, K2, A5) VALUES
 (17, 17, 'M1'), (18, 18, 'M3')

 INSERT R(RID, K2, A5) VALUES (19, 19, 'M1')

 SELECT * FROM R

 SELECT * FROM InsertLog











--1.Relational Database with Drones, PizzaShops and Customers

create table DroneManufacturer(
	droneManufacturerID int primary key,
	name VARCHAR(MAX)
)

create table DroneModels(
	droneModelID INT PRIMARY KEY,
	droneManufacturerID INT FOREIGN KEY REFERENCES DroneManufacturer(droneManufacturerID) not null,
	name VARCHAR(MAX),
	battery_life INT,
	maximum_speed INT
)

create table Drones(
	droneID INT PRIMARY KEY,
	droneModelsID INT FOREIGN KEY REFERENCES DroneModels(droneModelID) not null,
	serial_number INT
)

create table PizzaShop(
	pizzaShopID INT PRIMARY KEY,
	name_1 VARCHAR(50) UNIQUE,
	address VARCHAR(MAX)
)

create table Customer(
	customerID INT PRIMARY KEY,
	name_2 VARCHAR(50) UNIQUE,
	loyalty_score INT
)

create table Deliveries(
	pizzaShopID INT FOREIGN key references PizzaShop(pizzaShopID),
	customerID INT FOREIGN key references Customer(customerID),
	droneID int foreign key references Drones(droneID),
	date_ date,
	time_ time,
	primary key(pizzaShopID, customerID, droneID, date_, time_)
)

-- Insert data into DroneManufacturer table
INSERT INTO DroneManufacturer (droneManufacturerID, name)
VALUES
(1, 'DJI'),
(2, 'Parrot'),
(3, 'Yuneec');

-- Insert data into DroneModels table
INSERT INTO DroneModels (droneModelID, droneManufacturerID, name, battery_life, maximum_speed)
VALUES
(1, 1, 'Mavic Air 2', 34, 68),
(2, 2, 'Anafi', 25, 55),
(3, 3, 'Typhoon H Pro', 25, 43);

-- Insert data into Drones table
INSERT INTO Drones (droneID, droneModelsID, serial_number)
VALUES
(101, 1, 12345),
(102, 2, 67890),
(103, 3, 54321);

-- Insert data into PizzaShop table
INSERT INTO PizzaShop (pizzaShopID, name_1, address)
VALUES
(1, 'Pizza Express', '123 Main St, Cityville'),
(2, 'Mamma Mia Pizzeria', '456 Oak St, Townsville'),
(3, 'Cheesy Delight', '789 Maple St, Villageton');

-- Insert data into Customer table
INSERT INTO Customer (customerID, name_2, loyalty_score)
VALUES
(201, 'John Doe', 5),
(202, 'Jane Smith', 8),
(203, 'Bob Johnson', 3);

-- Insert data into Deliveries table
INSERT INTO Deliveries (pizzaShopID, customerID, droneID, date_, time_)
VALUES
(1, 201, 101, '2023-01-01', '12:00:00'),
(2, 202, 102, '2023-01-02', '13:30:00'),
(3, 203, 103, '2023-01-03', '15:00:00');

--2.Implement a stored procedure that receives a customer, a pizza shop, a drone, a date and time and adds the
--corresponding delivery to the database.

GO
CREATE OR ALTER PROCEDURE procedure1(@pid INT, @cid INT, @did INT, @date date, @time time)
AS
BEGIN
	--first do NOT FORGET TO RAISE ERRORS FOR INVALID DATA
	if not exists(SELECT * FROM PizzaShop P WHERE P.pizzaShopID = @pid)
		BEGIN
			RAISERROR('Invalid PizzaShop!', 16, 1)
		END
	if not exists(SELECT * FROM Customer C where C.customerID = @cid)
		BEGIN
			RAISERROR('Invalid Customer!', 16, 1)
		END
	if not exists(SELECT * FROM Drones D WHERE D.droneID = @did)
		BEGIN
			RAISERROR('Invalid Drone!', 16, 1)
		END
	
	--If the Delivery already exists => UPDATE
	--If the Delivery does NOT exist => INSERT

	IF EXISTS(select * from Deliveries D WHERE D.pizzaShopID = @pid AND D.customerID = @cid AND D.droneID = @did)
		UPDATE Deliveries
		SET date_ = @date, time_ = @time 
		WHERE pizzaShopID = @pid AND customerID = @cid AND droneID = @did
	
	ELSE
		INSERT INTO Deliveries VALUES(@pid, @cid, @did, @date, @time)

END
GO

SELECT * FROM PizzaShop
select * from Customer
EXEC procedure1 1, 201, 101, '11.11.2021', '13:15' 
SELECT * FROM Deliveries

--3.Create a view that shows the names of the startup’s favorite drone manufacturers, i.e., those with the largest
--number of drones used by the startup.

GO
CREATE OR ALTER VIEW view1
AS
	SELECT DF.name
	FROM DroneManufacturer DF inner join DroneModels DM ON DF.droneManufacturerID = DM.droneManufacturerID
		inner join Drones D ON D.droneModelsID = DM.droneModelID
		group by DF.name
	HAVING COUNT(*) >= ALL (SELECT count(*) as noOfDrones
							FROM DroneManufacturer DF2 inner join DroneModels DM2 ON DF2.droneManufacturerID = DM2.droneManufacturerID
								INNER JOIN Drones D2 ON D2.droneModelsID = DM2.droneModelID
								GROUP BY DF2.name)

GO

--4.Implement a function that lists the names of the customers who received at least D deliveries, where D is a
--function parameter.

create or alter function function1(@nrCustomer INT)
RETURNS TABLE
AS
RETURN
	SELECT C.name_2, --count(C.name_2) as noClients
	FROM Customer C INNER JOIN Deliveries D on D.customerID = C.customerID
	group by C.name_2
	HAVING COUNT(C.name_2) >= @nrCustomer
GO

select * from function1(2)