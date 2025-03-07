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

WITH TempdbDataFile
  AS (SELECT size,
             max_size,
             growth,
             is_percent_growth,
             AVG(CAST(size AS DECIMAL(18, 4))) OVER () AS AvgSize,
             AVG(CAST(max_size AS DECIMAL(18, 4))) OVER () AS AvgMaxSize,
             AVG(CAST(growth AS DECIMAL(18, 4))) OVER () AS AvgGrowth
        FROM tempdb.sys.database_files
       WHERE type_desc  = 'ROWS'
         AND state_desc = 'ONLINE')
SELECT 
       (SELECT cpu_count FROM sys.dm_os_sys_info) AS [#CPUs],
       COUNT(*) AS [#Files],
       (   SELECT CASE
                       WHEN cpu_count <= 8 THEN cpu_count
                       ELSE 8 END
             FROM sys.dm_os_sys_info) AS [Suggested #Files],
       CASE SUM(CASE size
                     WHEN AvgSize THEN 1
                     ELSE 0 END)
            WHEN COUNT(1) THEN 'YES'
            ELSE 'NO' END AS EqualSize,
       CASE SUM(CASE max_size
                     WHEN AvgMaxSize THEN 1
                     ELSE 0 END)
            WHEN COUNT(1) THEN 'YES'
            ELSE 'NO' END AS EqualMaxSize,
       CASE SUM(CASE growth
                     WHEN AvgGrowth THEN 1
                     ELSE 0 END)
            WHEN COUNT(1) THEN 'YES'
            ELSE 'NO' END AS EqualGrowth
  FROM TempdbDataFile;