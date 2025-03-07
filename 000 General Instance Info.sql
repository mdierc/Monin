--**********************************************************************************************************************
--* Description: Show some general information about the server.                                                       *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON

SELECT  
	SERVERPROPERTY('MachineName') AS [Server Name],
	CASE 
		WHEN SERVERPROPERTY('InstanceName') IS NULL THEN @@SERVICENAME 
		ELSE SERVERPROPERTY('InstanceName') 
	END AS InstanceName, 
	SERVERPROPERTY('Edition') AS Edition,
	--SERVERPROPERTY('ProductVersion') AS ProductVersion,  
	--SERVERPROPERTY('ProductMajorVersion') AS ProductMajorVersion,
	--SERVERPROPERTY('ProductMinorVersion') AS ProductMinorVersion,
	--SERVERPROPERTY('ProductBuild') AS ProductBuild,
	SERVERPROPERTY('EngineEdition') AS DatabaseEngineEdition, 
	sqlserver_start_time AS InstanceStartTime, 
	virtual_machine_type_desc AS VirtualMachine 
FROM sys.dm_os_sys_info;