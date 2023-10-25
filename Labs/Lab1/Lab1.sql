use Labs

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

DROP TABLE Cost