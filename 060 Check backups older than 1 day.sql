/********************************************************************************************************************\
* Description: Check for databases where the last backup > 1 day.                                                    *
**********************************************************************************************************************
* Modified by             Date       Description/Features added                                                      *
* ----------------------- ---------- ------------------------------------------------------------------------------- *
* SQL Team                ?          First version.                                                                  *
* Chris Vandekerkhove     18/11/2022 Bugfix: now using LEFT JOIN on table backupset.                                 *
* Maarten Dierckxsens     23/11/2022 Bugfix: also show db's that don't have a record in msdb.dbo.backupset           * 
*                                    Changed filter to exclude tempdb, db snapshots.                                 *
* Chris Vandekerkhove     14/03/2024 Added @NrOfDays so that you can specify more than 1 day for the age of the DB.  *
\********************************************************************************************************************/

SET NOCOUNT ON;

DECLARE @NrOfDays INT,
        @OldestAllowedDate DATETIME;

SET @NrOfDays = 1; -- Modify this value if necessary

SET @OldestAllowedDate = DATEADD(dd, -1 * @NrOfDays, GETDATE()); -- How many days old may the latest available backup be?

SELECT db.name AS [Database Name],
       db.recovery_model_desc AS [Recovery model],
       ISNULL(
       (
           SELECT DISTINCT
                  ARS.role_desc -- Replica Role
           FROM sys.availability_groups_cluster AS AGC
               INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS
                   ON RCS.group_id = AGC.group_id
               INNER JOIN sys.dm_hadr_availability_replica_states AS ARS
                   ON ARS.replica_id = RCS.replica_id
               INNER JOIN sys.availability_group_listeners AS AGL
                   ON AGL.group_id = ARS.group_id
           WHERE RCS.replica_server_name = @@SERVERNAME
       ),
       'N/A'
             ) AS [Role],
       MAX(   CASE
                  WHEN b.type = 'D' THEN
                      b.backup_finish_date
                  ELSE
                      NULL
              END
          ) AS LastFullBackup,
       MAX(   CASE
                  WHEN b.type = 'I' THEN
                      b.backup_finish_date
                  ELSE
                      NULL
              END
          ) AS LastDifferential,
       MAX(   CASE
                  WHEN b.type = 'L' THEN
                      b.backup_finish_date
                  ELSE
                      NULL
              END
          ) AS LastLog
FROM master.sys.databases db
    LEFT OUTER JOIN msdb.dbo.backupset b
        ON b.database_name = db.name
WHERE db.name <> 'tempdb'
      AND db.state NOT IN ( 1, 6, 10 ) /*1 = autoclose
       4 = select into/bulkcopy (ALTER DATABASE using SET RECOVERY)
       8 = trunc. log on chkpt (ALTER DATABASE using SET RECOVERY)
       16 = torn page detection (ALTER DATABASE)
       32 = loading
       64 = pre recovery
       128 = recovering
       256 = not recovered
       512 = offline (ALTER DATABASE)
       1024 = read only (ALTER DATABASE)
       2048 = dbo use only (ALTER DATABASE using SET RESTRICTED_USER)
       4096 = single user (ALTER DATABASE)
       32768 = emergency mode*/
      AND db.source_database_id IS NULL /* Excludes database snapshots */
      AND db.is_in_standby = 0 /* Not a log shipping target database */
--DATABASEPROPERTYEX(db.name, 'STATUS') = 'ONLINE' 
GROUP BY db.name,
         db.recovery_model_desc
HAVING (
           MAX(   CASE
                      WHEN b.type = 'D' THEN
                          b.backup_finish_date
                      ELSE
                          NULL
                  END
              ) <= @OldestAllowedDate
           AND MAX(   CASE
                          WHEN b.type = 'I' THEN
                              b.backup_finish_date
                          ELSE
                              CONVERT(DATETIME, '1900-01-01', 121)
                      END
                  ) <= @OldestAllowedDate
       )
       OR MAX(b.backup_finish_date) IS NULL
ORDER BY db.recovery_model_desc,
         db.name;
GO
