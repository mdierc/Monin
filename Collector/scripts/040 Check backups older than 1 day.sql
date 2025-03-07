/********************************************************************************************************************\
* Description: Check for database backup and checkdb information                                                    *
**********************************************************************************************************************
* Modified by             Date       Description/Features added                                                      *
* ----------------------- ---------- ------------------------------------------------------------------------------- *
* SQL Team                ?          First version.                                                                  *
* Chris Vandekerkhove     18/11/2022 Bugfix: now using LEFT JOIN on table backupset.                                 *
* Maarten Dierckxsens     23/11/2022 Bugfix: also show db's that don't have a record in msdb.dbo.backupset           * 
*                                    Changed filter to exclude tempdb, db snapshots
* Peter Kruis			  06/01/2025 Added additional columns for automate HC. Doubt on working of Always-On Role, as the server can have multiple*
* Peter Kruis			  06/02/2025 Fixed Always-On role definition
\********************************************************************************************************************/

SET NOCOUNT ON;

DECLARE @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

SELECT
         @MachineName AS [Server Name],
         ISNULL(d.[name], bs.[database_name]) AS [Database Name],
         d.recovery_model_desc AS [Recovery Model],
         (
            SELECT CASE WHEN drs.is_primary_replica = 1 THEN 'PRIMARY' ELSE 'SECONDARY' END
            FROM   sys.dm_hadr_database_replica_states AS drs WITH (NOLOCK)
                   INNER JOIN sys.availability_databases_cluster AS adc WITH (NOLOCK) ON drs.group_id = adc.group_id
                                                                                         AND drs.group_database_id = adc.group_database_id
                   INNER JOIN sys.availability_groups AS ag WITH (NOLOCK) ON ag.group_id = drs.group_id
                   INNER JOIN sys.availability_replicas AS ar WITH (NOLOCK) ON drs.group_id = ar.group_id
                                                                               AND drs.replica_id = ar.replica_id
			WHERE ar.replica_server_name = @@SERVERNAME
				AND adc.database_name = d.[name]
         ) AS AlwaysOnRole, /*NULL als niet in AG*/
         d.log_reuse_wait_desc AS [Log Reuse Wait Desc],
         MAX(  CASE WHEN bs.[type] = 'D' THEN bs.backup_finish_date
                    ELSE NULL
               END
            ) AS [Last Full Backup],
         MAX(  CASE WHEN bs.[type] = 'I' THEN bs.backup_finish_date
                    ELSE NULL
               END
            ) AS [Last Differential Backup],
         MAX(  CASE WHEN bs.[type] = 'L' THEN bs.backup_finish_date
                    ELSE NULL
               END
            ) AS [Last Log Backup],
         CONVERT(DECIMAL(18, 2), ds.cntr_value / 1024.0) AS [Total Data File Size on Disk (MB)],
         CONVERT(DECIMAL(18, 2), ls.cntr_value / 1024.0) AS [Total Log File Size on Disk (MB)],
         CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT) AS DECIMAL(18, 2))
         * 100 AS [Log Used %],
         MAX(  CASE WHEN bs.[type] = 'D' THEN
                       CONVERT(BIGINT, bs.compressed_backup_size / 1048576)
                    ELSE NULL
               END
            ) AS [Last Full Compressed Backup Size (MB)],
         MAX(  CASE WHEN bs.[type] = 'D' THEN
                       CONVERT(
                                 DECIMAL(18, 2),
                                 bs.backup_size / bs.compressed_backup_size
                              )
                    ELSE NULL
               END
            ) AS [Backup Compression Ratio],
         CAST(ISNULL(DATABASEPROPERTYEX((d.[name]), 'LastGoodCheckDbTime'), '1900-01-01') AS DATETIME) AS [Last Good CheckDB]
FROM     sys.databases AS d WITH (NOLOCK)
         INNER JOIN sys.master_files AS mf WITH (NOLOCK) ON d.database_id = mf.database_id
         LEFT OUTER JOIN msdb.dbo.backupset AS bs WITH (NOLOCK) ON bs.[database_name] = d.[name]
                                                                   AND bs.backup_finish_date > GETDATE()
                                                                                               - 30
         LEFT OUTER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK) ON d.name = lu.instance_name
                                                                               AND lu.counter_name LIKE N'Log File(s) Used Size (KB)%'
         LEFT OUTER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK) ON d.name = ls.instance_name
                                                                               AND ls.cntr_value > 0
                                                                               AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
         INNER JOIN sys.dm_os_performance_counters AS ds WITH (NOLOCK) ON d.name = ds.instance_name
WHERE    d.name <> N'tempdb'
         AND ds.counter_name LIKE N'Data File(s) Size (KB)%'
         AND d.state NOT IN ( 1, 6, 10 ) /* Not currently offline or restoring, like log shipping databases */
         AND d.source_database_id IS NULL /* Excludes database snapshots */
         AND d.is_in_standby = 0 /* Not a log shipping target database */
GROUP BY ISNULL(d.[name], bs.[database_name]),
         d.recovery_model_desc,
         d.log_reuse_wait_desc,
         d.[name],
         CONVERT(DECIMAL(18, 2), ds.cntr_value / 1024.0),
         CONVERT(DECIMAL(18, 2), ls.cntr_value / 1024.0),
         CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT) AS DECIMAL(18, 2))
         * 100
ORDER BY d.[name]
OPTION (RECOMPILE);
