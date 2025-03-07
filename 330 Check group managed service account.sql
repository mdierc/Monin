--**********************************************************************************************************************
--* Description: Check if the SQL Server and SQL Server Agent service account is a gMSA                                *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* Christophe Platteeuw    30/01/2025 First version.                                                                  *
--* Chris Vandekerkhove     31/01/2025 Added union to have one account per row                                         *
--**********************************************************************************************************************
 
DECLARE @SQLServerServiceAccount NVARCHAR(256);
DECLARE @SQLAgentServiceAccount NVARCHAR(256);
 
-- Get SQL Server Service Account
 
EXEC xp_instance_regread
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
N'ObjectName',
@SQLServerServiceAccount OUTPUT,
'no_output';
 
-- Get SQL Server Agent Service Account
 
EXEC xp_instance_regread 
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT',
N'ObjectName',
@SQLAgentServiceAccount OUTPUT,
'no_output';
 
-- Output the results
 
SELECT 
'SQL Server Service' AS [Service],
@SQLServerServiceAccount AS [Account],
CASE (RIGHT(@SQLServerServiceAccount, 1)) WHEN '$' THEN 'Yes' ELSE 'No' END AS Is_gGMSA

UNION ALL

SELECT 
'SQL Server Agent' AS [Service],
@SQLAgentServiceAccount AS [Account],
CASE (RIGHT(@SQLAgentServiceAccount, 1)) WHEN '$' THEN 'Yes' ELSE 'No' END AS Is_gMSA;

GO