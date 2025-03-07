--**********************************************************************************************************************
--* Description: Check for databases where the last integrity check is older than @NumDaysAgo.                         *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* Eddy Van Heghe          21/11/2014 First version.                                                                  *
--* Vandekerkhove Christian 16/07/2020 Only checks databases that are online.                                          *
--* Vandekerkhove Christian 12/07/2024 Also show creation date of the database.                                        *
--* Christophe Platteeuw    31/01/2025 Added CheckScript in the output results                                         *
--**********************************************************************************************************************

SET NOCOUNT ON;

DECLARE @NumDaysAgo INT = 7;
DECLARE @DBname VARCHAR(255);

SET @DBname = '%';

SET NOCOUNT ON;
DECLARE @CmdStr    VARCHAR(8000),
        @CurrentDB VARCHAR(255);

CREATE TABLE #tempCheck (Id INT IDENTITY(1, 1),
                         ParentObject VARCHAR(255),
                         [Object] VARCHAR(255),
                         Field VARCHAR(255),
                         [Value] VARCHAR(255));

DECLARE curDB CURSOR FAST_FORWARD FOR
SELECT name
  FROM sys.databases
 WHERE DATABASEPROPERTYEX(name, 'STATUS') = 'ONLINE'
   AND name LIKE @DBname
 ORDER BY name;

OPEN curDB;
FETCH curDB
 INTO @CurrentDB;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @CmdStr = 'DBCC DBINFO ( ''' + @CurrentDB + ''') WITH TABLERESULTS';
    INSERT INTO #tempCheck (ParentObject,
                            Object,
                            Field,
                            Value)
    EXEC (@CmdStr);
    FETCH curDB
     INTO @CurrentDB;
END;
CLOSE curDB;
DEALLOCATE curDB;


WITH CHECKDB1
  AS (SELECT [Value],
             ROW_NUMBER() OVER (ORDER BY Id) AS rn1
        FROM #tempCheck
       WHERE Field IN ( 'dbi_dbname' )),
     CHECKDB2
  AS (SELECT [Value],
             ROW_NUMBER() OVER (ORDER BY Id) AS rn2
        FROM #tempCheck
       WHERE Field IN ( 'dbi_dbccLastKnownGood' ))
-- return the results
SELECT      CHECKDB1.Value AS [Database],
            db.create_date AS [Creation date],
            CHECKDB2.Value AS [Last run date],
            CASE
                 WHEN CHECKDB2.Value = '1900-01-01 00:00:00.000' THEN 'NEVER RAN'
                 ELSE CAST(DATEDIFF(d, CHECKDB2.Value, GETDATE()) AS VARCHAR) + ' Days ago' END AS [#Days],
				 'USE [master]; DBCC CHECKDB('''+CHECKDB1.Value+''');' AS CheckScript
  FROM      CHECKDB1
 INNER JOIN CHECKDB2
    ON rn1     = rn2
  JOIN      sys.databases db
    ON db.name = CHECKDB1.Value
 WHERE      CHECKDB1.Value <> 'tempdb'
   AND      CHECKDB2.Value      <= DATEADD(d, -@NumDaysAgo, GETDATE());
DROP TABLE #tempCheck;
