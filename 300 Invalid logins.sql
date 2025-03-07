/********************************************************************************************************************\
* Description: Check for NT-logins which no longer exist in active directory.                                        *
**********************************************************************************************************************
* Modified by             Date       Description/Features added                                                      *
* ----------------------- ---------- ------------------------------------------------------------------------------- *
* SQL Team                ?          First version.                                                                  *
* Maarten Dierckxxens     23/11/2022 Added check if temp table exists to drop the temp table.                        *
\********************************************************************************************************************/

SET NOCOUNT ON
DECLARE @NTLogin sysname,
        @CmdStr VARCHAR(1024)

IF OBJECT_ID('tempdb..#tb_invalid_logins') IS NOT NULL
BEGIN
	DROP TABLE #tb_invalid_logins;
END

CREATE TABLE #tb_invalid_logins
(
    SID VARBINARY(85) NOT NULL,
    NTLogin sysname NOT NULL PRIMARY KEY
);

INSERT #tb_invalid_logins
(
    SID,
    NTLogin
)
EXEC master..sp_validatelogins;

DELETE FROM #tb_invalid_logins WHERE NTLogin LIKE 'NT SERVICE%'

--DECLARE curInvalidLogins CURSOR FOR
SELECT NTLogin, 'DROP LOGIN [' + NTLogin + ']' AS DropScript
FROM #tb_invalid_logins
ORDER BY NTLogin;
--OPEN curInvalidLogins;
--FETCH curInvalidLogins
--INTO @NTLogin;
--WHILE @@fetch_status = 0
--BEGIN
--    SET @CmdStr = 'DROP LOGIN [' + @NTLogin + ']';
--    PRINT @CmdStr;
--    FETCH curInvalidLogins
--    INTO @NTLogin;
--END;
--CLOSE curInvalidLogins;
--DEALLOCATE curInvalidLogins;

DROP TABLE #tb_invalid_logins;