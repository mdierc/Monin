/**********************************************************************************************************************
Description: Show version information.                                                                             
*******************************************************************************************************************
Modified by             Date       Description/Features added                                                      
----------------------- ---------- ------------------------------------------------------------------------------- 
PX		                2025-02-06 Created

**********************************************************************************************************************/


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
     servicename,
     process_id,
     startup_type_desc,
     status_desc,
     CAST(last_startup_time AS DATETIME) AS last_startup_time,
     service_account,
     is_clustered,
     cluster_nodename,
     [filename]
FROM sys.dm_server_services WITH (NOLOCK)
OPTION (RECOMPILE);
