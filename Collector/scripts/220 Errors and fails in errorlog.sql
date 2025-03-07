--**********************************************************************************************************************
--* Description: Show recent errors in the error log.                                                                  *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON;


DECLARE @MaxLogsToRead INT = 3;
CREATE TABLE #Tb_EnumErrorLogs
(
   ArchiveNr INT PRIMARY KEY,
   Date DATETIME,
   LogFileSizeByte BIGINT
);

CREATE TABLE #tb_Errorlog
(
   LogDate DATETIME,
   ProcessInfo VARCHAR(64),
   Description VARCHAR(MAX)
);
CREATE CLUSTERED INDEX IX_LogDate
   ON #tb_Errorlog (LogDate DESC);
DECLARE @ArchiveNr INT;

INSERT #Tb_EnumErrorLogs
EXEC sys.sp_enumerrorlogs 1;


DECLARE curErrorLogs CURSOR FAST_FORWARD FOR
   SELECT   ArchiveNr
   FROM     #Tb_EnumErrorLogs
   ORDER BY ArchiveNr;
OPEN curErrorLogs;
FETCH curErrorLogs
INTO @ArchiveNr;
WHILE @@FETCH_STATUS = 0
BEGIN
   INSERT #tb_Errorlog
   EXEC xp_readerrorlog
      @ArchiveNr,
      1;
   FETCH curErrorLogs
   INTO @ArchiveNr;
   IF @ArchiveNr > @MaxLogsToRead
      BREAK;
END;
CLOSE curErrorLogs;
DEALLOCATE curErrorLogs;

DELETE FROM #tb_Errorlog
WHERE Description LIKE 'DBCC CHECKDB%found 0 errors%'
      OR Description LIKE 'The availability group database%is changing roles%'
      OR Description LIKE 'The state of the local availability replica in availability group%'
      OR Description LIKE 'Always On: The local replica of availability group%'
      OR Description LIKE 'CHECKDB for database%inished without errors%'
      OR Description = 'Error: 41145, Severity: 16, State: 1.'
      OR Description LIKE 'Error: 18456%'
      OR Description = 'Always On Availability Groups: Local Windows Server Failover Clustering node is online. This is an informational message only. No user action is required.'
      OR Description = 'Always On Availability Groups: Waiting for local Windows Server Failover Clustering service to start. This is an informational message only. No user action is required.'
      OR Description = 'Always On Availability Groups: Local Windows Server Failover Clustering service started. This is an informational message only. No user action is required.'
      OR Description = 'Always On Availability Groups: Waiting for local Windows Server Failover Clustering node to start. This is an informational message only. No user action is required.'
      OR Description = 'Always On Availability Groups: Local Windows Server Failover Clustering node started. This is an informational message only. No user action is required.'
      OR Description = 'Always On Availability Groups: Waiting for local Windows Server Failover Clustering node to come online. This is an informational message only. No user action is required.'
      OR Description LIKE 'Logging SQL Server messages in file%'
      OR Description LIKE 'Registry startup parameters%'
      OR Description = 'Always On Availability Groups: Local Windows Server Failover Clustering node is no longer online. This is an informational message only. No user action is required.'
      OR Description = 'Always On: The availability replica manager is going offline because the local Windows Server Failover Clustering (WSFC) node has lost quorum. This is an informational message only. No user action is required.'
      OR Description IN ( 'Error: 41089, Severity: 16, State: 0.',
                          'Error: 976, Severity: 14, State: 1.',
                          'Error: 17054, Severity: 16, State: 1.'
                        )
      OR Description LIKE 'AlwaysOn: The local replica of availability group%is going offline because the corresponding resource in the Windows Server Failover Clustering (WSFC) cluster is no longer online. This is an informational message only. No user action is required.'
      OR Description LIKE 'AlwaysOn Availability Groups: Local Windows Server Failover Clustering node is online. This is an informational message only. No user action is required.'
      OR Description = 'Error: 35262, Severity: 17, State: 1.'
      OR Description = 'Error: 983, Severity: 14, State: 1.'
      OR Description = 'Error: 35278, Severity: 17, State: 1.'
      OR Description LIKE 'The error log has been reinitialized.%'
      OR Description LIKE 'Attempting to cycle error log.%';


DECLARE
   @MachineName NVARCHAR(128),
   @ServiceName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

SELECT   DISTINCT
         @MachineName AS [Server Name],
         [LogDate],
         ProcessInfo,
         Description
FROM     #tb_Errorlog
WHERE    (
            Description LIKE '%error%'
            OR Description LIKE '%fail%'
         )
         AND LogDate >= '2024-12-18' --date of last HC
ORDER BY LogDate DESC;

DROP TABLE #tb_Errorlog;
DROP TABLE #Tb_EnumErrorLogs;
-- EXEC sys.sp_enumerrorlogs 1
-- EXEC xp_readerrorlog 3,2 -> sql server agent
-- Logdate, ErrorLevel, Text