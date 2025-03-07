/*************************************************************************************************************************\
* Description: Check the number of datafiles for TempDB.                                                                  *
***************************************************************************************************************************
* Modified by             Date       Description/Features added                                                           *
* ----------------------- ---------- ------------------------------------------------------------------------------------ *
* SQL Team                ?          First version.                                                                       *
* Chris Vandekerkhove     18/11/2022 Changed the headings of some columns.                                                *
* Chris Vandekerkhove     18/11/2022 Removed the column "NoFilesWithPercentGrowth".                                       *
* Chris Vandekerkhove     18/11/2022 Removed the column "MultipleDataFiles".                                              *
* Maarten Dierckxsens     23/11/2022 Fixed syntax error. Added semicolon after statement SET NOCOUNT ON.                  *
\*************************************************************************************************************************/

SET NOCOUNT ON;

DECLARE @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

WITH TempdbDataFile
AS (SELECT
          size,
          max_size,
          growth,
          is_percent_growth,
          AVG(CAST(size AS DECIMAL(18, 4))) OVER () AS AvgSize,
          AVG(CAST(max_size AS DECIMAL(18, 4))) OVER () AS AvgMaxSize,
          AVG(CAST(growth AS DECIMAL(18, 4))) OVER () AS AvgGrowth
    FROM  tempdb.sys.database_files
    WHERE type_desc = 'ROWS'
          AND state_desc = 'ONLINE')
SELECT
     @MachineName AS [Server Name],
     (
        SELECT cpu_count
        FROM   sys.dm_os_sys_info
     ) AS [NumberOfCPUs],
     COUNT(*) AS [NumberOfFiles],
     (
        SELECT CASE WHEN cpu_count <= 8 THEN cpu_count
                    ELSE 8
               END
        FROM   sys.dm_os_sys_info
     ) AS [SuggestedNumberOfFiles],
     CASE SUM(  CASE size
                     WHEN AvgSize THEN 1
                     ELSE 0
                END
             )
          WHEN COUNT(1) THEN 'YES'
          ELSE 'NO'
     END AS FilesEqualSize,
     CASE SUM(  CASE max_size
                     WHEN AvgMaxSize THEN 1
                     ELSE 0
                END
             )
          WHEN COUNT(1) THEN 'YES'
          ELSE 'NO'
     END AS FilesEqualMaxSize,
     CASE SUM(  CASE growth
                     WHEN AvgGrowth THEN 1
                     ELSE 0
                END
             )
          WHEN COUNT(1) THEN 'YES'
          ELSE 'NO'
     END AS FilesEqualGrowth
FROM TempdbDataFile;