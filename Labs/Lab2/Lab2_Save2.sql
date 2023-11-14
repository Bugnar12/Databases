use Labs

DROP TABLE Customer
DROP TABLE Works_on
DROP TABLE Operating_system
DROP TABLE Antivirus_soft
DROP TABLE Cost
DROP TABLE Employee
DROP TABLE Associations
DROP TABLE Departament
DROP TABLE Opposition
DROP TABLE Fiscal_value



CREATE TABLE Opposition
(
	opposition_id INT PRIMARY KEY,
	oppositon_name VARCHAR(30),
	position_in_antivirus_chart INT,
	oppositon_profit INT,
	opposition_nr_of_members INT
)

CREATE TABLE Antivirus_soft
(
	antivirus_id INT PRIMARY KEY,
	opposition_id INT FOREIGN KEY REFERENCES Opposition(opposition_id),
	antivirus_name VARCHAR(20),
	antivirus_version VARCHAR(20),
	manager VARCHAR(50),
	headquarters VARCHAR(50),
)

CREATE TABLE Operating_system
(
	os_id INT PRIMARY KEY,
	os_name VARCHAR(20),
	os_version VARCHAR(20),
	release_date DATE,
	kernel_type VARCHAR(40),
	bits INT CHECK(bits in(32, 64)),
	headquarters VARCHAR(50)
)

CREATE TABLE Works_on
(
	antivirus_id INT FOREIGN KEY REFERENCES Antivirus_soft(antivirus_id),
	os_id INT FOREIGN KEY REFERENCES Operating_system(os_id)
)

CREATE TABLE Departament
(
	departament_id INT PRIMARY KEY,
	departament_name VARCHAR(20),
	nr_of_workers INT,
	allocated_budget INT,
	importance VARCHAR(15) check (importance in('low', 'medium', 'high'))
)

CREATE TABLE Employee
(
	employee_id INT PRIMARY KEY,
	departament_id INT FOREIGN KEY REFERENCES Departament(departament_id),
	employee_name VARCHAR(30),
	salary INT,
	gender VARCHAR(10) CHECK (gender in('male', 'female')),
	position_in_company VARCHAR(30)
)

CREATE TABLE Customer
(
	customer_id INT PRIMARY KEY,
	customer_name VARCHAR(30),
	antivirus_id INT FOREIGN KEY REFERENCES Antivirus_soft(antivirus_id),
	username VARCHAR(50),
	passwd VARCHAR(50),
	subscription_paid BIT
)

CREATE TABLE Associations
(
	association_id INT PRIMARY KEY,
	departament_id INT FOREIGN KEY REFERENCES Departament(departament_id),
	association_name VARCHAR(40), 
	number_of_emplyees INT
)

CREATE TABLE Cost
(
	cost_id INT PRIMARY KEY,
	month_count VARCHAR(15) CHECK (month_count in ('January', 'February', 'March', 'April', 'May', 'June', 'July',
													'August', 'September', 'October', 'November', 'December')),
	employee_id INT FOREIGN KEY REFERENCES Employee(employee_id),
	taxes INT,
	production_costs INT
)

CREATE TABLE Locations --plural because Location is integrated in SQL
(
	location_id INT PRIMARY KEY,
	location_country VARCHAR(30),
	location_city VARCHAR(40),
	street VARCHAR(50)
)

CREATE TABLE Location_of_Departaments
(
	location_id INT FOREIGN KEY REFERENCES Locations(location_id),
	departament_id INT FOREIGN KEY REFERENCES Departament(departament_id)
)

--Opposition insertion
INSERT INTO Opposition(opposition_id, oppositon_name, position_in_antivirus_chart, oppositon_profit, opposition_nr_of_members)
VALUES(1, 'ProVirus SRL', 4, 50000, 200)
INSERT INTO Opposition
VALUES(2, 'BestVirus Company', 5, 45000, 240)
INSERT INTO Opposition
VALUES(3, 'Viralex SC', 8, 38000, 100)
INSERT INTO Opposition
VALUES(4, 'ToyVirus SRL', 3, 65000, 250)

