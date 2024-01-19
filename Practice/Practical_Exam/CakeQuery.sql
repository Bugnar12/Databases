create table Chef(
	chefID int primary key,
	name varchar(50),
	gender varchar(50),
	dob date
)

create table CakeTypes(
	caketypeID int primary key,
	name varchar(50),
	description varchar(100)
)

create table Orders(
	orderID int primary key,
	purchaseDate date
)

create table Cake(
	cakeID int primary key,
	name varchar(50),
	shape varchar(50),
	weight int,
	price int,
	caketypeID int foreign key references CakeTypes(caketypeID)
)

create table ConfectionaryChefs(
	chefID int foreign key references Chef(chefID),
	cakeID int foreign key references Cake(cakeID),
	primary key (chefID, cakeID)
)
create table CakeOrders(
	orderID int foreign key references Orders(orderID),
	cakeID int foreign key references Cake(cakeID),
	primary key (cakeID, orderID),
	noOfCakes int
)

INSERT INTO CakeTypes(caketypeID, name, description) VALUES (1, 'Dobos', 'bun')
INSERT INTO CakeTypes(caketypeID, name, description) VALUES (2, 'Cremes', 'f. bun')
INSERT INTO CakeTypes(caketypeID, name, description) VALUES (3, 'Albinita', 'excelent')

INSERT INTO Cake(cakeID, name, shape, weight, price, caketypeID) VALUES (1, 'Dobos1', 'rotund', 10, 100, 1)
INSERT INTO Cake(cakeID, name, shape, weight, price, caketypeID) VALUES (2, 'Dobos2', 'patrat', 13, 120, 1)
INSERT INTO Cake(cakeID, name, shape, weight, price, caketypeID) VALUES (3, 'Cremes1', 'rotund-oval', 12, 80, 2)
INSERT INTO Cake(cakeID, name, shape, weight, price, caketypeID) VALUES (4, 'Albinita1', 'piramida', 15, 170, 3)

INSERT INTO Chef(chefID, name, gender, dob) VALUES (1, 'CM1', 'male', '1975-09-05')
INSERT INTO Chef(chefID, name, gender, dob) VALUES (2, 'CF1', 'female', '1977-02-15')
INSERT INTO Chef(chefID, name, gender, dob) VALUES (3, 'CM1', 'male', '1985-10-20')

insert into ConfectionaryChefs(chefID, cakeID) VALUES (1, 1)
insert into ConfectionaryChefs(chefID, cakeID) VALUES (1, 2)
insert into ConfectionaryChefs(chefID, cakeID) values (1, 3)
insert into ConfectionaryChefs(chefID, cakeID) values (1, 4)
insert into ConfectionaryChefs(chefID, cakeID) VALUES (2, 2)
insert into ConfectionaryChefs(chefID, cakeID) VALUES (3, 3)
insert into ConfectionaryChefs(chefID, cakeID) VALUES (3, 1)

insert into Orders(orderID, purchaseDate) VALUES (1, '2021-09-09')
insert into Orders(orderID, purchaseDate) VALUES (2, '2020-09-05')
insert into Orders(orderID, purchaseDate) VALUES (3, '2021-08-01')
insert into Orders(orderID, purchaseDate) VALUES (4, '2021-05-24')
insert into Orders(orderID, purchaseDate) VALUES (5, '2022-03-12')

insert into CakeOrders(orderID, cakeID, noOfCakes) VALUES (1, 2, 3)
insert into CakeOrders(orderID, cakeID, noOfCakes) VALUES (1, 1, 1)
insert into CakeOrders(orderID, cakeID, noOfCakes) VALUES (2, 2, 3)
insert into CakeOrders(orderID, cakeID, noOfCakes) VALUES (3, 2, 2)
insert into CakeOrders(orderID, cakeID, noOfCakes) VALUES (4, 3, 6)
insert into CakeOrders(orderID, cakeID, noOfCakes) VALUES (5, 1, 2)

go
create or alter proc addCake(@orderID INT, @cakeName VARCHAR(50), @P INT)
as
begin
	IF NOT EXISTS (SELECT O.orderID from Orders O where O.orderID = @orderID)
	begin
		raiserror('Invalid order!', 12, 1)
	end

	if not exists(select C.name from Cake C where C.name = @cakeName)
	begin
		raiserror('Invalid cake!', 12, 1)
	end
	
	declare @cake_id int = (select C.cakeID from Cake C where C.name = @cakeName)

	IF exists(select O.orderID from Orders O where O.orderID = @orderID) AND @cake_id is not null
		if exists(select CO.orderID, CO.cakeID from CakeOrders CO WHERE CO.orderID = @orderID and CO.cakeID = @cake_id)
		begin
			update CakeOrders
			SET noOfCakes = @P
			WHERE orderID = @orderID and cakeID = @cake_id
		end
		else
			insert into CakeOrders values (@orderID, @cake_id, @P)
end
go

EXEC addCake 2, 'Dobos5', 2

select * from Chef
--3.Implement function that lists the name of the chefs that are specialized in all the cakes.
--From ChefCakes, group by the chefID
go
create or alter function listChefs()
returns
table
as
return
		select C.name
		from Chef C
		where C.chefID IN
				(select CC.chefID
				from ConfectionaryChefs CC
				GROUP BY CC.chefID
				HAVING count(*) = (select count(*) from Cake)
				)
go

select * from Cake
select * from listChefs()


