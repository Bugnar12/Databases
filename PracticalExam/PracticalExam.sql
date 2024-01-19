create table Players(
	playerID int primary key,
	name varchar(50),
	dob date,
	nationality varchar(50),
	ranking int
)

create table Court(
	courtID int primary key,
	name varchar(50),
	number int UNIQUE
)

create table Referee(
	refereeID int primary key,
	name varchar(50),
)
create table Matches(
	matchID int primary key,
	player1 int,
	player2 int,
	scorePlayer1 int,
	scorePlayer2 int,
	date_ date,
	duration int,
	round_ varchar(50)
	check(round_ in ('first tour', 'quarter final', 'semi final', 'final')),
	courtID int foreign key references Court(courtID),
	winner int
)
create table RefereeMatches(
	matchID int foreign key references Matches(matchID),
	refereeID int foreign key references Referee(refereeID),
	primary key(refereeID, matchID)
)

alter table Matches add foreign key (player1) references Players(playerID)
alter table Matches add foreign key (player2) references Players(playerID)

insert into Players values (1, 'player1', '2000-01-01', 'nat1', 6)
insert into Players values (2, 'player2', '2001-03-12', 'nat1', 2)
insert into Players values (3, 'player3', '2000-12-13', 'nat1', 3)
insert into Players values (4, 'player4', '2000-06-01', 'nat1', 4)
insert into Players values (5, 'player5', '2000-05-29', 'nat1', 5)


insert into Court values (1, 'court1', 1)
insert into Court values (2, 'court2', 2)
insert into Court values (3, 'court3', 3)
insert into Court values (4, 'court4', 4)
insert into Court values (5, 'court5', 5)

insert into Referee values(1, 'ref1')
insert into Referee values(2, 'ref2')
insert into Referee values(3, 'ref3')
insert into Referee values(4, 'ref4')

insert into Matches values (1, 1, 2, 7, 3, '2024-01-05', 100, 'first tour', 1, 1)
insert into Matches values (2, 1, 5, 6, 2, '2024-01-15', 100, 'first tour', 1, 1)
insert into Matches values (3, 2, 3, 6, 3, '2024-01-06', 100, 'first tour', 3, 2)
insert into Matches values (4, 4, 1, 6, 5, '2024-01-25', 100, 'quarter final', 2, 4)
insert into Matches values (5, 2, 4, 6, 1, '2024-02-15', 100, 'quarter final', 5, 2)
insert into Matches values (6, 3, 1, 6, 2, '2024-01-08', 100, 'first tour', 4, 3)
insert into Matches values (7, 3, 5, 6, 3, '2024-01-18', 100, 'semifinal', 3, 3)


insert into RefereeMatches values(1, 2)
insert into RefereeMatches values(1, 3)
insert into RefereeMatches values(2, 1)
insert into RefereeMatches values(3, 4)
insert into RefereeMatches values(3, 3)
insert into RefereeMatches values(4, 2)




go
create or alter proc procedure1(@matchID int, @player1 int, @player2 int, @score1 int, @score2 int, @date_ date,
									@duration int, @round varchar(50), @courtID int, @winner int)
as
begin
		--check if the player exists
		if exists(select M.player1, M.player2 from Matches M where M.player1 = @player1 AND M.player2 = @player2)
		begin
			update Matches
			set scorePlayer1 = @score1, scorePlayer2 = @score2
			where player1 = @player1 AND player2 = @player2
		end
		else
			insert into Matches values(@matchID, @player1, @player2, @score1, @score2, @date_, @duration, @round, @courtID, @winner)

end
go

exec procedure1 10, 2, 3, 6, 1, '2024-01-17', 120, 'semi final', 3, 2
select * from Matches

go
create or alter view view1
as

	--select the ranking of the opponents 
	select count (*) as Courts
	from Court C
	where C.courtID IN
				(select M.courtID
				from Matches M inner join Players P on M.player1 = P.playerID or M.player2 = P.playerID
				where M.winner = M.player1 and P.ranking in (select P.ranking 
															from Matches M1 inner join Players P on M1.player2 = P.playerID
															where M1.player1 = M.player))

go

select * from view1
	
go
create or alter function function1(@S date, @E date)
returns
table
as
return

		select count(RM.refereeID) AS CountRef
		from Matches M inner join RefereeMatches RM on M.matchID = RM.matchID
		where M.date_ >= @S AND M.date_ <= @E
		group by RM.matchID
		HAVING count(RM.referee) >= ALL(select count(RM1.matchID)
								from Matches M1 inner join RefereeMatches RM1 on M1.matchID = RM1.matchID
								group by RM1.matchID)
go
