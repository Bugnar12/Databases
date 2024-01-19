----- VIEW PART -----

--View no.1 : on the Operating_system table
CREATE OR ALTER VIEW view_one_table
AS
	SELECT tester_id, tester_name
	FROM OS_tester;
GO

--View no.2 : inner join between Employee and Departament tables
CREATE OR ALTER VIEW view_inner_join
AS
	SELECT t.tester_id, t.tester_name, o.os_name
	FROM OS_tester t
	JOIN Operating_system o ON t.os_id = o.os_id;
GO

--View no.3 : select + group by + join
CREATE OR ALTER VIEW view_group_by
AS
	SELECT o.os_name, COUNT(t.tester_id) AS total_testers
	FROM OS_tester t
	JOIN Operating_system o ON t.os_id = o.os_id
	GROUP BY o.os_name;
GO

---GENERATING RANDOM DATA PART---
--1.Generate random string
--2.Generate random integer

--1.
CREATE OR ALTER PROCEDURE generate_random_string(@resultString VARCHAR(18) OUTPUT) AS
BEGIN
	SELECT @resultString = CONVERT(varchar(255), NEWID())
END
GO

-- Declare a variable to store the result
DECLARE @outputString VARCHAR(30)
EXEC generate_random_string @resultString = @outputString OUTPUT
SELECT @outputString
GO

--2.
CREATE OR ALTER PROCEDURE generate_random_integer
    @lower INT,
    @upper INT,
    @resultInteger INT OUTPUT
AS
BEGIN
    -- Check if the lower limit is greater than the upper limit
    IF @lower > @upper
    BEGIN
        RAISERROR('Lower limit must be less than or equal to upper limit.', 16, 1)
        RETURN;
    END

    DECLARE @range INT = @upper - @lower + 1;

    -- Generate random integer within the specified range
    SET @resultInteger = CONVERT(INT, RAND() * @range + @lower);

    RETURN;
END;
GO

DECLARE @lowerLimit INT = 1;
DECLARE @upperLimit INT = 100;
DECLARE @outputRandom INT;
EXEC generate_random_integer @lower = @lowerLimit, @upper = @upperLimit, @resultInteger = @outputRandom OUTPUT;
SELECT @outputRandom AS RandomInteger;
GO

DROP PROCEDURE IF EXISTS getReferenceData;
GO

CREATE PROCEDURE getReferenceData (@table VARCHAR(128), @column VARCHAR(128), @referencedTable VARCHAR(128) OUTPUT, @referencedColumn VARCHAR(128) OUTPUT)
AS
BEGIN
	SELECT @referencedTable = OBJECT_NAME(FC.referenced_object_id), @referencedColumn = COL_NAME(FC.referenced_object_id, FC.referenced_column_id)
	FROM sys.foreign_keys AS F INNER JOIN sys.foreign_key_columns AS FC ON F.OBJECT_ID = FC.constraint_object_id
	WHERE OBJECT_NAME (F.parent_object_id) = @table AND COL_NAME(FC.parent_object_id, FC.parent_column_id) = @column
END
GO

DECLARE @referencedTable VARCHAR(128);
DECLARE @referencedColumn VARCHAR(128);

-- Test the procedure with the OS_tester table and os_id column
EXEC getReferenceData 'OS_tester', 'os_id', @referencedTable OUTPUT, @referencedColumn OUTPUT;

-- Display the results
PRINT 'Referenced Table: ' + @referencedTable;
PRINT 'Referenced Column: ' + @referencedColumn;
GO

--Function that checks whether a column is a primary key or not
CREATE OR ALTER FUNCTION IsColumnPrimaryKey
(
    @tableName NVARCHAR(128),
    @columnName NVARCHAR(128)
)
RETURNS BIT
AS
BEGIN
    DECLARE @isPrimaryKey BIT = 0;

    SELECT @isPrimaryKey = 1
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
        ON TC.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME
    WHERE TC.TABLE_NAME = @tableName
        AND KCU.COLUMN_NAME = @columnName
        AND TC.CONSTRAINT_TYPE = 'PRIMARY KEY';

    RETURN @isPrimaryKey;
