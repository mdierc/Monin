--**********************************************************************************************************************
--* Description: Check membership of db_owner, db_accessadmin, db_backupoperator, db_ddladmin and db_securityadmin.     *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON;

DECLARE @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

DECLARE @DBname VARCHAR(255);

SET @DBname = '%';

DECLARE
   @CmdStr VARCHAR(8000),
   @CurrentDB VARCHAR(255);

CREATE TABLE #tb_Result
(
   [Database] [NVARCHAR](128) NULL,
   [Account] [sysname] NOT NULL,
   [Login] [sysname] NULL,
   [Type] [NVARCHAR](60) NULL,
   [Member of] [sysname] NULL
);
DECLARE curDB CURSOR FAST_FORWARD FOR
   SELECT   name
   FROM     sys.databases
   WHERE    DATABASEPROPERTYEX(name, 'STATUS') = 'ONLINE'
            AND DATABASEPROPERTYEX(name, 'Updateability') = 'READ_WRITE'
            AND name LIKE @DBname
   ORDER BY name;

OPEN curDB;
FETCH curDB
INTO @CurrentDB;

WHILE @@FETCH_STATUS = 0
BEGIN
   SET @CmdStr = 'USE [' + @CurrentDB + '] ' + 'SELECT ''' + @CurrentDB
                 + ''' AS [Database],
       p.name ''Account'',
       sp.name ''Login'',
       p.type_desc ''Type'',
       r.name ''Member of''
  FROM sys.database_principals p
  JOIN sys.server_principals sp
    ON p.sid                = sp.sid
  JOIN sys.database_role_members rm
    ON p.principal_id       = rm.member_principal_id
  JOIN sys.database_principals r
    ON rm.role_principal_id = r.principal_id
 WHERE p.name NOT IN ( ''dbo'' ) -- (''guest'',''sys'',''INFORMATION_SCHEMA'')
   AND r.name IN ( ''db_owner'', ''db_accessadmin'', ''db_backupoperator'', ''db_ddladmin'', ''db_securityadmin'' )
UNION
-- Get the NT groups which are not in any SQL role. This happens e.g. when an application role is used.
SELECT      '''  + @CurrentDB
                 + ''' AS [Database],
            p.name ''Account'',
            sp.name ''Login'',
            p.type_desc ''Type'',
            r.name ''Member of''
  FROM      sys.database_principals p
  LEFT JOIN sys.server_principals sp
    ON p.sid                = sp.sid
  LEFT JOIN sys.database_role_members rm
    ON p.principal_id       = rm.member_principal_id
  LEFT JOIN sys.database_principals r
    ON rm.role_principal_id = r.principal_id
 WHERE      p.name NOT IN ( ''dbo'', ''guest'', ''sys'', ''INFORMATION_SCHEMA'', ''db_accessadmin'', ''db_backupoperator'',
                            ''db_datareader'', ''db_datawriter'', ''db_ddladmin'', ''db_denydatareader'', ''db_denydatawriter'',
                            ''db_owner'', ''db_securityadmin'', ''public'' ) -- Ignore built in SQL roles
   AND      r.name IN ( ''db_owner'', ''db_accessadmin'', ''db_backupoperator'', ''db_ddladmin'', ''db_securityadmin'' )
'  ;
   INSERT #tb_Result
   (
      [Database],
      Account,
      Login,
      Type,
      [Member of]
   )
   EXEC (@CmdStr);
   FETCH curDB
   INTO @CurrentDB;
END;
CLOSE curDB;
DEALLOCATE curDB;
SELECT
         @MachineName AS [Server Name],
         [Database] AS [Database Name],
         Account,
         Login,
         Type,
         [Member of]
FROM     #tb_Result
ORDER BY [Database],
         Account,
         [Member of];

DROP TABLE #tb_Result;
