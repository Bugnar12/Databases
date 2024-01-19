create table Women(
	wid int primary key,
	name varchar(50),
	money int
)	

create table ShoeModels(
	smid int primary key,
	name varchar(50),
	season varchar(20)
)

create table Shoes(
	sid_ int primary key,
	price int,
	smid int foreign key references ShoeModels(smid)
)

create table PresentationShops(
	psid int primary key,
	name varchar(50),
	city varchar(50),
)

create table ShoesShop(
	sid_ int foreign key references Shoes(sid_),
	psid int foreign key references PresentationShops(psid),
	primary key (sid_, psid),
	availableShoes int
)

create table WomanShoes(
	wid int foreign key references Women(wid),
	sid_ int foreign key references Shoes(sid_),
	primary key(wid, sid_),
	numberShoes int,
	moneySpent int
)

--2.Create a proc that recieves a shoe, presentation shop and the nr. of shoes and adds the shoe to the presentation shop

GO
create or alter proc addShoe(@sid_ int, @psid int, @nrShoes int)
AS
BEGIN
	declare @shoeID INT = (select S.sid_ from Shoes S where S.sid_ = @sid_)
	declare @pshopID int = (select PS.psid from PresentationShops PS where PS.psid = @psid)

	if @shoeID is not null and @pshopID is not null
		if not exists (select * from ShoesShop SS WHERE SS.sid_ = @sid_ and SS.psid = @psid)
			INSERT INTO ShoesShop(sid_, psid, availableShoes) VALUES(@sid_, @psid, @nrShoes)
		else
			update ShoesShop
			SET ShoesShop.availableShoes = @nrShoes
	else
		raiserror('Invalid input!', 16, 1)
END
GO

--3.View that shows the women that bought at least 2 shoes of a given model
go
create or alter view displayWomen
AS
	SELECT W.name
	FROM Women W
	WHERE W.wid IN ( SELECT WS.wid FROM WomanShoes WS where WS.numberShoes >= 2)
GO

--4.Create a function that lists the shoes that can be found in at least T presentation shops, where
--T is a function parameter

go
create function shoesInShop(@T int)
returns table
as
return
	select * from Shoes S
	WHERE S.sid_ IN (select sid_ from ShoesShop group by sid_ Having count(*) >= @T)
GO