END;
GO

-- Test the IsColumnPrimaryKey function
DECLARE @tableName NVARCHAR(128) = 'Customer';
DECLARE @columnName NVARCHAR(128) = 'customer_id';

DECLARE @isPrimaryKey BIT = dbo.IsColumnPrimaryKey(@tableName, @columnName);

IF @isPrimaryKey = 1
    PRINT 'The column is part of the primary key.';
ELSE
    PRINT 'The column is not part of the primary key.';
GO

DROP PROCEDURE IF EXISTS insertOnRow;
GO

CREATE PROCEDURE insertOnRow (@tableName VARCHAR(70)) AS
BEGIN
	--Get the columns from the table
	DECLARE @getColumnsQuery NVARCHAR(MAX) = N' 
		SELECT COLUMN_NAME, DATA_TYPE
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = ''' + @tableName + '''
	';
	--Used to actually insert the data
	DECLARE @insertQuery NVARCHAR(MAX) = N'INSERT INTO ' + @tableName;

	DECLARE @columns NVARCHAR(MAX);
	DECLARE @types NVARCHAR(MAX);
	DECLARE @rowsNumber INT = 0;

	--Extract all the columns with their respective data types and the number of rows using a Cursor
	DECLARE @cursorQuery NVARCHAR(MAX) = N'
		DECLARE @columnName NVARCHAR(MAX);
		DECLARE @dataType NVARCHAR(MAX);
		DECLARE columnsCursor CURSOR FOR ' + @getColumnsQuery + '
		OPEN columnsCursor
		FETCH columnsCursor
		INTO @columnName, @dataType;

		--check if the row exists
		IF @@FETCH_STATUS = 0
		BEGIN
			SET @columns = @columnName;
			SET @types = @dataType;
			SET @rowsNumber = 1;
		END

		--While we still have rows
		WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH columnsCursor
			INTO @columnName, @dataType;
			IF @@FETCH_STATUS = 0
			BEGIN
				SET @columns = @columns + '', '' + @columnName;
				SET @types = @types + '', '' + @dataType;
				SET @rowsNumber = @rowsNumber + 1;
			END
		END

		CLOSE columnsCursor;
		DEALLOCATE columnsCursor;	
	';

	EXEC sp_executesql @Query = @cursorQuery, @Params = N'@columns NVARCHAR(MAX) OUTPUT, @types NVARCHAR(MAX) OUTPUT, @rowsNumber INT OUTPUT', @columns = @columns OUTPUT, @types = @types OUTPUT, @rowsNumber = @rowsNumber OUTPUT
	
	SET @insertQuery = @insertQuery + '(' + @columns + ') VALUES (';

	SET @types = @types + ', ';
	SET @columns = @columns + ', ';

	DECLARE @index INT = 0;
	DECLARE @current NVARCHAR(MAX);
	DECLARE @currentColumn NVARCHAR(MAX);
	DECLARE @pkConstraint INT = 0;
	DECLARE @outputPK INT;
	DECLARE @pkQuery NVARCHAR(MAX)

	-- now we insert random data on every column
	WHILE @index < @rowsNumber
	BEGIN
		SET @current = LEFT(@types, CHARINDEX(', ', @types) - 1);
		SET @types = SUBSTRING(@types, CHARINDEX(', ', @types) + 2, LEN(@types));
		SET @currentColumn = LEFT(@columns, CHARINDEX(', ', @columns) - 1);
		SET @columns = SUBSTRING(@columns, CHARINDEX(', ', @columns) + 2, LEN(@columns));

		IF @index != 0
			SET @insertQuery = @insertQuery + ', ';

		DECLARE @referencedTable NVARCHAR(MAX) = '';
		DECLARE @referencedColumn NVARCHAR(MAX) = '';

		--If we get some data in referencedTable and referencedColumn => we have a foreign key and we must pay attention
		EXEC getReferenceData @tableName, @currentColumn, @referencedTable = @referencedTable OUTPUT, @referencedColumn = @referencedColumn OUTPUT;
	
		-- Check if the column has a primary key
		SET @pkConstraint = dbo.IsColumnPrimaryKey(@tableName, @currentColumn);

		--IF @referencedTable != ''
		--begin
		--			PRINT @referencedTable
		--end
		-- case 1: we must insert a integer
		IF @current = 'INT'
		BEGIN
			-- case 1.1: it's a foreign key => we must search in the refferenced table
			IF @referencedTable != '' AND @referencedColumn != ''
			BEGIN
				DECLARE @intValue INT;
				DECLARE @intQuery NVARCHAR(MAX) = N'
					SELECT @intValue = ' + @referencedColumn + ' FROM ' + @referencedTable;
				EXEC sp_executesql @Query = @intQuery, @Params = N'@intValue INT OUTPUT', @intValue = @intValue OUTPUT;
				SET @insertQuery = @insertQuery + CONVERT(NVARCHAR(MAX), @intValue);
			END
			ELSE
			BEGIN
				DECLARE @resultInteger INT;
				-- case 1.2: it's a primary key => we generate a random value and we must check if the value doesn't already exist
				IF @pkConstraint = 1 AND @current = 'INT'
				BEGIN
					DECLARE @maxID INT;
					DECLARE @maxIDQuery NVARCHAR(MAX) = N'
						SELECT @maxIDOUT = MAX(' + @currentColumn + ') FROM ' + @tableName;
					EXEC sp_executesql @maxIDQuery, N'@maxIDOUT INT OUTPUT', @maxID OUTPUT;

					IF @maxID IS NOT NULL
					BEGIN
						SET @insertQuery = @insertQuery + CONVERT(NVARCHAR(MAX), @maxID + 1);
					END
					ELSE
					BEGIN
						-- If there are no existing records, insert with ID = 1
						SET @insertQuery = @insertQuery + '1';
					END
				END
				-- case 1.3: it's not a foreign key or a primary key => we insert a random value
				ELSE
				BEGIN
					EXEC generate_random_integer 0, 1000, @resultInteger = @resultInteger OUTPUT;
					SET @insertQuery = @insertQuery + CONVERT(NVARCHAR(MAX), @resultInteger);
				END

			END
		END

		-- case 2: we must insert a string
		IF @current = 'VARCHAR'
		BEGIN
			-- case 2.1: it's a foreign key => we must search in the refferenced table
			--IF @referencedTable != '' AND @referencedColumn != ''
			--BEGIN
			--	DECLARE @stringValue NVARCHAR(MAX);
			--	DECLARE @stringQuery NVARCHAR(MAX) = N'
			--		SELECT @stringValue = ' + @referencedColumn + ' FROM ' + @referencedTable;
			--	EXEC sp_executesql @Query = @stringQuery, @Params = N'@stringValue INT OUTPUT', @stringValue = @stringValue OUTPUT;
			--	SET @insertQuery = @insertQuery + CONVERT(NVARCHAR(MAX), @stringValue);
			--END
			--ELSE 
			BEGIN
				DECLARE @resultString NVARCHAR(21);

				-- case 2.2: it's a primary key => get the maximum ID value and insert max(id) + 1
				IF @pkConstraint = 1
				BEGIN
					EXEC generate_random_string @resultString = @resultString OUTPUT;
					SET @pkQuery = N'SELECT @outputPK = COUNT (*) FROM ' + @tableName + ' WHERE '	+ @currentColumn + '=' + @resultString;
					EXEC sp_executesql @pkQuery, N'@outputPK VARCHAR OUTPUT', @outputPK OUTPUT;
					--PRINT @outputPK;
					IF @outputPK != NULL
					BEGIN
						WHILE @outputPK != NULL 
						BEGIN
							SET @pkQuery = N'SELECT @outputPK = COUNT (*) FROM ' + @tableName + ' WHERE '	+ @currentColumn + '=' + @resultString;
							EXEC sp_executesql @pkQuery, N'@outputPK VARCHAR OUTPUT', @outputPK OUTPUT;
						END
					END
					SET @insertQuery = @insertQuery + '''' + @resultString + '''';
				END

				-- case 2.3: it's not a foreign key or a primary key => we insert a random value
				ELSE
				BEGIN
					EXEC generate_random_string @resultString = @resultString OUTPUT;
					SET @insertQuery = @insertQuery + '''' + @resultString + '''';
				END
			END
		END

		SET @index = @index + 1;
	END

	SET @insertQuery = @insertQuery + ');';
	PRINT @insertQuery;
	EXEC sp_executesql @insertQuery;
