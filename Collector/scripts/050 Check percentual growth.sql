/**********************************************************************************************************************
* Description: Check for databases which have devices which grow in percent instead of a fixed length.               *
**********************************************************************************************************************
* Modified by             Date       Description/Features added                                                      *
* ----------------------- ---------- ------------------------------------------------------------------------------- *
* Vandekerkhove Christian 03/01/2020 First version.                                                                  *
* Peter Kruis				06/01/2025 Added 'small growth' and additional information about the files.                    
* Peter Kruis				19/02/2025 Fixed growth definition
**********************************************************************************************************************/

SET NOCOUNT ON;

DECLARE @MachineName NVARCHAR(128);
SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

DECLARE @Execute BIT;
SET @Execute = 1;

DECLARE
   @DBname sysname,
   @logical_name sysname,
   @file_type NVARCHAR(60),
   @file_path NVARCHAR(260),
   @growth VARCHAR(10),
   @CmdStr VARCHAR(8000);

CREATE TABLE #tb_GrowthInfo
(
   dbname sysname,
   logical_name sysname,
   file_type NVARCHAR(60),
   file_path NVARCHAR(260),
   is_percent_growth BIT,
   growth INT,
   PRIMARY KEY (
                  dbname,
                  logical_name
               )
);

DECLARE curDB CURSOR FOR
   SELECT   sd.name
   FROM     sys.databases sd
   WHERE    DATABASEPROPERTYEX(sd.name, 'Status') = 'ONLINE'
            AND DATABASEPROPERTYEX(sd.name, 'Updateability') = 'READ_WRITE' -- ignore read-only DBs
   ORDER BY sd.name;
OPEN curDB;
FETCH curDB
INTO @DBname;
WHILE @@FETCH_STATUS = 0
BEGIN
   -- Size is expressed in 8Kb pages => size * 8 /1024 = size in Mb
   SET @CmdStr = 'INSERT #tb_GrowthInfo (dbname, logical_name, file_type, file_path, is_percent_growth, growth)
                  SELECT ''' + @DBname + ''', name, type_desc, physical_name, is_percent_growth, 
                         CASE WHEN is_percent_growth = 1 THEN growth ELSE growth * 8 / 1024 END
                  FROM [' + @DBname + '].sys.database_files';
   EXEC (@CmdStr);
   FETCH curDB INTO @DBname;
END;
CLOSE curDB;
DEALLOCATE curDB;

SELECT
     @MachineName AS [Server Name],
     dbname AS [Database Name],
     logical_name AS [Logical Name],
     file_type AS [File Type],
     file_path AS [Path],
     is_percent_growth AS [Is Percent Growth],
     growth AS [Growth]
FROM #tb_GrowthInfo;
DROP TABLE #tb_GrowthInfo;