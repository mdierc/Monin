--**********************************************************************************************************************************************************************
--* Description: Count the number of VLFs.                                                                                                                             *
--**********************************************************************************************************************************************************************
--* Modified by             Date       Description/Features added                                                                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------------------------------------------------------- *
--* Vandekerkhove Christian ?          First version.                                                                                                                  *
--* Vandekerkhove Christian 31/03/2023 Now uses a random name for the permanent temporary tables to avoid conflicts when multiple instances are running on the server. *
--**********************************************************************************************************************************************************************
-- Count the number of virtual log files for each database
SET NOCOUNT ON;
DECLARE @CmdStr           VARCHAR(8000),
        @SQLVersion       VARCHAR(20),
        @TempTablename_01 VARCHAR(128),
        @TempTablename_02 VARCHAR(128);

SET @TempTablename_01 = '##tb_VLF_temp_' + REPLACE(CONVERT(VARCHAR(128), NEWID()), '-', '');

SET @SQLVersion = SUBSTRING(@@VERSION, CHARINDEX(@@VERSION, 'Microsoft SQL Server ') + 22, 4);
IF @SQLVersion = '2008'
BEGIN
    SET @CmdStr
        = 'CREATE TABLE [' + @TempTablename_01
          + '] 
           (FileID VARCHAR(3),
            FileSize NUMERIC(20, 0),
            StartOffset BIGINT,
            FSeqNo BIGINT,
            Status CHAR(1),
            Parity VARCHAR(4),
            CreateLSN NUMERIC(25, 0));';
END;
ELSE
BEGIN
    SET @CmdStr
        = 'CREATE TABLE [' + @TempTablename_01
          + '] 
           ([RecoveryUnitId] INT NULL,
            [FileId] INT NULL,
            [FileSize] BIGINT NULL,
            [StartOffset] BIGINT NULL,
            [FSeqNo] INT NULL,
            [Status] INT NULL,
            [Parity] TINYINT NULL,
            [CreateLSN] NUMERIC(25, 0) NULL);';
END;
EXEC (@CmdStr);

SET @TempTablename_02 = '##tb_VLF_temp_' + REPLACE(CONVERT(VARCHAR(128), NEWID()), '-', '');
SET @CmdStr = 'CREATE TABLE [' + @TempTablename_02 + '] (name sysname,vlf_count INT);';
EXEC (@CmdStr);

DECLARE db_cursor CURSOR READ_ONLY FOR
SELECT name
  FROM master.sys.sysdatabases
 WHERE DATABASEPROPERTYEX(name, 'STATUS') = 'ONLINE';

DECLARE @name sysname,
        @stmt VARCHAR(40);
OPEN db_cursor;

FETCH NEXT FROM db_cursor
 INTO @name;
WHILE (@@fetch_status <> -1)
BEGIN
    IF (@@fetch_status <> -2)
    BEGIN
        SET @CmdStr = 'SET NOCOUNT ON;
        INSERT INTO [' + @TempTablename_01 + '] 
        EXEC (''DBCC LOGINFO ([' + @name + ']) WITH NO_INFOMSGS'');
        INSERT INTO [' + @TempTablename_02 + '] 
        SELECT ''' + @name + ''',
               COUNT(*)
          FROM [' + @TempTablename_01 + '] ;
        TRUNCATE TABLE[' + @TempTablename_01 + '];';
        EXEC (@CmdStr);

    END;
    FETCH NEXT FROM db_cursor
     INTO @name;
END;
CLOSE db_cursor;
DEALLOCATE db_cursor;

SET @CmdStr = 'SELECT name,
       vlf_count
  FROM [' + @TempTablename_02 + ']
 ORDER BY vlf_count DESC, name;
SELECT * FROM [' + @TempTablename_02 + '] ORDER BY name;
DROP TABLE [' + @TempTablename_01 + '];
DROP TABLE [' + @TempTablename_02 + ']';
EXEC (@CmdStr);
GO
