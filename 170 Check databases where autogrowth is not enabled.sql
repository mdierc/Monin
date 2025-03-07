--**********************************************************************************************************************
--* Description: Check for databases where autogrowth is not enabled.                                                  *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* Vandekerkhove Christian 26/01/2021 First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON;

DECLARE @Execute BIT;

SET @Execute = 1;


DECLARE @DBname       sysname,
        @logical_name sysname,
        @growth       VARCHAR(10),
        @CmdStr       VARCHAR(8000);


CREATE TABLE #tb_GrowthInfo (dbname sysname,
                             logical_name sysname,
                             growth INT,
                             PRIMARY KEY (dbname, logical_name));

DECLARE curDB CURSOR FOR
SELECT sd.name
  FROM sys.databases sd
 WHERE DATABASEPROPERTYEX(sd.name, 'Status')        = 'ONLINE'
   AND DATABASEPROPERTYEX(sd.name, 'Updateability') = 'READ_WRITE' -- ignore read-only DBs
   AND name NOT IN ( 'master', 'model', 'msdb', 'tempdb' )
 ORDER BY sd.name;
OPEN curDB;
FETCH curDB
 INTO @DBname;
WHILE @@fetch_status = 0
BEGIN
    -- Size is expressed in 8Kb pages => size * 8 /1024 = size in Mb
    SET @CmdStr
        = 'insert #tb_GrowthInfo (dbname,logical_name, growth) select ''' + @DBname + ''', name,  growth from ['
          + @DBname + '].sys.database_files WHERE growth = 0 and type_desc not in (''FULLTEXT'',''FILESTREAM'')';
    EXEC (@CmdStr);
    FETCH curDB
     INTO @DBname;
END;
CLOSE curDB;
DEALLOCATE curDB;
SELECT *
  FROM #tb_GrowthInfo;
DROP TABLE #tb_GrowthInfo;