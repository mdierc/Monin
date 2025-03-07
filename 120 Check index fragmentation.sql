-- Duration at AZMM = 03:08:47
/******************************************************************************************************************************************************\
* Description:  Find indexes with > 1000 pages and a fragmentation > 50%.                                                                              *
********************************************************************************************************************************************************
* Modified by             Date       Description/Features added                                                                                        *
* ----------------------- ---------- -------------------------------------------------------------------------------                                   *
* SQL Team                ?          First version.                                                                                                    *
* Maarten Dierckxxens     23/11/2022 Syntax error invalid column name 'avg_fragmentation_in_percent'. Renamed column temp table to [Fragmentation%].   *
* Maarten Dierckxxens     23/11/2022 Added check if temp table exists to drop the temp table.                                                          *
* Chris Vandekerkhove     09/06/2023 Replaced db_id() with fixed value.                                                                                *
\******************************************************************************************************************************************************/


SET NOCOUNT ON;

DECLARE @CmdStr    VARCHAR(8000),
        @CurrentDB VARCHAR(255),
        @DBtoCheck VARCHAR(255),
		@DBid VARCHAR(10);

SET @DBtoCheck = '%';

IF OBJECT_ID('tempdb..#tb_IndexFragmentation') IS NOT NULL
BEGIN
	DROP TABLE #tb_IndexFragmentation;
END

CREATE TABLE #tb_IndexFragmentation ([Database] [NVARCHAR](128) NULL,
                                     [Schema] [sysname] NOT NULL,
                                     [Table] [sysname] NOT NULL,
                                     [Index] [sysname] NULL,
                                     [Fragmentation%] [FLOAT] NULL,
                                     [page_count] [BIGINT] NULL) ON [PRIMARY];

DECLARE curDB CURSOR FAST_FORWARD FOR
SELECT d.name,convert(varchar,d.database_id)
  FROM sys.databases d
 WHERE name NOT IN ( 'master', 'msdb', 'model', 'tempdb', 'distribution' )
   AND DATABASEPROPERTYEX(name, 'STATUS')        = 'ONLINE'
   AND DATABASEPROPERTYEX(name, 'Updateability') = 'READ_WRITE'
   AND name LIKE @DBtoCheck
 ORDER BY name;

OPEN curDB;
FETCH curDB INTO @CurrentDB,@DBid;

WHILE @@fetch_status = 0
BEGIN
    PRINT 'Checking database [' + @CurrentDB + ']';
    SET @CmdStr
        = 'USE [' + @CurrentDB + '] ' + 'SELECT ''' + @CurrentDB + ''' AS [Database],dbschemas.[name] AS [Schema],'
          + '            dbtables.[name] AS [Table],' + '            dbindexes.[name] AS [Index],'
          + '            indexstats.avg_fragmentation_in_percent,' + '            indexstats.page_count'
          + '  FROM      sys.dm_db_index_physical_stats(' + @DBid + ', NULL, NULL, NULL, NULL) AS indexstats'
          + ' INNER JOIN sys.tables dbtables' + '    ON dbtables.[object_id]  = indexstats.[object_id]'
          + ' INNER JOIN sys.schemas dbschemas' + '    ON dbtables.[schema_id]  = dbschemas.[schema_id]'
          + ' INNER JOIN sys.indexes AS dbindexes' + '    ON dbindexes.[object_id] = indexstats.[object_id]'
          + '   AND indexstats.index_id   = dbindexes.index_id' + ' WHERE      indexstats.database_id = ' + @DBid 
          + ' ORDER BY indexstats.avg_fragmentation_in_percent DESC;';
    INSERT #tb_IndexFragmentation ([Database],
                                   [Schema],
                                   [Table],
                                   [Index],
                                   [Fragmentation%],
                                   page_count)
    EXEC (@CmdStr);
    FETCH curDB INTO @CurrentDB,@DBid;
END;
CLOSE curDB;
DEALLOCATE curDB;

SELECT [Database],
       [Schema],
       [Table],
       [Index],
       [Fragmentation%],
       page_count
 FROM #tb_IndexFragmentation
 WHERE [Index] IS NOT NULL
   AND page_count                   > 1000
   AND [Fragmentation%] > 50
ORDER BY [Fragmentation%] DESC;

DROP TABLE #tb_IndexFragmentation;