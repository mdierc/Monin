
SET NOCOUNT ON;

DECLARE @MachineName NVARCHAR(128);
SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

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

IF (
      @ProductVersionMajor = 11
      AND @ProductVersionMinor >= 7001
   )
   OR (
         @ProductVersionMajor = 12
         AND @ProductVersionMinor >= 6024
      )
   OR (@ProductVersionMajor > 12)
BEGIN
   /*Applies to: SQL Server 2012 (11.x) SP 4, SQL Server 2014 (12.x) SP 3, and SQL Server 2016 (13.x) SP 1 and later versions.*/
   DECLARE @StringToExecute NVARCHAR(500) = 
    'SELECT
         '''+@MachineName+''' AS [Server Name],
         service_account,
         instant_file_initialization_enabled AS [IFI enabled]
   FROM  sys.dm_server_services
   WHERE ServiceName LIKE ''SQL Server (%''';

   EXEC (@StringToExecute)
END
ELSE
BEGIN
	SELECT
         @MachineName AS [Server Name],
         service_account,
         NULL AS [IFI enabled]
   FROM  sys.dm_server_services
   WHERE ServiceName LIKE 'SQL Server (%';
END