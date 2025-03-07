-- Check if 'show advanced options' and 'xp_cmdshell' are enabled
SET NOCOUNT ON;
DECLARE @ShowAdvancedOptionsEnabled INT,
        @ShowAdvancedOptionsChanged INT,
        @xp_cmdshellEnabled         INT,
        @CmdStr VARCHAR(8000);

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
SET @ShowAdvancedOptionsChanged=0
IF @ShowAdvancedOptionsEnabled = 0
BEGIN
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
    SET @ShowAdvancedOptionsChanged=1
END;

INSERT #tb_spconfigure ([name],
                        minimum,
                        maximum,
                        config_value,
                        run_value)
EXEC sp_configure 'xp_cmdshell';

INSERT #tb_spconfigure ([name],
                        minimum,
                        maximum,
                        config_value,
                        run_value)
EXEC sp_configure 'clr enabled';

INSERT #tb_spconfigure ([name],
                        minimum,
                        maximum,
                        config_value,
                        run_value)
EXEC sp_configure 'Ole Automation Procedures';

INSERT #tb_spconfigure ([name],
                        minimum,
                        maximum,
                        config_value,
                        run_value)
EXEC sp_configure 'scan for startup procs';

SET @xp_cmdshellEnabled = (SELECT run_value FROM #tb_spconfigure WHERE name = 'xp_cmdshell');
IF @ShowAdvancedOptionsChanged=1
BEGIN
    EXEC sp_configure 'show advanced options', 0;
    RECONFIGURE;
    SET @ShowAdvancedOptionsChanged=1
END;

--SELECT name, run_value 
--FROM #tb_spconfigure
--WHERE run_value = 1

SELECT @ShowAdvancedOptionsEnabled AS [Show advanced options],
       @xp_cmdshellEnabled AS [xp_cmdshell];

DROP TABLE #tb_spconfigure;