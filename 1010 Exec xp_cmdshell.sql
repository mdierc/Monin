--**********************************************************************************************************************
--* Description: Check for objects which call xp_cmdshell.                                                             *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* Vandekerkhove Christian 08/12/2022 First version.                                                                  *
--**********************************************************************************************************************
-- 
DECLARE @DBname VARCHAR(255)

SET @DBname = '%'

SET NOCOUNT ON
DECLARE @CmdStr VARCHAR(8000),
        @CurrentDB VARCHAR(255)

DECLARE curDB CURSOR FAST_FORWARD FOR
    SELECT  name
    FROM    sys.databases
    WHERE   DATABASEPROPERTYEX(name, 'STATUS') = 'ONLINE'
	AND (DATABASEPROPERTYEX(name, 'Updateability') = 'READ_ONLY' OR DATABASEPROPERTYEX(name, 'Updateability') = 'READ_WRITE')
            AND name LIKE @DBname
    ORDER BY name

OPEN curDB
FETCH curDB INTO @CurrentDB

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @CmdStr = 'USE [' + @CurrentDB + '] '+
  'IF EXISTS ( SELECT 1
FROM sys.syscomments sc
JOIN sys.objects so ON sc.id = so.object_id
WHERE CHARINDEX(''xp_cmdshell'',text) > 0
AND (''' + @CurrentDB + ''' <> ''msdb'' and so.name not in (''sp_set_local_time'', ''sp_set_local_time'', ''sp_msx_defect'')))
    SELECT ''' + @CurrentDB + ''' as [Database], so.name, sc.text
FROM sys.syscomments sc
JOIN sys.objects so ON sc.id = so.object_id
WHERE CHARINDEX(''xp_cmdshell'',text) > 0
AND (''' + @CurrentDB + ''' <> ''msdb'' and so.name not in (''sp_set_local_time'', ''sp_set_local_time'', ''sp_msx_defect''))'
  EXEC (@CmdStr)
  FETCH curDB INTO @CurrentDB
END
CLOSE curDB
DEALLOCATE curDB


