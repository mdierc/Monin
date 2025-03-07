--**********************************************************************************************************************
--* Description: Find SQL users in @DBname which have no or an invalid login.                                          *
--**********************************************************************************************************************
--* Parameter         Type      Description                                                                            *
--* ----------------- --------- -------------------------------------------------------------------------------------- *
--* @DBname           sysname   Name of the database to check. May contain wildcards.                                  *
--* @FixIssues        BIT       When 1, attempt to fix the SQL user with the correct sid.                              *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* Vandekerkhove Christian 22/05/2024 First version.                                                                  *
--* Vandekerkhove Christian 16/01/2025 Removed userid from the result set.                                             *
--**********************************************************************************************************************

SET NOCOUNT ON;

DECLARE @DBname    VARCHAR(255),
        @FixIssues BIT;

SET @DBname = '%';
SET @FixIssues = 1; -- When 1 attempt to fix issues

DECLARE @CmdStr    NVARCHAR(4000),
        @CurrentDB sysname,
        @Username  sysname;

CREATE TABLE #tb_Result (username sysname,
                         userid VARBINARY(85));

CREATE TABLE #tb_DBResult (DB sysname,
                           username sysname,
                           userid VARBINARY(85));
CREATE CLUSTERED INDEX IX_DB__Username ON #tb_DBResult (DB, username);

DECLARE curDB CURSOR FAST_FORWARD FOR
SELECT name
  FROM sys.databases
 WHERE --name NOT IN ( 'master', 'msdb', 'model', 'tempdb', 'distribution' ) AND
       DATABASEPROPERTYEX(name, 'STATUS')        = 'ONLINE'
   AND DATABASEPROPERTYEX(name, 'Updateability') = 'READ_WRITE'
   AND name LIKE @DBname
 ORDER BY name;

OPEN curDB;
FETCH curDB
 INTO @CurrentDB;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @CmdStr
        = N'USE [' + @CurrentDB
          + N']; INSERT #tb_Result (username, userid) EXEC sys.sp_change_users_login @Action = ''report''';
    EXEC (@CmdStr);
    INSERT #tb_DBResult (DB,
                         username,
                         userid)
    SELECT @CurrentDB,
           username,
           userid
      FROM #tb_Result;
    TRUNCATE TABLE #tb_Result;

    FETCH curDB
     INTO @CurrentDB;
END;
CLOSE curDB;
DEALLOCATE curDB;

SELECT DB,
       username
  FROM #tb_DBResult
 ORDER BY DB,
          username;

IF (SELECT COUNT(*)FROM #tb_DBResult) > 0
BEGIN
    DECLARE curFixit CURSOR FOR
    SELECT DB,
           username
      FROM #tb_DBResult
     ORDER BY DB,
              username;
    OPEN curFixit;
    FETCH curFixit
     INTO @CurrentDB,
          @Username;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (   SELECT name
                            FROM sys.server_principals
                           WHERE name = @Username)
        BEGIN
            PRINT 'User [' + @Username
                  + '] cannot be fixed: first create an SQL login with the same name and the correct password.';
        END;
        ELSE
        BEGIN
            SET @CmdStr
                = N'USE [' + @CurrentDB
                  + N']; exec sys.sp_change_users_login @Action = ''Update_One'',  @UserNamePattern = ''' + @Username
                  + N''', @LoginName = ''' + @Username + N'''';
            PRINT @CmdStr;
            IF @FixIssues = 1
            BEGIN
                BEGIN TRY
                    EXEC (@CmdStr);
					PRINT 'Issues has been fixed for ['+ @Username + '].' + CHAR(13) + CHAR(10)
                END TRY
                BEGIN CATCH
                    PRINT 'Execution failed: ' + ERROR_MESSAGE();
                END CATCH;
            END;
        END;
        FETCH curFixit
         INTO @CurrentDB,
              @Username;
    END;
    CLOSE curFixit;
    DEALLOCATE curFixit;

END;

DROP TABLE #tb_Result,
           #tb_DBResult;

