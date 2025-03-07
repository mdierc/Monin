--**********************************************************************************************************************
--* Description: Check if DB owner is sa.                                                                              *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

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
      d.name AS [Database Name],
      ISNULL(p.name, '<NULL>') AS [Owner],
      'ALTER AUTHORIZATION ON database::' + QUOTENAME(d.name) + ' TO sa;' AS AlterScript
FROM  sys.databases d
      LEFT JOIN sys.server_principals p ON d.owner_sid = p.sid
WHERE ISNULL(p.name, '') <> 'sa'
      AND DATABASEPROPERTYEX(d.name, 'Updateability') = 'READ_WRITE'
      AND DATABASEPROPERTYEX(d.name, 'Status') = 'ONLINE';