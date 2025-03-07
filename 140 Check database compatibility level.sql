--**********************************************************************************************************************
--* Description: Find databases with a compatibility level lower than the server version.                              *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* ?                       ?            First version.                                                                *
--* Vandekerkhove Christian 15/12/2022   Now recognizes SQL 2022.                                                      *
--* Vandekerkhove Christian 15/12/2022   Use SERVERPROPERTY to determine the server version.                           *
--* Vandekerkhove Christian 22/12/2022   Bugfix in case master has a lower compatibility level.                        *
--* Vandekerkhove Christian 23/01/2025   Get @strTargetLevel from @@VERSION.                                           *
--**********************************************************************************************************************
-- List databases where the compatibility level is lower than the server level
DECLARE @Targetlevel    INT,
        @strTargetLevel VARCHAR(128);

SET @Targetlevel = (SELECT CONVERT(INT, SERVERPROPERTY('ProductMajorVersion'))) * 10;
SET @strTargetLevel = LEFT(@@VERSION,25)

SELECT name AS [Database],
       CASE CONVERT(VARCHAR, compatibility_level)
            WHEN '170' THEN 'SQL Server 2025'
            WHEN '160' THEN 'SQL Server 2022'
            WHEN '150' THEN 'SQL Server 2019'
            WHEN '140' THEN 'SQL Server 2017'
            WHEN '130' THEN 'SQL Server 2016'
            WHEN '120' THEN 'SQL Server 2014'
            WHEN '110' THEN 'SQL Server 2012'
            WHEN '100' THEN 'SQL Server 2008'
            WHEN '90' THEN 'SQL Server 2005'
            WHEN '80' THEN 'SQL Server 2000' 
			ELSE 'Unknown'
			END AS [Current level],
       @strTargetLevel AS [System level],
       'ALTER DATABASE [' + d.name + '] SET COMPATIBILITY_LEVEL = ' + CONVERT(VARCHAR, @Targetlevel) AS [ModifyScript],
       'ALTER DATABASE [' + d.name + '] SET COMPATIBILITY_LEVEL = ' + CONVERT(VARCHAR, compatibility_level) AS [RollbackScript]
  FROM sys.databases d
 WHERE compatibility_level <> @Targetlevel
   AND d.state_desc        = 'ONLINE'
   AND d.is_read_only      = 0;
GO
