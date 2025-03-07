/********************************************************************************************************************\
* Description: Check for AG status.                                        *
**********************************************************************************************************************
* Modified by             Date       Description/Features added                                                      *
* ----------------------- ---------- ------------------------------------------------------------------------------- *
* Peter Kruis             2025/03/03 Created (partially gathered from Glenn  										 *
* Peter Kruis             2025/03/05 sql 2012 compatible 										 *
*********************************************************************************************************************/

SET NOCOUNT ON;

/*Variables to work with*/
DECLARE @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;
/*TODO changes: Make sure that it only runs on the primaries*/

/*Define version*/
DECLARE
   @ProductVersion NVARCHAR(128),
   @ProductVersionMajor DECIMAL(10, 2),
   @ProductVersionMinor DECIMAL(10, 2);

SET @ProductVersion = CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128));

SELECT
   @ProductVersionMajor = SUBSTRING(
                                      @ProductVersion,
                                      1,
                                      CHARINDEX('.', @ProductVersion) + 1
                                   ),
   @ProductVersionMinor = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 2);

/*is_primary_replica is added in sql server 2014, so only then retrieve that one.*/
DECLARE @QueryToExecute nvarchar(max);

IF @ProductVersionMajor >= 12
BEGIN
	SET @QueryToExecute = N'
	SELECT @MachineName AS [Server Name], ag.name AS [AG Name], ar.replica_server_name, ar.availability_mode_desc, adc.[database_name], 
       drs.is_local, drs.is_primary_replica, drs.synchronization_state_desc, drs.is_commit_participant, 
	   drs.synchronization_health_desc, drs.recovery_lsn, drs.truncation_lsn, drs.last_sent_lsn, 
	   drs.last_sent_time, drs.last_received_lsn, drs.last_received_time, drs.last_hardened_lsn, 
	   drs.last_hardened_time, drs.last_redone_lsn, drs.last_redone_time, drs.log_send_queue_size, 
	   drs.log_send_rate, drs.redo_queue_size, drs.redo_rate, drs.filestream_send_rate, 
	   drs.end_of_log_lsn, drs.last_commit_lsn, drs.last_commit_time, drs.database_state_desc 
	FROM sys.dm_hadr_database_replica_states AS drs WITH (NOLOCK)
	INNER JOIN sys.availability_databases_cluster AS adc WITH (NOLOCK)
	ON drs.group_id = adc.group_id 
	AND drs.group_database_id = adc.group_database_id
	INNER JOIN sys.availability_groups AS ag WITH (NOLOCK)
	ON ag.group_id = drs.group_id
	INNER JOIN sys.availability_replicas AS ar WITH (NOLOCK)
	ON drs.group_id = ar.group_id 
	AND drs.replica_id = ar.replica_id
	ORDER BY ag.name, ar.replica_server_name, adc.[database_name] OPTION (RECOMPILE);
	'
END
ELSE
BEGIN
	SET @QueryToExecute = N'
	SELECT @MachineName AS [Server Name], ag.name AS [AG Name], ar.replica_server_name, ar.availability_mode_desc, adc.[database_name], 
       drs.is_local, CAST(NULL AS BIT) AS is_primary_replica, drs.synchronization_state_desc, drs.is_commit_participant, 
	   drs.synchronization_health_desc, drs.recovery_lsn, drs.truncation_lsn, drs.last_sent_lsn, 
	   drs.last_sent_time, drs.last_received_lsn, drs.last_received_time, drs.last_hardened_lsn, 
	   drs.last_hardened_time, drs.last_redone_lsn, drs.last_redone_time, drs.log_send_queue_size, 
	   drs.log_send_rate, drs.redo_queue_size, drs.redo_rate, drs.filestream_send_rate, 
	   drs.end_of_log_lsn, drs.last_commit_lsn, drs.last_commit_time, drs.database_state_desc 
	FROM sys.dm_hadr_database_replica_states AS drs WITH (NOLOCK)
	INNER JOIN sys.availability_databases_cluster AS adc WITH (NOLOCK)
	ON drs.group_id = adc.group_id 
	AND drs.group_database_id = adc.group_database_id
	INNER JOIN sys.availability_groups AS ag WITH (NOLOCK)
	ON ag.group_id = drs.group_id
	INNER JOIN sys.availability_replicas AS ar WITH (NOLOCK)
	ON drs.group_id = ar.group_id 
	AND drs.replica_id = ar.replica_id
	ORDER BY ag.name, ar.replica_server_name, adc.[database_name] OPTION (RECOMPILE);
	'
END

DECLARE @Params NVARCHAR(500) = '@MachineName SYSNAME'
EXEC sp_executesql @QueryToExecute, @Params, @MachineName;