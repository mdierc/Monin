--**********************************************************************************************************************
--* Description: Check which accounts are member of system roles.                                                      *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON

SELECT sp1.name AS [Login],
       sp2.name AS [System role],
       sp1.is_disabled AS [IsDisabled]
  FROM sys.server_role_members srm
  JOIN sys.server_principals sp1
    ON sp1.principal_id = srm.member_principal_id
  JOIN sys.server_principals sp2
    ON sp2.principal_id = srm.role_principal_id
 WHERE sp1.name NOT IN ( 'sa', 'NT SERVICE\SQLWriter', 'NT SERVICE\Winmgmt', 'NT SERVICE\MSSQLSERVER',
                         'NT SERVICE\SQLSERVERAGENT' )
 ORDER BY sp2.name;
