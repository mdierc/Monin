/******************************************************************************************************************
Description: If lock pages in memory is enabled, the value will be greater than 0.                                 
*******************************************************************************************************************
Modified by             Date       Description/Features added                                                      
----------------------- ---------- ------------------------------------------------------------------------------- 
SQL Team                ?          First version.                                                                  
PX		                2024-06-25 Also added Enabled and checks if error 17890 exists in the errorlog                                                                  
*******************************************************************************************************************/

SET NOCOUNT ON;

/*check if error 17890 is written in the errorlog, this will indicate LPIM can be an improvement as the server suffers from memory paging issues*/
DECLARE @Error17890WrittenInErrorLog BIT = 0;
DECLARE @MultipleInstancesInstalled BIT = 0;
BEGIN TRY
   DECLARE @ErrorLogTable TABLE
   (
      LogDate DATETIME,
      ProcessInfo NVARCHAR(255),
      Text NVARCHAR(MAX)
   );

   -- Insert the error log entries into the table variable
   INSERT INTO @ErrorLogTable
   EXEC sp_readerrorlog
      0,
      1,
      '17890';

   -- Check if the error 17890 exists in the log table
   IF EXISTS (
                SELECT 1
                FROM   @ErrorLogTable
                WHERE  Text LIKE '%17890%'
             )
   BEGIN
      SET @Error17890WrittenInErrorLog = 1;
   END;
   ELSE
   BEGIN
      SET @Error17890WrittenInErrorLog = 0;
   END;

   IF OBJECT_ID('tempdb..#Instances') IS NOT NULL
      DROP TABLE #Instances;
   CREATE TABLE #Instances
   (
      Instance_Number NVARCHAR(MAX),
      Instance_Name NVARCHAR(MAX),
      Data_Field NVARCHAR(MAX)
   );


   INSERT INTO #Instances
   (
      Instance_Number,
      Instance_Name,
      Data_Field
   )
   EXEC master.sys.xp_regread
      @rootkey = 'HKEY_LOCAL_MACHINE',
      @key = 'SOFTWARE\Microsoft\Microsoft SQL Server',
      @value_name = 'InstalledInstances';

   IF (
         SELECT COUNT(*)
         FROM   #Instances
      ) > 1
   BEGIN
      SET @MultipleInstancesInstalled = 1;
   END;

END TRY
BEGIN CATCH

END CATCH;

DECLARE @MachineName NVARCHAR(128);
SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

SELECT DISTINCT
       @MachineName AS [Server Name],
       (
          SELECT service_account
          FROM   sys.dm_server_services
          WHERE  servicename LIKE 'SQL Server (%'
       ) AS [Service account],
       CASE WHEN MN.locked_page_allocations_kb = 0 THEN 'N'
            ELSE 'Y'
       END AS [Lock pages in memory],
       @Error17890WrittenInErrorLog AS Error17890Occurred,
       CASE WHEN @MultipleInstancesInstalled = 1 THEN 'Y'
            ELSE 'N'
       END AS MultipleInstancesInstalled
FROM   sys.dm_os_memory_nodes MN
       INNER JOIN sys.dm_os_nodes N ON MN.memory_node_id = N.memory_node_id
WHERE  N.node_state_desc <> 'ONLINE DAC';

