--**********************************************************************************************************************
--* Description: Check for databases where the recovery mode is not suitable for the environment.                      *
--*              This script comes in 2 parts: one for PROD and one for non-PROD. Execute only the part you need.      *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--* Chris Vandekerkhove     25/10/2024 Ignore DBs in non-PROD which are in FULL recovery but part of an AO group.      *
--**********************************************************************************************************************

-- PROD
-- Give a list of all user databases where the recovery model <> 'FULL'
SET NOCOUNT ON;
SELECT d.name AS [Database],
       d.recovery_model_desc AS [Recovery model]
FROM sys.databases d
WHERE d.recovery_model_desc <> 'FULL'
      AND d.name NOT IN ( 'master', 'model', 'msdb', 'tempdb', 'DBAToolbox', 'DBA', 'MoninSupport', 'HMSM', 'MgmtDb' );
GO


-- non-PROD
-- Give a list of all user databases where the recovery model <> 'SIMPLE'
SET NOCOUNT ON;
SELECT d.name AS [Database],
       d.recovery_model_desc AS [Recovery model]
FROM sys.databases d
    LEFT JOIN sys.availability_databases_cluster adc
        ON d.name = adc.database_name
WHERE d.recovery_model_desc <> 'SIMPLE'
      AND d.name NOT IN ( 'master', 'model', 'msdb', 'tempdb', 'DBAToolbox', 'DBA', 'MoninSupport', 'HMSM', 'MgmtDb' )
      AND adc.database_name IS NULL; -- Ignore databases which are member of an Always On Group
