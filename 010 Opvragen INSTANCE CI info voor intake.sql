/*
OPVRAGEN INSTANCE CI INFO VOOR INTAKE

--> voer uit op elke SQL Server instance en copy/paste output naar 'Database' Tab in de Intake Excel 
--> één lijn per SQL Server instance

*/
SELECT CASE
           WHEN SERVERPROPERTY('IsClustered') = 1 THEN
               @@SERVERNAME
           ELSE
               CONVERT([NVARCHAR](100), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) + '\'
	        + COALESCE(CONVERT([NVARCHAR](100), SERVERPROPERTY('InstanceName')), 'MSSQLSERVER')
       END AS [Title],
       'SQL Server Instance voor: ' AS [Description],
       CONVERT([NVARCHAR](100), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) AS [Server Name],
	   'MS SQL Instance' AS [Role],
       ISNULL( ( SELECT TOP 1 ISNULL(local_net_address + ':' + CAST(local_tcp_port AS VARCHAR(10)), client_net_address) AS IPAddress
                 FROM sys.dm_exec_connections
                 WHERE local_net_address IS NOT NULL ), '127.0.0.1' ) AS IPaddress,
       CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) AS [Version],
       NULL AS [Vendor Support ID],
       CAST(SERVERPROPERTY('Edition') AS VARCHAR(30)) AS [Type],
       ''  AS [Status],
	   CAST(SERVERPROPERTY('Edition') AS VARCHAR(30)) + ' - '
        + CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) + ' - '
        + CAST(SERVERPROPERTY('ProductLevel') AS VARCHAR(20)) AS [Runtime Environment] ,

	--   ''  AS [Runtime Environment],
       '' AS [Maintenance Window],
       '' AS [Maintenance Plans],
       CASE
           WHEN mirroring_state_desc IS NULL THEN
               'NO'
           ELSE
               'YES'
       END AS [Is Mirorred],
       'YES' AS [In/Out Scope],
       CASE
           WHEN @@ServerName LIKE '%tst%' THEN
               'Test'
           WHEN @@ServerName LIKE '%test%' THEN
               'Test'
           WHEN @@ServerName LIKE '%ACCEPTATION%' THEN
               'ACCEPTATION'
           WHEN @@ServerName LIKE '%ACC%' THEN
               'ACCEPTATION'
           WHEN @@ServerName LIKE '%Dev%' THEN
               'Development'
           WHEN CAST(SERVERPROPERTY('Edition') AS VARCHAR(20)) LIKE '%dev%' THEN
               'Development'
           WHEN CAST(SERVERPROPERTY('Edition') AS VARCHAR(20)) LIKE '%Enterprise%' THEN
               'Production'
           ELSE
               'Production'
       END AS [Environment],
       ISNULL(
                 CAST(ConnectionProperty('net_transport') AS varchar(20)) + ' ON ['
                 + CAST(ConnectionProperty('local_net_address') AS varchar(20)) + ']:'
                 + CAST(ConnectionProperty('local_tcp_port') AS varchar(10)) + +' - Protocol Type:'
                 + CAST(ConnectionProperty('protocol_type') AS varchar(20)),
                 'Shared Memory'
             ) AS [Connection Type],
       CASE
           WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') = 1 THEN
               'Integrated security (Windows Authentication)'
           ELSE
               'Both Windows Authentication and SQL Server Authentication'
       END AS [Connection String],
       CASE
           WHEN SERVERPROPERTY('IsClustered') = 1 THEN
               'YES'
           ELSE
               'NO'
       END AS [Clustered],
       '' AS [Backup Type],
       '' AS [Backup Engine]
FROM sys.databases db
    LEFT OUTER JOIN sys.database_mirroring dbm
        ON db.database_id = dbm.database_id
    LEFT OUTER JOIN
    (
        SELECT T1.name AS DatabaseName,
               COALESCE(CONVERT(VARCHAR(12), MAX(T2.backup_finish_date), 101), 'None') AS LastBackUpTaken,
               COALESCE(CONVERT(VARCHAR(12), MAX(T2.user_name), 101), 'NA') AS UserName
        FROM sys.sysdatabases T1
            LEFT OUTER JOIN msdb.dbo.backupset T2
                ON T2.database_name = T1.name
        GROUP BY T1.name
    ) AS backups
        ON backups.DatabaseName = db.name
WHERE db.name = 'master';

