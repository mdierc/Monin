--********************************************************************************************************************************************
--* Description: Check if the device holding the data files is formatted using 64 Kb/segment.                                                *
--********************************************************************************************************************************************
--* Parameter         Type      Description                                                                                                  *
--* ----------------- --------- ------------------------------------------------------------------------------------------------------------ *
--* @DBname           sysname   Name of the DB to examine. Wildcards are allowed.                                                            *
--********************************************************************************************************************************************
--* Modified by             Date       Description/Features added                                                                            *
--* ----------------------- ---------- ----------------------------------------------------------------------------------------------------- *
--* Vandekerkhove Christian 01/12/2010 First version.                                                                                        *
--* Vandekerkhove Christian 21/09/2021 Bugfix in case SQLDataRoot/SQLLogRoot are not defined in the registry.
--* Vandekerkhove Christian 04/04/2024 To do: if regkey not found read in same location the parameters for the startup (SqlArgx)/                         *
--********************************************************************************************************************************************

DECLARE @strEnvVar [NVARCHAR](4000) = N'DefaultData',
        @DataRoot  [NVARCHAR](4000) = NULL;

DECLARE @RetValue INT = 0;

DECLARE @key_name      VARCHAR(1024),
        @RegistryValue VARCHAR(1024),
        @ServiceKey    VARCHAR(1024),
        @aRegKey       VARCHAR(1024);


-- Get the key of the current service
SET @key_name = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'; -- Under this key all instances of SQL Server are listed.
SET @ServiceKey = @@SERVICENAME; -- name of the instance
SET @DataRoot = N'';

EXEC master.dbo.xp_regread @rootkey = 'HKEY_LOCAL_MACHINE',
                           @key = @key_name,
                           @value_name = @ServiceKey,
                           @value = @DataRoot OUTPUT; -- This will be used to look further in the registry

-- Find the value for the current service
-- DefaultData, DefaultLog, BackupDirectory


SET @key_name = 'SOFTWARE\Microsoft\Microsoft SQL Server\' + @DataRoot + '\MSSQLServer';
BEGIN TRY
    EXEC xp_regread @rootkey = N'HKEY_LOCAL_MACHINE',
                    @RegKey = @key_name,
                    @value_name = 'DefaultData',
                    @value = @DataRoot OUTPUT;
    PRINT 'DefaultData    : ' + @DataRoot;
END TRY
BEGIN CATCH
    SET @DataRoot = N'';
    RAISERROR('Could not find DefaultData', 16, 1);
    RETURN;
END CATCH;

-- fsutil fsinfo ntfsinfo


-- Check if 'show advanced options' and 'xp_cmdshell' are enabled
SET NOCOUNT ON;
DECLARE @ShowAdvancedOptionsEnabled INT,
        @ShowAdvancedOptionsChanged BIT,
        @xp_cmdshellEnabled         INT,
        @xp_cmdshellChanged         BIT,
        @CmdStr                     VARCHAR(8000);


SET @xp_cmdshellChanged = 0;
SET @ShowAdvancedOptionsChanged = 0;

CREATE TABLE #tb_spconfigure ([name] NVARCHAR(35),
                              minimum INT,
                              maximum INT,
                              config_value INT,
                              run_value INT, );
INSERT #tb_spconfigure ([name],
                        minimum,
                        maximum,
                        config_value,
                        run_value)
EXEC sp_configure 'show advanced options';
SET @ShowAdvancedOptionsEnabled = (SELECT run_value FROM #tb_spconfigure WHERE name = 'show advanced options');
IF @ShowAdvancedOptionsEnabled = 0
BEGIN
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
    SET @ShowAdvancedOptionsChanged = 1;
END;

INSERT #tb_spconfigure ([name],
                        minimum,
                        maximum,
                        config_value,
                        run_value)
EXEC sp_configure 'xp_cmdshell';

SET @xp_cmdshellEnabled = (SELECT run_value FROM #tb_spconfigure WHERE name = 'xp_cmdshell');

IF @xp_cmdshellEnabled = 0
BEGIN
    EXEC sp_configure 'xp_cmdshell', 1;
    RECONFIGURE;
    SET @xp_cmdshellChanged = 1;
END;

-- Type here you xp_cmdshell commands:
SET @CmdStr = 'fsutil fsinfo ntfsinfo "' + @DataRoot + '"';
PRINT @CmdStr;
CREATE TABLE #tb_Result (LineNr INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
                         aLine VARCHAR(8000) NULL);
PRINT @CmdStr;
INSERT #tb_Result (aLine)
EXEC xp_cmdshell @CmdStr;
SELECT @DataRoot AS [Data root],
       LTRIM(REPLACE(REPLACE(aLine, 'Bytes Per Cluster :', ''),'  (64 KB)',''))  AS [Bytes per cluster]
  FROM #tb_Result
 WHERE aLine LIKE 'Bytes Per Cluster%'
 ORDER BY LineNr;

IF @xp_cmdshellChanged = 1
BEGIN
    EXEC sp_configure 'xp_cmdshell', 0;
    RECONFIGURE;
END;

IF @ShowAdvancedOptionsChanged = 1
BEGIN
    EXEC sp_configure 'show advanced options', 0;
    RECONFIGURE;
END;

DROP TABLE #tb_Result;
DROP TABLE #tb_spconfigure;
PRINT @DataRoot;