END
GO

EXEC insertOnRow 'Operating_system'
go

select * from Operating_system
GO

CREATE OR ALTER PROCEDURE insertMultipleRows
    @tableName VARCHAR(70),
    @rowCount INT
AS
BEGIN
    DECLARE @counter INT = 0;

    WHILE @counter < @rowCount
    BEGIN
        -- Call the insertOnRow procedure to insert a single row
        EXEC insertOnRow @tableName;

        -- Increment the counter
        SET @counter = @counter + 1;
    END
END
GO


DROP PROCEDURE IF EXISTS runTest;
GO

CREATE PROCEDURE runTest (@testID INT) AS
BEGIN
	DECLARE @tests INT = 0;
	DECLARE @tableID INT = -1;
	DECLARE @viewID INT = -1;
	DECLARE @rowsNb INT = -1;
	DECLARE @runID INT = -1;
	DECLARE @testStart DATETIME = GETDATE();

	INSERT INTO TestRuns (Description, StartAt)
	VALUES ((SELECT Name FROM Tests WHERE TestID = @testID), @testStart);

	SELECT @runID = TestRunID FROM TestRuns 
	WHERE Description = (SELECT Name FROM Tests WHERE TestID = @testID) AND StartAt = @testStart;

	SELECT @tests = COUNT(*) FROM Tests
	WHERE TestID = @testID;

	IF @testID < 0
	BEGIN
		RAISERROR('Invalid test ID!', 10, 1);
		RETURN
	END

	--- Run the tests for the table ---

	DECLARE @tableName NVARCHAR(MAX);
	DECLARE @query NVARCHAR(MAX);

