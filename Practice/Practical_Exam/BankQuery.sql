create table Clients(
	clientID int primary key,
	name varchar(50) unique
)
create table Bank(
	bankID int primary key,
	bankName varchar(50)
)

create table ClientsAndBanks(
	clientID int foreign key references Clients(clientID),
	clientName varchar(50) foreign key references Clients(name),
	bankID int foreign key references Bank(bankID)
)

create table BankingServices(
	bankServicesID int primary key,
	bankID int foreign key references Bank(bankID),
)

create table InvestingServices(
	investingServicesID int primary key,
	bankID int foreign key references Bank(bankID)
)

create table BankingServicesClients(
	clientID int foreign key references Clients(clientID),
	bankServicesID int foreign key references BankingServices(bankServicesID)
)

create table InvestingServicesClients(
	clientName varchar(50) foreign key references Clients(name),
	investingServicesID int foreign key references InvestingServices(investingServicesID)
)

INSERT INTO Clients VALUES (1, 'client1');
INSERT INTO Clients VALUES (2, 'client2');
INSERT INTO Clients VALUES (3, 'client3');

INSERT INTO Bank VALUES (1, 'Bank1');
INSERT INTO Bank VALUES (2, 'Bank2');
INSERT INTO Bank VALUES (3, 'Bank3');

INSERT INTO ClientsAndBanks VALUES (1, 'client1', 1);
INSERT INTO ClientsAndBanks VALUES (2, 'client2', 2);
INSERT INTO ClientsAndBanks VALUES (3, 'client3', 3);

INSERT INTO BankingServices VALUES (1, 1);
INSERT INTO BankingServices VALUES (2, 2);
INSERT INTO BankingServices VALUES (3, 3);

INSERT INTO InvestingServices VALUES (1, 1);
INSERT INTO InvestingServices VALUES (2, 2);
INSERT INTO InvestingServices VALUES (3, 3);

INSERT INTO BankingServicesClients VALUES (1, 1);
INSERT INTO BankingServicesClients VALUES (2, 2);
INSERT INTO BankingServicesClients VALUES (3, 3);

INSERT INTO InvestingServicesClients VALUES ('client1', 1);
INSERT INTO InvestingServicesClients VALUES ('client2', 2);
INSERT INTO InvestingServicesClients VALUES ('client3', 3);

go
create or alter proc proc1 (@bankID int, @clientID int)
as
begin
	if not exists (select BSC.clientID from BankingServicesClients BSC where BSC.clientID = @clientID)
		
end
	