-- Antivirus insertion
INSERT INTO Antivirus_soft(antivirus_id, opposition_id, antivirus_name, antivirus_version, manager, headquarters) 
VALUES (1, 1, 'Bitdefender', '12.4', 'Florin Talpes', 'Bucharest')	
INSERT INTO Antivirus_soft(antivirus_id, opposition_id, antivirus_name, antivirus_version, manager, headquarters) 
VALUES (2, 1, 'Norton', '10.6', 'Robert Hentschel', 'Arizona')
INSERT INTO Antivirus_soft(antivirus_id, opposition_id, antivirus_name, antivirus_version, manager, headquarters) 
VALUES (3, 3, 'McAfee', '6.1', 'Greg Johnson', 'California')
INSERT INTO Antivirus_soft
VALUES(4, 3, 'Bitdefender', '11,9', 'Florin Talpes', 'Cluj')
INSERT INTO Antivirus_soft
VALUES(5, 4, 'Avast', '5.1', 'Ondřej Vlček', 'Prague')


-- Departament insertion

INSERT INTO [Departament]([departament_id],[departament_name],[nr_of_workers],[allocated_budget],[importance])
VALUES(1,'ManualTesting',20,4000,'medium')
INSERT INTO Departament(departament_id, departament_name, nr_of_workers, allocated_budget, importance)
VALUES(2, 'Human Resources', 12, 20000, 'medium')
INSERT INTO Departament(departament_id, departament_name, nr_of_workers, allocated_budget, importance)
VALUES(3, 'Cleaning', 4, 1000, 'low')
INSERT INTO Departament VALUES(4, 'Software', 40, 50000, 'high')
INSERT INTO Departament VALUES(5, 'Lift manager', 2, 2000, 'low')
INSERT INTO Departament(departament_id, departament_name, nr_of_workers, allocated_budget, importance)
VALUES(7, 'Sales', 18, 40000, 'medium')
INSERT INTO Departament(departament_id, departament_name, nr_of_workers, allocated_budget, importance)
VALUES(8, 'Accounting', 10, 15000, 'low')

SELECT * FROM Departament

-- Employee insertion
INSERT INTO [Employee]([employee_id],[departament_id],[employee_name], [salary], [gender],[position_in_company])
VALUES(1,1,'Rus Emanuel', 4000, 'male','Senior Developer')
INSERT INTO Employee
VALUES(2, 2, 'Borodi Razvan', 1500, 'male', 'Junior Developer')
INSERT INTO Employee
VALUES(3, 1, 'Moldovan Lorena', 2700, 'female', 'Dev-ops')
INSERT INTO Employee
VALUES(4, 2, 'Georgescu Florin', 1900, 'male', 'HR Senior')
INSERT INTO Employee
VALUES(5, 1, 'Petrescu Daria', 2300, 'female', 'Secretary')	
INSERT INTO Employee
VALUES(6, 3, 'Georgina Marian', 800, 'female', 'Cleaner')
INSERT INTO Employee
VALUES(7, NULL, 'Ariana Pop', 1200, 'Female', 'Pregnancy vacation')

--violation of referential integrity constraint : the departament with id 20 DOES NOT EXIST
INSERT INTO Employee
VALUES(8, 20, 'Moldovan Darius', 2000, 'male', 'Mid Developer')

-- OS insertion
INSERT INTO Operating_system(os_id, os_name, os_version, release_date, kernel_type, bits, headquarters)
VALUES(1, 'Windows', 11, '2021-10-05', 'hybrid', 64, 'Bucharest')
INSERT INTO Operating_system(os_id, os_name, os_version, release_date, kernel_type, bits, headquarters)
VALUES(2, 'Linux', 21, '2006-08-27', 'Monolithic', 32, 'New Dallas')
INSERT INTO Operating_system(os_id, os_name, os_version, release_date, kernel_type, bits, headquarters)
VALUES(3, 'MacOS', 14, '2023-06-05', 'XNU Kernel', 64, 'London')
INSERT INTO Operating_system(os_id, os_name, os_version, release_date, kernel_type, bits, headquarters)
VALUES(4, 'Windows', 10, '2015-07-29', 'hybrid', 64, 'Bucharest')

--Antivirus works on OS insertion
INSERT INTO Works_on (antivirus_id, os_id) VALUES (1,1)
INSERT INTO Works_on(antivirus_id, os_id) VALUES(1,2)
INSERT INTO Works_on(antivirus_id, os_id) VALUES(2,1)
INSERT INTO Works_on(antivirus_id, os_id) VALUES(3,2)
INSERT INTO Works_on(antivirus_id, os_id) VALUES(3,3)

