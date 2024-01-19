create table Zoo(
	zooID int primary key,
	administrator varchar(50),
	name varchar(50)
)

create table Animal(
	animalID int primary key,
	name varchar(50),
	dob date,
	zooID int foreign key references Zoo(zooID)
)

create table Food(
	foodID int primary key,
	name varchar(50)
)

create table AnimalsFood(
	animalID int foreign key references Animal(animalID),
	foodID int foreign key references Food(foodID),
	primary key (animalID, foodID),
	quota int
)

create table Visitor(
	visitorID int primary key,
	name varchar(50),
	age int
)

create table Visits(
	visitID int primary key,
	day_ varchar(50),
	price int,
	visitorID int foreign key references Visitor(visitorID),
	zooID int foreign key references Zoo(zooID)
)

-- Inserts for Zoo table
INSERT INTO Zoo VALUES (1, 'Admin A', 'Zoo A');
INSERT INTO Zoo VALUES (2, 'Admin B', 'Zoo B');
INSERT INTO Zoo VALUES (3, 'Admin C', 'Zoo C');

-- Inserts for Animal table
INSERT INTO Animal VALUES (1, 'Lion', '2020-01-01', 1);
INSERT INTO Animal VALUES (2, 'Elephant', '2018-05-15', 2);
INSERT INTO Animal VALUES (3, 'Giraffe', '2019-07-20', 1);

-- Inserts for Food table
INSERT INTO Food VALUES (1, 'Meat');
INSERT INTO Food VALUES (2, 'Hay');
INSERT INTO Food VALUES (3, 'Leaves');

-- Inserts for AnimalsFood table
INSERT INTO AnimalsFood VALUES (1, 1, 10);
INSERT INTO AnimalsFood VALUES (1, 2, 15);
INSERT INTO AnimalsFood VALUES (2, 2, 20);

-- Inserts for Visitor table
INSERT INTO Visitor VALUES (1, 'Visitor A', 25);
INSERT INTO Visitor VALUES (2, 'Visitor B', 30);
INSERT INTO Visitor VALUES (3, 'Visitor C', 22);

-- Inserts for Visits table
INSERT INTO Visits VALUES (1, '2024-01-10', 15, 1, 1);
INSERT INTO Visits VALUES (2, '2024-01-11', 20, 2, 2);
INSERT INTO Visits VALUES (3, '2024-01-12', 18, 3, 3);
INSERT INTO Visits VALUES (4, '2024-01-22', 20, 2, 3);
INSERT INTO Visits VALUES (5, '2024-02-12', 15, 3, 2);


go
create or alter proc deleteData(@animalID int)
as
begin
	IF EXISTS(select A.animalID from Animal A where A.animalID = @animalID)
	begin
		delete
		from AnimalsFood
		where animalID = @animalID
	end
	else
		raiserror('Invalid animal!', 16, 1)

end
go

exec deleteData 2
select * from AnimalsFood

go

create or alter view showZoo
as
	select COUNT(V.zooID) as ZooID
	from Zoo Z inner join Visits V on Z.zooID = V.zooID
	group by Z.zooID
	HAVING count(Z.zooID) <= ALL (SELECT count(Z1.zooID)
									from Zoo Z1 inner join Visits V1 on Z1.zooID = V1.zooID
									group by Z1.zooID)


select * from showZoo

GO
create or alter function listVisitors(@N int)
RETURNS
TABLE
AS
RETURN
	--no animals > @N
	select V.visitorID
	from Visits V
	where V.zooID in
		(select Z.zooID
		from Zoo Z inner join Animal A on Z.zooID = A.zooID
		group by Z.zooID
		HAVING count(A.animalID) > @N)


select * from listVisitors(1)