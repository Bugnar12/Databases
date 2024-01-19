create table Cities(
	cityID int primary key,
	name varchar(50) unique
)

create table Stadiums(
	stadiumID int primary key,
	name varchar(50),
	cityID int foreign key references Cities(cityID)
)

create table NationalTeams(
	teamID int primary key,
	country varchar(50) unique
)

create table Players(
	playerID int primary key,
	name varchar(100),
	dob date,
	nationality varchar(50),
	position varchar(50),
	captain bit,
	teamID int foreign key references NationalTeams(teamID)
)

create table Coaches(
	coachID int primary key,
	name varchar(50),
	teamID int foreign key references NationalTeams(teamID)
)

create table Games(
	gameID int primary key,
	datePlay date,
	team1 int foreign key references NationalTeams(teamID),
	team2 int foreign key references NationalTeams(teamID),
	stadiumID int foreign key references Stadiums(stadiumID),
	final_score varchar(10),
	winnerID int,
	overtime bit
)

insert into Cities values(1, 'city1')
insert into Cities values(2, 'city2')
insert into Cities values(3, 'city3')

insert into Stadiums values(1, 'stadium1', 1)
insert into Stadiums values(2, 'stadium2', 1)
insert into Stadiums values(3, 'stadium3', 2)
insert into Stadiums values(4, 'stadium4', 3)

insert into NationalTeams values (1, 'country1')
insert into NationalTeams values (2, 'country2')
insert into NationalTeams values (3, 'country3')
insert into NationalTeams values (4, 'country4')
insert into NationalTeams values (5, 'country5')

insert into Players values (1, 'name1', '2000-06-12', 'nat1', 'striker', 0, 1)
insert into Players values (2, 'name2', '2000-04-19', 'nat2', 'defeneder', 0, 1)
insert into Players values (3, 'name3', '2000-03-13', 'nat3', 'goalkeeper', 0, 1)
insert into Players values (4, 'name4', '2000-06-14', 'nat4', 'defeneder', 1, 2)
insert into Players values (5, 'name5', '2000-08-15', 'nat5', 'striker', 0, 2)
insert into Players values (6, 'name6', '2000-09-03', 'nat6', 'defeneder', 0, 3)
insert into Players values (7, 'name7', '2000-11-29', 'nat7', 'sweeper', 0, 4)

insert into Coaches values (1, 'name1', 1)
insert into Coaches values (2, 'name2', 2)
insert into Coaches values (3, 'name3', 3)
insert into Coaches values (4, 'name4', 1)
insert into Coaches values (5, 'name5', 4)
insert into Coaches values (6, 'name6', 5)
insert into Coaches values (7, 'name7', 4)

insert into Games values(1, '2023-02-02', 1, 2, 1, '10-20', 2, 0)
insert into Games values(2, '2023-08-12', 1, 3, 1, '29-25', 1, 0)
insert into Games values(3, '2023-07-02', 1, 4, 3, '30-26', 1, 0)
insert into Games values(4, '2023-06-22', 2, 4, 2, '21-20', 2, 1)
insert into Games values(5, '2023-05-15', 3, 4, 2, '10-20', 4, 0)
insert into Games values(6, '2023-04-16', 4, 5, 1, '10-25', 5, 0)
insert into Games values(7, '2023-12-20', 3, 1, 3, '25-20', 3, 1)
insert into Games values(10, '2023-10-21', 1, 4, 3, '23-20', 1, 1)
insert into Games values(9, '2023-12-26', 2, 3, 3, '22-20', 2, 1)

go
create or alter proc addGame(@gameID INT, @date DATE, @team1 INT, @team2 INT, @stadium INT, @score VARCHAR(40), @winnerID INT, @overtime BIT)
as
begin
	if not exists(select T.teamID from NationalTeams T where T.teamID = @team1)
	begin
		raiserror('Inexisting team 1!', 16, 1)
	end
	if not exists(select T.teamID from NationalTeams T where T.teamID = @team2)
	begin
		raiserror('Inexisting team 2!', 16, 1)
	end
	if not exists(select S.stadiumID from Stadiums S where S.stadiumID = @stadium)
	begin
		raiserror('Inexisting stadium!', 16, 1)
	end

	if exists (SELECT G.gameID from Games G where G.gameID = @gameID)
	begin
		update Games
		set final_score = @score
	end
	else
		insert into Games values(@gameID, @date, @team1, @team2, @stadium, @score, @winnerID, @overtime)
end
go

exec addGame 8, '2022-07-07', 4, 3, 2, '20-30', 2, 0

select * from Games
go
create or alter view showStadiums
as
	select S.name
	from Stadiums S
	where S.stadiumID in
		(select distinct G.stadiumID
		from Games G
		group by G.stadiumID
		HAVING count(G.overtime) = (select COUNT(G1.overtime) from Games G1 where G.stadiumID = G1.stadiumID and overtime = 1)
		)
go

create or alter function scoreDiff(@S int, @R int)
RETURNS
int
AS
RETURN
	select count(*)
	from NationalTeams T
go



go
SELECT *
    FROM Games AS g
    INNER JOIN NationalTeams AS n
    ON g.winner = n.teamID
    WHERE g.stadiumID = stadiumID

