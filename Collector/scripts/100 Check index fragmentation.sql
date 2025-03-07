/******************************************************************************************************************************************************\
* Description:  Find indexes with > 1000 pages and a fragmentation > 50%.                                                                              *
********************************************************************************************************************************************************
* Modified by             Date       Description/Features added                                                                                        *
* ----------------------- ---------- -------------------------------------------------------------------------------                                   *
* SQL Team                ?          First version.                                                                                                    *
* Maarten Dierckxxens     23/11/2022 Syntax error invalid column name 'avg_fragmentation_in_percent'. Renamed column temp table to [Fragmentation%].   *
* Maarten Dierckxxens     23/11/2022 Added check if temp table exists to drop the temp table.                                                          *
\******************************************************************************************************************************************************/


SET NOCOUNT ON;

DECLARE @MachineName NVARCHAR(128), @ServiceName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

DECLARE
   @CmdStr VARCHAR(8000),
   @CurrentDB VARCHAR(255),
   @DBtoCheck VARCHAR(255);

SET @DBtoCheck = '%';

IF OBJECT_ID('tempdb..#tb_IndexFragmentation') IS NOT NULL
BEGIN
   DROP TABLE #tb_IndexFragmentation;
END;

CREATE TABLE #tb_IndexFragmentation
(
   [Database] [NVARCHAR](128) NULL,
   [Schema] [sysname] NOT NULL,
   [Table] [sysname] NOT NULL,
   [Index] [sysname] NULL,
   [Fragmentation%] [FLOAT] NULL,
   [page_count] [BIGINT] NULL
) ON [PRIMARY];

DECLARE curDB CURSOR FAST_FORWARD FOR
   SELECT   name
   FROM     sys.databases
   WHERE    name NOT IN ( 'master', 'msdb', 'model', 'tempdb', 'distribution' )
            AND DATABASEPROPERTYEX(name, 'STATUS') = 'ONLINE'
            AND DATABASEPROPERTYEX(name, 'Updateability') = 'READ_WRITE'
            AND name LIKE @DBtoCheck
   ORDER BY name;

OPEN curDB;
FETCH curDB
INTO @CurrentDB;

WHILE @@FETCH_STATUS = 0
BEGIN
   PRINT 'Checking database [' + @CurrentDB + ']';
   SET @CmdStr = 'USE [' + @CurrentDB + '] ' + 'SELECT ''' + @CurrentDB
                 + ''' AS [Database],dbschemas.[name] AS [Schema],'
                 + '            dbtables.[name] AS [Table],'
                 + '            dbindexes.[name] AS [Index],'
                 + '            indexstats.avg_fragmentation_in_percent,'
                 + '            indexstats.page_count'
                 + '  FROM      sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, ''LIMITED'') AS indexstats'
                 + ' INNER JOIN sys.tables dbtables'
                 + '    ON dbtables.[object_id]  = indexstats.[object_id]'
                 + ' INNER JOIN sys.schemas dbschemas'
                 + '    ON dbtables.[schema_id]  = dbschemas.[schema_id]'
                 + ' INNER JOIN sys.indexes AS dbindexes'
                 + '    ON dbindexes.[object_id] = indexstats.[object_id]'
                 + '   AND indexstats.index_id   = dbindexes.index_id'
                 + ' WHERE      indexstats.database_id = DB_ID()'
                 + ' ORDER BY indexstats.avg_fragmentation_in_percent DESC;';
   INSERT #tb_IndexFragmentation
   (
      [Database],
      [Schema],
      [Table],
      [Index],
      [Fragmentation%],
      page_count
   )
   EXEC (@CmdStr);
   FETCH curDB
   INTO @CurrentDB;
END;
CLOSE curDB;
DEALLOCATE curDB;

SELECT
         @MachineName AS [Server Name],
         [Database] AS [Database Name],
         [Schema],
         [Table],
         [Index],
         [Fragmentation%],
         page_count
FROM     #tb_IndexFragmentation
WHERE    [Index] IS NOT NULL
         AND page_count > 1000
         AND [Fragmentation%] > 50
ORDER BY [Fragmentation%] DESC;

DROP TABLE #tb_IndexFragmentation;