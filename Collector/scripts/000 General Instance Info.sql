/*********************************************************************************************************************
* Description: Show some general information about the server.                                                       
*********************************************************************************************************************
* Modified by             Date       Description/Features added                                                      
* ----------------------- ---------- ------------------------------------------------------------------------------- 
* SQL Team                ?          First version.                                                                  
* PX					  2024-06-26 Added html part and added additional information                                                                  
*********************************************************************************************************************/

SET NOCOUNT ON;

DECLARE @MachineName NVARCHAR(128),
        @Edition NVARCHAR(128),
        @EngineEdition NVARCHAR(128),
        @InstanceName NVARCHAR(128),
        @SQLServerStartDateTime DATETIME,
        @VirtualMachine NVARCHAR(60),
        @CountDatabasesAndSize NVARCHAR(128);

SELECT @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)),
       @InstanceName = CASE
                           WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                               @@SERVICENAME
                           ELSE
                               CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                       END,
       @Edition = CAST(SERVERPROPERTY('Edition') AS NVARCHAR(128)),
       @EngineEdition = CAST(SERVERPROPERTY('EngineEdition') AS NVARCHAR(128)),
       @SQLServerStartDateTime = sqlserver_start_time,
       @VirtualMachine = virtual_machine_type_desc
FROM sys.dm_os_sys_info;


/*Define sizes*/

DECLARE @StringToExecute NVARCHAR(4000);

IF OBJECT_ID('tempdb..#MasterFiles') IS NOT NULL
    DROP TABLE #MasterFiles;
CREATE TABLE #MasterFiles
(
    database_id INT,
    file_id INT,
    type_desc NVARCHAR(50),
    name NVARCHAR(255),
    physical_name NVARCHAR(255),
    size BIGINT
);
/* Azure SQL Database doesn't have sys.master_files, so we have to build our own. */
IF (
       (SERVERPROPERTY('Edition')) = 'SQL Azure'
       AND (OBJECT_ID('sys.master_files') IS NULL)
   )
    SET @StringToExecute
        = N'INSERT INTO #MasterFiles (database_id, file_id, type_desc, name, physical_name, size) SELECT DB_ID(), file_id, type_desc, name, physical_name, size FROM sys.database_files;';
ELSE
    SET @StringToExecute
        = N'INSERT INTO #MasterFiles (database_id, file_id, type_desc, name, physical_name, size) SELECT database_id, file_id, type_desc, name, physical_name, size FROM sys.master_files;';
EXEC (@StringToExecute);

SELECT @CountDatabasesAndSize
    = CAST(COUNT(DISTINCT database_id) AS NVARCHAR(100)) + N' databases, '
      + CAST(CAST(SUM(CAST(size AS BIGINT) * 8. / 1024. / 1024.) AS MONEY) AS VARCHAR(100)) + N' GB total file size'
FROM #MasterFiles
WHERE database_id > 4;


SELECT @MachineName AS [Server Name],
       @InstanceName AS InstanceName,
       @Edition AS Edition,
       --SERVERPROPERTY('ProductVersion') AS ProductVersion,  
       --SERVERPROPERTY('ProductMajorVersion') AS ProductMajorVersion,
       --SERVERPROPERTY('ProductMinorVersion') AS ProductMinorVersion,
       --SERVERPROPERTY('ProductBuild') AS ProductBuild,
       @EngineEdition AS DatabaseEngineEdition,
       @SQLServerStartDateTime AS InstanceStartTime,
       @VirtualMachine AS VirtualMachine,
       @CountDatabasesAndSize AS CountDatabasesAndSize;

/*
TODO:

Add disk information; disk used, disk available.
Yellow when we think is critical

Add user information; what (service) user is used

Add OS + Uptime server

Add Balanced power mode; or should it be a different check -> I think this

*/