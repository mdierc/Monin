--**********************************************************************************************************************
--* Description:  Check if the "sa" account is disabled.                                                               *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON
DECLARE
   @MachineName NVARCHAR(128);
SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

SELECT @MachineName AS [Server Name], is_disabled AS [Disabled]
  FROM sys.server_principals
 WHERE name        = 'sa';