-- Deleting data from our table paying attention to tables that are refferenced --
	DECLARE testCursor CURSOR FOR
    SELECT TableID FROM TestTables
    WHERE TestID = @testID
    ORDER BY Position DESC;

OPEN testCursor
FETCH testCursor INTO @tableId;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @tableName = Name FROM Tables
    WHERE TableID = @tableID;

    -- Check if the table has any referencing foreign keys
    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys AS FK
        INNER JOIN sys.tables AS T ON FK.parent_object_id = T.object_id
        WHERE FK.referenced_object_id = OBJECT_ID(@tableName)
    )
    BEGIN
        -- Iterate over referencing tables and delete data
        DECLARE @referencingTableName NVARCHAR(MAX);

        DECLARE referencingCursor CURSOR FOR
        SELECT OBJECT_NAME(parent_object_id) AS ReferencingTable
        FROM sys.foreign_keys
        WHERE referenced_object_id = OBJECT_ID(@tableName);

        OPEN referencingCursor
        FETCH referencingCursor INTO @referencingTableName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @query = N'DELETE FROM ' + @referencingTableName;
            EXEC sp_executesql @query;

            FETCH referencingCursor INTO @referencingTableName;
        END

        CLOSE referencingCursor;
        DEALLOCATE referencingCursor;
    END

    -- Delete data from the current table
    SET @query = N'DELETE FROM ' + @tableName;
    EXEC sp_executesql @query;

    FETCH testCursor INTO @tableId;
END

