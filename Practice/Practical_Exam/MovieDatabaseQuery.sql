create table StageDirector(
	directorID int primary key,
	name varchar(50),
	no_of_awards int
)

create table Company(
	companyID int primary key,
	name varchar(50)
)

create table Movie(
	movieID int primary key,
	name varchar(50),
	release_date date,
	directorID int foreign key references StageDirector(directorID),
	companyID int foreign key references Company(companyID)
)

create table Actor(
	actorID int primary key,
	name varchar(50),
	ranking int
)

create table CinemaProduction(
	productionID int primary key, 
	title varchar(50),
	movieID int foreign key references Movie(movieID),
)

create table CinemaProductionActors(
	productionID int foreign key references CinemaProduction(productionID),
	actorID int foreign key references Actor(actorID),
	primary key (productionID, actorID),
	entryMoment date
)

-- Insert data into StageDirector table
INSERT INTO StageDirector (directorID, name, no_of_awards) VALUES
(1, 'John Doe', 3),
(2, 'Jane Smith', 5);

-- Insert data into Company table
INSERT INTO Company (companyID, name) VALUES
(1, 'ABC Studios'),
(2, 'XYZ Productions');

-- Insert data into Movie table
INSERT INTO Movie (movieID, name, release_date, directorID, companyID) VALUES
(101, 'The Great Movie', '2023-05-15', 1, 1),
(102, 'Blockbuster Hit', '2024-02-28', 2, 2);

-- Insert data into Actor table
INSERT INTO Actor (actorID, name, ranking) VALUES
(501, 'Tom Actorson', 1),
(502, 'Emma Actress', 3);

-- Insert data into CinemaProduction table
INSERT INTO CinemaProduction (productionID, title, movieID) VALUES
(1001, 'Awesome Production', 101),
(1002, 'Epic Film', 102);

-- Insert data into CinemaProductionActors table
INSERT INTO CinemaProductionActors (productionID, actorID, entryMoment) VALUES
(1001, 501, '2023-04-01'),
(1001, 502, '2023-04-01'),
(1002, 502, '2024-01-15');


--2.Stored proc. that recieves an actor an entry moment	and a cinema production and adds the new actor to the production
go
create or alter proc addActor(@actorID int, @entryMoment date, @productionID int)
AS
BEGIN
	if exists(select CPA.actorID, CPA.productionID from CinemaProductionActors CPA where CPA.actorID = @actorID and CPA.productionID = @productionID)
	BEGIN
		raiserror('Invalid entry data!', 16, 1)
	END
	else
	INSERT INTO CinemaProductionActors(productionID, actorID, entryMoment)
	VALUES(@actorID, @productionID, @entryMoment)
END
GO

--3.View that shows the name of the actors that appear in all the cinema productions
--Question : is this the same query like AlexandraViorel?


CREATE OR ALTER VIEW selectAllActors
AS
	select A.name
	FROM Actor A inner join CinemaProductionActors CPA on A.actorID = CPA.actorID
	GROUP BY A.name
	HAVING count(productionID) = (select count(*) from CinemaProduction)
go

--4.Function that returns all movies that have the release date after 2018.01.01 and have at least p productions, p parameter

create or alter function movieReleaseDate (@p int)
returns table
as
return
	select M.name
	from Movie M
	where M.release_date > '2018-01-01' AND count(M.movieID) >= (
	(select count(CP.movieID) from CinemaProduction CP group by CP.movieID HAVING CP.productionID >= @p))
go

SELECT * FROM movieReleaseDate(1)


--This version is good(ChatGPT)
GO
CREATE FUNCTION GetMoviesWithProductions
(
    @p INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT M.movieID, M.name AS movieName, M.release_date
    FROM Movie M
    INNER JOIN CinemaProduction CP ON M.movieID = CP.movieID
    GROUP BY M.movieID, M.name, M.release_date
    HAVING M.release_date > '2018-01-01' AND COUNT(CP.productionID) >= @p
);
GO
select * from GetMoviesWithProductions(1)
select * from CinemaProduction CP inner join Movie M on CP.movieID = M.movieID