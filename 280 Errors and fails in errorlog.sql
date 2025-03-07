--**********************************************************************************************************************
--* Description: Show recent errors in the error log.                                                                  *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--* Christophe Platteeuw	2025-01-22 Added test if temptables exist before creation and drop them                    *
--* Christophe Platteeuw	2025-01-22 Sorted the WHERE clause entries and made them uniform (LIKE style)              *
--**********************************************************************************************************************

SET NOCOUNT ON

-- drop existing tables by checking existance in the sysobjects (sys.tables doesn't work on SQL2012)
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE name LIKE '%#Tb_Errorlog%') DROP TABLE #Tb_Errorlog;
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '%#Tb_EnumErrorLogs%') DROP TABLE #Tb_EnumErrorLogs;
GO

DECLARE @MaxLogsToRead INT = 1;

CREATE TABLE #Tb_EnumErrorLogs (

	ArchiveNr INT PRIMARY KEY,
	Date DATETIME,
	LogFileSizeByte BIGINT

);

CREATE TABLE #Tb_Errorlog (

	LogDate DATETIME,
	ProcessInfo VARCHAR(64),
	Description VARCHAR(MAX)

);

CREATE CLUSTERED INDEX IX_LogDate ON #Tb_Errorlog (LogDate DESC);

DECLARE @ArchiveNr INT;

INSERT #Tb_EnumErrorLogs
EXEC sys.sp_enumerrorlogs 1;

DECLARE curErrorLogs CURSOR FAST_FORWARD FOR

	SELECT ArchiveNr
	FROM #Tb_EnumErrorLogs
	ORDER BY ArchiveNr;

OPEN curErrorLogs;
FETCH curErrorLogs INTO @ArchiveNr;

WHILE @@FETCH_STATUS = 0

BEGIN

	INSERT #Tb_Errorlog
	EXEC xp_readerrorlog @ArchiveNr, 1;
	FETCH curErrorLogs INTO @ArchiveNr;
	IF @ArchiveNr > @MaxLogsToRead BREAK;

END;

CLOSE curErrorLogs;
DEALLOCATE curErrorLogs;

DELETE FROM #Tb_Errorlog
WHERE Description LIKE 'Attempting to cycle error log.%'
OR Description LIKE 'BACKUP DATABASE successfully%'
OR Description LIKE 'CHECKDB for database%inished without errors%'
OR Description LIKE 'Database backed up%'
OR Description LIKE 'DBCC CHECKDB%found 0 errors%'
OR Description LIKE 'Error: 983, Severity: 14, State: 1.%'
OR Description LIKE 'Error: 976, Severity: 14, State: 1.%'
OR Description LIKE 'Error: 17054, Severity: 16, State: 1.%'
OR Description LIKE 'Error: 18456%'
OR Description LIKE 'Error: 35262, Severity: 17, State: 1.%'
OR Description LIKE 'Error: 35278, Severity: 17, State: 1.%'
OR Description LIKE 'Error: 41089, Severity: 16, State: 0.%'
OR Description LIKE 'Error: 41145, Severity: 16, State: 1.%'
OR Description LIKE 'Always On: The local replica of availability group%'
OR Description LIKE 'Always On: The availability replica manager is going offline because the local Windows Server Failover Clustering (WSFC) node has lost quorum. This is an informational message only. No user action is required.%'
OR Description LIKE 'AlwaysOn: The local replica of availability group%is going offline because the corresponding resource in the Windows Server Failover Clustering (WSFC) cluster is no longer online. This is an informational message only. No user action is required.'
OR Description LIKE 'AlwaysOn Availability Groups: Local Windows Server Failover Clustering node is online. This is an informational message only. No user action is required.'
OR Description LIKE 'Always On Availability Groups: Local Windows Server Failover Clustering node started. This is an informational message only. No user action is required.%'
OR Description LIKE 'Always On Availability Groups: Local Windows Server Failover Clustering node is no longer online. This is an informational message only. No user action is required.%'
OR Description LIKE 'Always On Availability Groups: Local Windows Server Failover Clustering node is online. This is an informational message only. No user action is required.%'
OR Description LIKE 'Always On Availability Groups: Local Windows Server Failover Clustering service started. This is an informational message only. No user action is required.%'
OR Description LIKE 'Always On Availability Groups: Waiting for local Windows Server Failover Clustering service to start. This is an informational message only. No user action is required.%'
OR Description LIKE 'Always On Availability Groups: Waiting for local Windows Server Failover Clustering node to start. This is an informational message only. No user action is required.%'
OR Description LIKE 'Always On Availability Groups: Waiting for local Windows Server Failover Clustering node to come online. This is an informational message only. No user action is required.%'
OR Description LIKE 'I/O is frozen on database%'
OR Description LIKE 'I/O was resumed on database%'
OR Description LIKE 'Log was backed up%'
OR Description LIKE 'Logging SQL Server messages in file%'
OR Description LIKE 'Registry startup parameters%'
OR Description LIKE 'Server is listening on%'
OR Description LIKE 'SQL Server is now ready for client connections%'
OR Description LIKE 'System Manufacturer:%'
OR Description LIKE 'The error log has been reinitialized.%'
OR Description LIKE 'The availability group database%is changing roles%'
OR Description LIKE 'The state of the local availability replica in availability group%'
OR Description LIKE 'The Service Broker endpoint is in disabled or stopped state.%'
OR Description LIKE 'This instance of SQL Server has been using a process ID of%'

SELECT DISTINCT 
CONVERT(VARCHAR, [LogDate], 103) AS [LogDate],
ProcessInfo,
Description
FROM #Tb_Errorlog
WHERE Description LIKE '%error%'
OR Description LIKE '%fail%'
ORDER BY LogDate DESC;

DROP TABLE #Tb_Errorlog;
DROP TABLE #Tb_EnumErrorLogs;

-- EXEC sys.sp_enumerrorlogs 1
-- EXEC xp_readerrorlog 3,2 -> sql server agent
-- Logdate, ErrorLevel, Text