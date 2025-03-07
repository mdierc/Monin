--**********************************************************************************************************************
--* Description: Scan for UNSAFE assemblies in all databases.                                                          *
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
  'IF EXISTS (   SELECT name AS ''Assembly'',
                     clr_name,
                     permission_set_desc,
                     is_visible
                FROM sys.assemblies
               WHERE name NOT IN ( ''Microsoft.SqlServer.Types'' )
			     AND permission_set_desc <> ''SAFE_ACCESS'')
    SELECT ''' + @CurrentDB + ''' as [Database], name AS ''Assembly'',
           clr_name,
           permission_set_desc,
           is_visible
      FROM sys.assemblies
     WHERE name NOT IN ( ''Microsoft.SqlServer.Types'' )
	 	AND permission_set_desc <> ''SAFE_ACCESS'';'
  EXEC (@CmdStr)
  FETCH curDB INTO @CurrentDB
END
CLOSE curDB
DEALLOCATE curDB


