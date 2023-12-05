--Modify the type of a column
CREATE OR ALTER PROCEDURE modifyType
AS
BEGIN
	ALTER TABLE Associations
	ALTER COLUMN number_of_emplyees VARCHAR(10)
	PRINT('Changing in Associations, type from INT to VARCHAR')
END
GO

--UNDO
CREATE OR ALTER PROCEDURE modifyTypeUNDO
AS
BEGIN
	ALTER TABLE Associations
	ALTER COLUMN number_of_emplyees INT
	PRINT('Changing in Associations, type from VARCHAR to INT')
END
GO

--Add/remove a column
CREATE OR ALTER PROCEDURE addColumn
AS
BEGIN
	ALTER TABLE Customer
	ADD loyalty INT
	print('Adding a column in the Customer table')
END
GO

--UNDO
CREATE OR ALTER PROCEDURE addColumnUNDO
AS
BEGIN
	ALTER TABLE Customer
	DROP COLUMN loyalty
	PRINT('Removing a column in the Customer table')
END
GO

--Add/remove Default constraint
CREATE OR ALTER PROCEDURE addDefaultConstraint
AS
BEGIN
	ALTER TABLE Customer
	ADD CONSTRAINT default_paid_subscription DEFAULT 1 FOR subscription_paid
	PRINT('Adding default constraint for the subscription paid in Customer table')
END
GO

--UNDO
CREATE OR ALTER PROCEDURE addDefaultConstraintUNDO
AS
BEGIN
	ALTER TABLE Customer
	DROP CONSTRAINT default_paid_subscription
	PRINT('Removing the default constraint from the Customer table')
END
GO

--Add/remove a table
CREATE OR ALTER PROCEDURE addTable
AS
BEGIN
	CREATE TABLE FiredEmployee(
		fullName VARCHAR(80) NOT NULL, 
		reason VARCHAR(80) NOT NULL,
		employee_id INT NOT NULL,
		current_status VARCHAR(20),
		CONSTRAINT FIRED_EMPLOYEE_PRIMARY_KEY PRIMARY KEY(fullName)
		)
		PRINT 'Table FiredEmployee has been added'
END
GO

--UNDO
CREATE OR ALTER PROCEDURE addTableUNDO
AS
BEGIN
	DROP TABLE IF EXISTS FiredEmployee
	PRINT 'Table FiredEmployee has been removed'
END
GO

--Add and remove Primary key
CREATE OR ALTER PROCEDURE dropPrimaryKeyReason
AS
BEGIN
	ALTER TABLE FiredEmployee
	DROP Constraint FIRED_EMPLOYEE_PRIMARY_KEY
		ALTER TABLE FiredEmployee
		ADD CONSTRAINT FIRED_EMPLOYEE_PRIMARY_KEY PRIMARY KEY (fullname, reason)
	PRINT 'Adding the reason as a new primary key in the FiredEmployee table'
END
GO

--UNDO
CREATE OR ALTER PROCEDURE dropPrimaryKeyReasonUNDO
AS
BEGIN
	ALTER TABLE FiredEmployee
	DROP CONSTRAINT FIRED_EMPLOYEE_PRIMARY_KEY 
		ALTER TABLE FiredEmployee
		ADD CONSTRAINT FIRED_EMPLOYEE_PRIMARY_KEY PRIMARY KEY (fullname)
	PRINT 'Removing the reason as a new primary key in the FiredEmployee table'
END
GO

--Add/remove a Candidate key
CREATE OR ALTER PROCEDURE addCandidateKey
AS
BEGIN
	ALTER TABLE Customer
	ADD CONSTRAINT CUSTOMER_CANDIDATE_KEY UNIQUE(username, passwd)
	PRINT 'Adding a new candidate key in Customer(username,passwd)'
END
GO

--UNDO
CREATE OR ALTER PROCEDURE addCandidateKeyUNDO
AS
BEGIN
	ALTER TABLE Customer
	DROP CONSTRAINT CUSTOMER_CANDIDATE_KEY
	PRINT 'Removing the candidate key from Customer(username,passwd)'
END
GO

--Add/remove a Foreign key
CREATE OR ALTER PROCEDURE addForeignKey
AS
BEGIN
	ALTER TABLE FiredEmployee
	ADD CONSTRAINT FIRED_EMPLOYEE_FOREIGN_KEY FOREIGN KEY(employee_id) REFERENCES Employee(employee_id)
	PRINT 'Adding a foreign key in the FiredEmployee table to Employee table'
END
GO

