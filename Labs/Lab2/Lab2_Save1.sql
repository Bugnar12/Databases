use Labs

DROP TABLE Customer
DROP TABLE Works_on
DROP TABLE Antivirus_soft
DROP TABLE Operating_system
DROP TABLE Cost
DROP TABLE Employee
DROP TABLE Departament
DROP TABLE Opposition
DROP TABLE Fiscal_value
DROP TABLE Associations


CREATE TABLE Antivirus_soft
(
	antivirus_id INT PRIMARY KEY,
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
	bits INT CHECK(bits in(32, 64))
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
	country VARCHAR(20)
)

CREATE TABLE Associations
(
	association_id INT PRIMARY KEY,
	association_name VARCHAR(40), 
	relationship_type VARCHAR(35),
	service_given VARCHAR(100),
	service_recieved VARCHAR(100),
)

CREATE TABLE Fiscal_value
(
	fiscal_id INT PRIMARY KEY,
	total_earnings INT,
	market_position VARCHAR(30),
	profit INT,
	percentage_compared_to_prev_year FLOAT,
)

CREATE TABLE Opposition
(
	opposition_id INT PRIMARY KEY,
	oppositon_name VARCHAR(30),
	position_in_antivirus_chart INT,
	oppositon_profit INT,
	opposition_members INT
)

CREATE TABLE Cost
(
	cost_id INT PRIMARY KEY,
	month_count VARCHAR(15) CHECK (month_count in ('January', 'February', 'March', 'April', 'May', 'June', 'JULY',
													'August', 'September', 'October', 'November', 'December')),
	employee_id INT FOREIGN KEY REFERENCES Employee(employee_id),
	taxes INT,
	production_costs INT
)

INSERT INTO Antivirus_soft(antivirus_id, antivirus_name, antivirus_version, manager, headquarters) 
VALUES (1, 'Bitdefender', '12.4', 'Florin Talpes', 'Bucharest')	

INSERT INTO Antivirus_soft(antivirus_id, antivirus_name, antivirus_version, manager, headquarters) 
VALUES (2, 'Norton', '10.6', 'Robert Hentschel', 'Arizona')

INSERT INTO Antivirus_soft(antivirus_id, antivirus_name, antivirus_version, manager, headquarters) 
VALUES (3, 'McAfee', '6.1', 'Greg Johnson', 'California')


INSERT INTO [Departament]
           ([departament_id]
           ,[departament_name]
           ,[nr_of_workers]
           ,[allocated_budget]
           ,[importance])
     VALUES
           (1,
		   'ManualTesting',
			20,
			4000,
			'medium')

INSERT INTO [Employee]
           ([employee_id]
           ,[departament_id]
           ,[employee_name]
           ,[gender]
           ,[position_in_company])
     VALUES
           (1,
		   1,
		   'Rus Emanuel',
		   'male',
		   'Senior Developer'
		   )

INSERT INTO Employee(employee_id, departament_id, employee_name, gender, position_in_company) 
VALUES(2, 2, 'Borodi Razvan', 'male', 'Junior Developer')

INSERT INTO Operating_system(os_id, os_name, os_version, release_date, kernel_type, bits)
VALUES(1, 'Windows', 11, '2021-10-05', 'hybrid', 64)

INSERT INTO Works_on (antivirus_id, os_id) VALUES (1,1)
INSERT INTO Employee(employee_id, departament_id, employee_name, gender, position_in_company)
VALUES(3, 1, 'Moldovan Lorena', 'female', 'Dev-ops')

INSERT INTO Customer(customer_id, customer_name, antivirus_id, username, passwd, country)
VALUES(1, 'George Pop', 1, 'George10', '1234', 'Moldova')

UPDATE Employee
SET position_in_company = 'Senior Dev-ops'
WHERE employee_id = 3;

SELECT * FROM Employee;

SELECT * FROM Works_on "Compatibility"

SELECT * FROM Operating_system
SELECT * FROM Employee
