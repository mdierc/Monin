--**********************************************************************************************************************
--* Description: Find orphaned users and users in databases.                                                           *
--*              Note: Contained SQL/NT users are recognized and hence do not show up in the result.                   *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* Vandekerkhove Christian 19/11/2024 First version.                                                                  *
--* Vandekerkhove Christian 31/01/2025 Also check for NT-groups.                                                       *
--**********************************************************************************************************************

SET NOCOUNT ON;

DECLARE @dbName sysname = N'%',
        @sql NVARCHAR(MAX),
        @CurrentDB sysname;

CREATE TABLE #tb_Results
(
    DB sysname NOT NULL,
    Username sysname NOT NULL
);


-- Cursor to iterate through all databases
DECLARE cur_Databases CURSOR FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE'
      AND name NOT IN ( 'master', 'tempdb', 'model', 'msdb' )
      AND name LIKE @dbName;

OPEN cur_Databases;
FETCH NEXT FROM cur_Databases
INTO @CurrentDB;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql
        = N'USE [' + @CurrentDB + N']; 
                SELECT ''' + @CurrentDB
          + N''' AS DatabaseName, dp.name AS OrphanedUser
                FROM sys.database_principals dp
                LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
                WHERE dp.type IN (''S'', ''U'',''G'') AND sp.sid IS NULL
				AND dp.name NOT IN (''guest'',''INFORMATION_SCHEMA'',''sys'');';
    INSERT #tb_Results
    (
        DB,
        Username
    )
    EXEC sys.sp_executesql @sql;
    FETCH NEXT FROM cur_Databases
    INTO @CurrentDB;
END;

CLOSE cur_Databases;
DEALLOCATE cur_Databases;
SELECT DB,
       Username
FROM #tb_Results
ORDER BY DB,
         Username;
DROP TABLE #tb_Results;