--UNDO
CREATE OR ALTER PROCEDURE addForeignKeyUNDO
AS
BEGIN
	ALTER TABLE FiredEmployee
	DROP CONSTRAINT FIRED_EMPLOYEE_FOREIGN_KEY
	PRINT 'Removing the foreign key from the FiredEmployee table'
END
GO

--We need a way to find which procedure to execute(or undo), thus I created an auxiliary table
CREATE TABLE VersionTable(
	currentProcedure VARCHAR(50),
	undoProcedure VARCHAR(50),
	nextVersion INT)
INSERT INTO VersionTable VALUES('modifyType', 'modifyTypeUNDO', 1)
INSERT INTO VersionTable VALUES('addColumn', 'addColumnUNDO', 2)
INSERT INTO VersionTable VALUES('addDefaultConstraint', 'addDefaultConstraintUNDO', 3)
INSERT INTO VersionTable VALUES('addTable', 'addTableUNDO', 4)
INSERT INTO VersionTable VALUES('dropPrimaryKeyReason', 'dropPrimaryKeyReasonUNDO', 5)
INSERT INTO VersionTable VALUES('addCandidateKey', 'addCandidateKeyUNDO', 6)
INSERT INTO VersionTable VALUES('addForeignKey', 'addForeignKeyUNDO', 7)


DROP TABLE CurrentVersionState
--Here we will store the current version of our Database
CREATE TABLE CurrentVersionState
(
	currentVersion INT DEFAULT(0)
)
INSERT INTO CurrentVersionState VALUES(0) --we start at the STATE 0
GO

CREATE PROCEDURE versionChooser(@version INT)
AS
BEGIN
	--Set current version
	DECLARE @currVersion INT
	SET @currVersion = (SELECT * FROM CurrentVersionState)

	--find the maximum version available
	DECLARE @maxVersion INT
	SET @maxVersion = (SELECT max(nextVersion) FROM VersionTable)

	--Perform some checks
	IF @version > @maxVersion OR @version < 0
		BEGIN
			DECLARE @errorMsg VARCHAR(100)
			SET @errorMsg = 'Version Number must be between 0 and ' + CAST(@maxVersion AS VARCHAR(5)) + ' !'
			RAISERROR(@errorMsg, 17, 1)
			RETURN
		END
	ELSE
		IF @currVersion = @version --means we don't have anything to do
			BEGIN
				PRINT 'The version you chose is the current version of the datebase!'
				RETURN
			END
	ELSE
	--Here we know we want to parse up or down through the versions
	DECLARE @running_procedure VARCHAR(50)
		IF @currVersion < @version
			BEGIN
				--parsing downwards(ascendingly)
				WHILE @currVersion < @version
					BEGIN
						PRINT 'Current version is : ' + cast(@currVersion AS VARCHAR(5))
						SET @running_procedure = (SELECT currentProcedure FROM VersionTable WHERE nextVersion = @currVersion + 1)
						EXEC @running_procedure
						SET @currVersion = @currVersion + 1
					END
			END
	ELSE
		IF @currVersion > @version
			BEGIN
				--parsing upwards(descendingly)
				WHILE @currVersion > @version
					BEGIN
						PRINT 'Current version is : ' + cast(@currVersion AS VARCHAR(5))
						SET @running_procedure = (SELECT undoProcedure FROM VersionTable WHERE nextVersion = @currVersion)
						EXEC @running_procedure
						SET @currVersion = @currVersion - 1
					END
			END
	--Update the table for subsequent calls
	UPDATE CurrentVersionState
		SET currentVersion = @version
	PRINT 'The procedure has ended ! Version at the moment is : ' + CAST(@currVersion AS VARCHAR(5))
END
GO

select * from VersionTable

EXEC modifyTypeUNDO
EXEC addColumnUNDO
EXEC addDefaultConstraintUNDO
EXEC addTableUNDO
EXEC dropPrimaryKeyReasonUNDO
EXEC addCandidateKeyUNDO
EXEC addForeignKeyUNDO

EXEC modifyType
EXEC addColumn
EXEC addDefaultConstraint
EXEC addTable
EXEC dropPrimaryKeyReason
EXEC addCandidateKey
EXEC addForeignKey

EXEC versionChooser 6
--Version 1 : Modify type of column
--Version 2 : add/remove column
--Version 3 : add/remove DEFAULT constraint
--Version 4 : Add table
--Version 5 : drop Primary Key Constraint
--Version 6 : add a Candidate Key
--Version 7 : add a Foreign Key

SELECT * FROM CurrentVersionState
SELECT * FROM VersionTable
