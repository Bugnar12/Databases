	create table Customer(
		customerID int primary key,
		name VARCHAR(50),
		dob DATE
	)

	create table Atm(
		atmID int primary key,
		address VARCHAR(max)
	)

	create table BankAccount(
		iban int primary key,
		currBalance INT,
		customerID INT foreign key references Customer(customerID)
	)

	create table Cards(
		cardID int primary key,
		cvv INT,
		iban int foreign key references BankAccount(iban)
	)

	create table Transactions(
		transactionID INT primary key,
		atmID int foreign key references Atm(atmID),
		cardID int foreign key references Cards(cardID),
		time_ time,
		money_ int
	)

-- Insert data into Customer table
INSERT INTO Customer (customerID, name, dob)
VALUES (1, 'John Doe', '1990-05-15');

-- Insert data into Atm table
INSERT INTO Atm (atmID, address)
VALUES (101, '123 Main Street, Cityville');

-- Insert data into BankAccount table
INSERT INTO BankAccount (iban, currBalance, customerID)
VALUES (123456789, 5000, 1);

-- Insert data into Cards table
INSERT INTO Cards (cardID, cvv, iban)
VALUES (1001, 123, 123456789);

-- Insert data into Transactions table
INSERT INTO Transactions (transactionID, atmID, cardID, time_, money_)
VALUES (2001, 101, 1001, '12:30:00', 1000);
-- Additional inserts for Customer table
INSERT INTO Customer (customerID, name, dob)
VALUES (2, 'Jane Smith', '1985-09-20');

INSERT INTO Customer (customerID, name, dob)
VALUES (3, 'Mike Johnson', '1998-03-08');

-- Additional inserts for Atm table
INSERT INTO Atm (atmID, address)
VALUES (102, '456 Oak Avenue, Townsville');

INSERT INTO Atm (atmID, address)
VALUES (103, '789 Pine Road, Villagetown');

-- Additional inserts for BankAccount table
INSERT INTO BankAccount (iban, currBalance, customerID)
VALUES (987654321, 8000, 2);

INSERT INTO BankAccount (iban, currBalance, customerID)
VALUES (456789012, 3000, 3);

-- Additional inserts for Cards table
INSERT INTO Cards (cardID, cvv, iban)
VALUES (1002, 456, 987654321);

INSERT INTO Cards (cardID, cvv, iban)
VALUES (1003, 789, 456789012);

-- Additional inserts for Transactions table
INSERT INTO Transactions (transactionID, atmID, cardID, time_, money_)
VALUES (2002, 102, 1002, '14:45:00', 1500);

INSERT INTO Transactions (transactionID, atmID, cardID, time_, money_)
VALUES (2003, 103, 1003, '16:30:00', 800);

INSERT INTO Transactions (transactionID, atmID, cardID, time_, money_)
VALUES (2004, 102, 1001, '17:30:00', 800);

INSERT INTO Transactions (transactionID, atmID, cardID, time_, money_)
VALUES (2005, 103, 1001, '18:30:00', 800);


--2.Delete from the transactions the cards if they are valid
GO
create or alter proc deleteTransaction(@cardID INT)
AS
BEGIN
	--If there is not a card for what we want to delete raise error
	if NOT EXISTS(SELECT C.cardID FROM Cards C where C.cardID = @cardID)
	BEGIN
		RAISERROR('Invalid card!', 16, 1)
	END
	else
		delete from Transactions where Transactions.cardID = @cardID
END
GO

--3.Create a view that shows the card numbers used for transactions in all atms

go
create or alter view displayAll
AS
	SELECT C.cardID as Cards
	FROM Cards C
	WHERE ((SELECT COUNT(*) FROM ATM) = (SELECT COUNT(DISTINCT T.atmID) FROM
											Transactions T inner join Atm A ON T.atmID = A.atmID
											where T.cardID = C.cardID))
go

select * from displayAll

--4.Function that lists the cards (number + cvv) that have total transactions sum > 2000
go
create or alter function displaySum()
returns table
as
return
	SELECT C.cardID, C.cvv
	FROM Cards C inner join Transactions T on C.cardID = T.cardID
	GROUP BY C.cardID, C.cvv
	HAVING sum(T.money_) > 2000
go


SELECT * FROM displaySum()