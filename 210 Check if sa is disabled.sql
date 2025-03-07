--**********************************************************************************************************************
--* Description:  Check if the "sa" account is disabled.                                                               *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--* Christophe Platteeuw	2025-01-22 Added column with disable script                                                *
--**********************************************************************************************************************

SET NOCOUNT ON

SELECT 
@@SERVERNAME AS [Server], 
'ALTER LOGIN sa DISABLE;' AS ModifyScript
FROM sys.server_principals
WHERE name = 'sa'
AND is_disabled = 0;