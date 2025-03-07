--**********************************************************************************************************************
--* Description: Check if DB owner is sa.                                                                              *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON

SELECT      d.name AS [Database],
            ISNULL(p.name, ISNULL(SUSER_SNAME(owner_sid), '<unknown>')) AS [Owner],
            'ALTER AUTHORIZATION ON database::' + QUOTENAME(d.name) + ' TO sa;' AS AlterScript
  FROM      sys.databases d
  LEFT JOIN sys.server_principals p
    ON d.owner_sid = p.sid
 WHERE      ISNULL(p.name, '')                     <> 'sa'
   AND      DATABASEPROPERTYEX(d.name, 'Updateability') = 'READ_WRITE'
   AND      DATABASEPROPERTYEX(d.name, 'Status')        = 'ONLINE';