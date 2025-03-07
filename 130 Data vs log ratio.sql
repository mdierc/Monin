--**********************************************************************************************************************
--* Description: Calculate the ratio of the data size versus the log size in percent.                                  *
--*              If the ration > 100 it means that the log is bigger than the data.                                    *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* Vandekerkhove Christian 15/04/2021 First version.                                                                  *
--* Maarten Dierckxsens		08/02/2022 Added column with revocery model description to the result.                     *
--* Maarten Dierckxsens		28/03/2023 Recovery model not showing the correct value									   *
--**********************************************************************************************************************

SET NOCOUNT ON;

DECLARE @DBname          VARCHAR(255),
		@RecoveryModel	 VARCHAR(50),
        @IgnoreSystemDBs BIT,
        @DBExceptionlist VARCHAR(1024),
        @CmdStr          VARCHAR(8000),
        @CurrentDB       VARCHAR(255),
		@CurrentRecoveryModel	 VARCHAR(50);

SET @DBname = '%';
SET @IgnoreSystemDBs = 1; -- When 1 do not include the system databases
SET @DBExceptionlist = '';


CREATE TABLE #tb_DBsizes (DBname VARCHAR(255),
							RecoveryModel varchar(50),
                          DBType CHAR(4),
                          SizeMb FLOAT);

IF @IgnoreSystemDBs = 1
BEGIN
    DECLARE curDB CURSOR FAST_FORWARD FOR
    SELECT name, recovery_model_desc
      FROM sys.databases
     WHERE DATABASEPROPERTYEX(name, 'STATUS')        = 'ONLINE'
       AND DATABASEPROPERTYEX(name, 'Updateability') = 'READ_WRITE'
       --AND name LIKE @DBname
       AND name NOT IN ( 'master', 'msdb', 'model', 'tempdb', 'distribution' )
     ORDER BY name;
END;
ELSE
BEGIN
    DECLARE curDB CURSOR FAST_FORWARD FOR
    SELECT name, recovery_model_desc
      FROM sys.databases
     WHERE DATABASEPROPERTYEX(name, 'STATUS')        = 'ONLINE'
       AND DATABASEPROPERTYEX(name, 'Updateability') = 'READ_WRITE'
       AND name LIKE @DBname
     --AND name NOT IN ( 'master', 'msdb', 'model', 'tempdb', 'distribution' )
     ORDER BY name;
END;
OPEN curDB;
FETCH curDB
 INTO @CurrentDB, @CurrentRecoveryModel;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @CmdStr
        = 'USE [' + @CurrentDB + '] ' + 'SELECT db_name(), ''' + @CurrentRecoveryModel + ''' AS REcoveryModel, ' + '       CASE type ' + '         WHEN 0 THEN ''data'''
          + '         ELSE ''log''' + '       END AS [Type], ' + '       SUM(size*8.0/1024) AS [Size in Mb] '
          + '  FROM sys.database_files ' + ' WHERE type in (0,1) ' + 'GROUP BY type;';
    INSERT #tb_DBsizes
    EXEC (@CmdStr);
	--PRINT @CmdStr
    FETCH curDB
     INTO @CurrentDB, @CurrentRecoveryModel;
END;
CLOSE curDB;
DEALLOCATE curDB;

CREATE TABLE #tb_SizeProportion (DBname VARCHAR(255),
								RecoveryModel varchar(50),
                                 DataMb FLOAT,
                                 LogMb FLOAT,
                                 DataLogRatio FLOAT);

DECLARE @DataSize FLOAT,
        @LogSize  FLOAT;

DECLARE curSizeProportion CURSOR FAST_FORWARD FOR
SELECT DISTINCT DBname, RecoveryModel
  FROM #tb_DBsizes;
OPEN curSizeProportion;
FETCH curSizeProportion
 INTO @DBname, @RecoveryModel;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @DataSize = (SELECT SizeMb FROM #tb_DBsizes WHERE DBType = 'data' AND DBname = @DBname);
    SET @LogSize = (SELECT SizeMb FROM #tb_DBsizes WHERE DBType = 'log ' AND DBname = @DBname);
    INSERT #tb_SizeProportion
    VALUES (@DBname, @RecoveryModel, @DataSize, @LogSize, @LogSize / @DataSize * 100);
    FETCH curSizeProportion
     INTO @DBname, @RecoveryModel;
END;
CLOSE curSizeProportion;
DEALLOCATE curSizeProportion;

SELECT DBname,
       RecoveryModel,
       CONVERT(BIGINT,DataMb) AS [DataMb],
       CONVERT(BIGINT,LogMb) AS [LogMb],
       CONVERT(BIGINT,DataLogRatio) AS [DataLogRatio]
  FROM #tb_SizeProportion
 WHERE DataLogRatio > 100
 ORDER BY DataLogRatio DESC,
          DBname;

DROP TABLE #tb_DBsizes;
DROP TABLE #tb_SizeProportion;
GO
