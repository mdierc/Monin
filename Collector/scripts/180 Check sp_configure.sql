-- Check if 'show advanced options' and 'xp_cmdshell' are enabled
SET NOCOUNT ON;
DECLARE
   @ShowAdvancedOptions INT,
   @xp_cmdshell INT,
   @CmdStr VARCHAR(8000),
   @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;


SELECT @ShowAdvancedOptions = CAST(c.value_in_use AS INT)
FROM sys.configurations AS c
WHERE c.name = 'Show Advanced Options'


SELECT @xp_cmdshell = CAST(c.value_in_use AS INT)
FROM sys.configurations AS c
WHERE c.name = 'xp_cmdshell'

SELECT
      @MachineName AS [Server Name],
      @ShowAdvancedOptions AS [Show advanced options],
      @xp_cmdshell AS [xp_cmdshell]