CLOSE testCursor;
DEALLOCATE testCursor;

	--- Insertion of data in the tables ---
	
	DECLARE testCursor CURSOR FOR
	SELECT TableID, NoOfRows FROM TestTables
	WHERE TestID = @testID
	ORDER BY Position;

	OPEN testCursor
	FETCH testCursor
	INTO @tableId, @rowsNb;

	DECLARE @startInsert DATETIME;
	DECLARE @endInsert DATETIME;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @tableName = Name FROM Tables
		WHERE TableID = @tableID;

		PRINT @tableName

		SET @startInsert = GETDATE();
		EXEC insertMultipleRows @tableName, @rowsNb;
		SET @endInsert = GETDATE();

		INSERT INTO TestRunTables (TestRunID, TableID, StartAt, EndAt)
		VALUES (@runID, @tableID, @startInsert, @endInsert)

		FETCH testCursor
		INTO @tableID, @rowsNb;
	END

	CLOSE testCursor
	DEALLOCATE testCursor

	--- Perform tests for the views part---

	DECLARE @viewName NVARCHAR(MAX);

	DECLARE testCursor CURSOR FOR
	SELECT ViewID FROM TestViews
	WHERE TestID = @testID

	OPEN testCursor
	FETCH testCursor 
	INTO @viewID;

	DECLARE @startView DATETIME;
	DECLARE @endView DATETIME;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @viewName = Name FROM Views
		WHERE ViewID = @viewID;

		SET @query = 'SELECT * FROM ' + @viewName;

		SET @startView = GETDATE();
		EXEC sp_executesql @query;
		SET @endView = GETDATE();

		INSERT INTO TestRunViews (TestRunID, ViewID, StartAt, EndAt)
		VALUES (@runID, @viewID, @startView, @endView);

		FETCH testCursor
		INTO @viewID;
	END

	CLOSE testCursor;
	DEALLOCATE testCursor;

	--- Introduce TestRuns table data ---
	UPDATE TestRuns
	SET EndAt = GETDATE()
	WHERE Description = (SELECT Name FROM Tests WHERE TestID = @testID) AND StartAt = @testStart;
END 
GO


EXEC insertMultipleRows 'Customer', 5;

---Insertion into the tables + views + tests---
INSERT INTO Tables
VALUES ('Operating_system'), --This table will have no foreign keys
		('OS_Tester'), --This table will have foreign key to Operating_system
		('FiredEmployee') --This table will have a multi-column primary key
select * from Tables



INSERT INTO Views
VALUES('view_one_table'),
		('view_inner_join'),
		('view_group_by')

INSERT INTO Tests
VALUES ('test1'), ('test2'), ('test3')

SELECT * FROM Tables
SELECT * FROM Tests
select * from Views

INSERT INTO TestTables(TableID, TestID, NoOfRows, Position)--takes table id and test id
VALUES (1, 1, 20, 2), (2, 2, 100, 2), (3, 3, 40, 1)
 
INSERT INTO TestTables(TableID, TestID, NoOfRows, Position)--takes table id and test id
VALUES(2, 1, 400, 2), (1, 3, 250, 1), (3, 2, 150, 3)

INSERT INTO TestTables(TableID, TestID, NoOfRows, Position)
VALUES(3, 1, 150, 3), (2, 3, 300, 2), (1, 2, 200, 3)

DELETE FROM TestTables

INSERT INTO [TestViews]([TestID], [ViewID])
VALUES
	(1,1),
	(1,2),
	(1,3),
	(2,1),
	(2,2),
	(2,3),
	(3,1),
	(3,2),
	(3,3)
GO


EXEC runTest 3
SELECT * FROM Operating_system
SELECT * FROM OS_tester
SELECT * FROM FiredEmployee

DELETE FROM TestViews
DELETE FROM TestTables
DELETE FROM TestViews
DELETE FROM Tables
DELETE FROM Tests
DELETE FROM Views

SELECT * FROM Tables
SELECT * FROM Tests
SELECT * FROM Views
SELECT * FROM TestTables
SELECT * FROM TestRuns
SELECT * FROM TestViews
SELECT * FROM TestRunViews
SELECT * FROM TestRunTables