--Customer insertion
INSERT INTO Customer(customer_id, customer_name, antivirus_id, username, passwd, subscription_paid)
VALUES(1, 'Maria Radulescu', 1, NULL, NULL, 1)
INSERT INTO Customer(customer_id, customer_name, antivirus_id, username, passwd, subscription_paid)
VALUES(2, 'George Pop', 2, 'George10', '1234', 1)
INSERT INTO Customer
VALUES(3, 'Georgescu Florin', 1, 'geo42', 'geo_antivirus1', 1)
INSERT INTO Customer
VALUES(4, 'Maria Moldovan', 2, 'mary22', 'mariamaria', 0)
INSERT INTO Customer
VALUES(5, 'Andrei Andreescu', 2, 'andr', 'andr123', 1)
INSERT INTO Customer
VALUES(6, 'Mario Iorgulescu', NULL, 'mario', 'mario223', 0)
INSERT INTO Customer
VALUES(7, 'Vasile Georgescu', 3, 'vasy44', 'vasyvasy', 1)

--Costs insertion
INSERT INTO Cost(cost_id, month_count, employee_id, taxes, production_costs)
VALUES(1, 'March', 3, 200, 1000)
INSERT INTO Cost(cost_id, month_count, employee_id, taxes, production_costs)
VALUES(2, 'June', 4, 300, 250)
INSERT INTO Cost
VALUES(3, 'March', 2, 150, 500)
INSERT INTO Cost
VALUES(4, 'January', 3, 300, 1200)
INSERT INTO Cost
VALUES(5, 'March', 1, 100, 400)
INSERT INTO Cost
VALUES(6, 'January', 5, 500, 1800);
INSERT INTO Cost
VALUES(7, 'February', 2, 200, 700);
INSERT INTO Cost
VALUES(8, 'April', 3, 350, 1400);
INSERT INTO Cost
VALUES(9, 'May', 4, 400, 1600);
INSERT INTO Cost
VALUES(10, 'July', 2, 250, 900);
INSERT INTO Cost
VALUES(11, 'August', 3, 400, 1500);
INSERT INTO Cost
VALUES(12, 'September', 1, 150, 600);
INSERT INTO Cost
VALUES(13, 'October', 5, 550, 2000);
INSERT INTO Cost
VALUES(14, 'November', 3, 300, 1200);
INSERT INTO Cost
VALUES(15, 'December', 4, 400, 1600);

--Locations insertion
INSERT INTO Locations
VALUES(1, 'USA', 'Washington', 'Abraham Lincoln')
INSERT INTO Locations
VALUES(2, 'France', 'Bordeaux', 'Bastille')
INSERT INTO Locations
VALUES(3, 'USA', 'Arizona', 'D. Roosevelt')
INSERT INTO Locations
VALUES(4, 'Romania', 'Bucharest', 'Eroilor')
INSERT INTO Locations
VALUES(5, 'Romania', 'Cluj', 'Muncii')

--Locations_of_Departaments insertion
INSERT INTO Location_of_Departaments VALUES(1,1)
INSERT INTO Location_of_Departaments VALUES(1,2)
INSERT INTO Location_of_Departaments VALUES(2,1)
INSERT INTO Location_of_Departaments VALUES(3,2)
INSERT INTO Location_of_Departaments VALUES(3,3)
INSERT INTO Location_of_Departaments VALUES (4,4)

--Associations insertion
INSERT INTO Associations
VALUES(1, 2, 'Mr_Proper', 120)
INSERT INTO Associations
VALUES(2, 2, 'HR_Experts', 30)

--UPDATE + DELETE
--AND
UPDATE Operating_system
SET os_version = 12, release_date = '2023-11-1'
WHERE os_id = 1 AND os_name = 'Windows'

--OR
UPDATE Opposition
SET position_in_antivirus_chart = position_in_antivirus_chart - 1
WHERE oppositon_profit > 5000 OR opposition_nr_of_members > 300

--IS NULL
UPDATE Customer
SET username = 'custom_1kri2', passwd = 'custom_pass_29ii41' --suppose someone has the option to be a guest, a user and a passwd should automatically be assignated
WHERE username IS NULL AND passwd IS NULL

-- < operator
DELETE FROM Cost
WHERE production_costs < taxes

-- BETWEEN
DELETE FROM Departament
WHERE nr_of_workers BETWEEN 0 AND 3

