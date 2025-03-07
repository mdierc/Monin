/********************************************************************************************************************\
* Description: Check for NT-logins which no longer exist in Active Directory.                                        *
**********************************************************************************************************************
* Modified by             Date       Description/Features added                                                      *
* ----------------------- ---------- ------------------------------------------------------------------------------- *
* SQL Team                ?          First version.                                                                  *
* Maarten Dierckxxens     23/11/2022 Added check if temp table exists to drop the temp table.                        *
* Christophe Platteeuw	  25/02/2025 Added ignore for group managed service accounts                                 *
\********************************************************************************************************************/

SET NOCOUNT ON;

/*Variables to work with*/
DECLARE @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

DECLARE @NTLogin sysname;
DECLARE @CmdStr VARCHAR(1024);

/* DROP TEMPORARY TABLE*/

IF OBJECT_ID('tempdb..#tb_invalid_logins') IS NOT NULL
   DROP TABLE #tb_invalid_logins;

/*CREATE TEMPORARY TABLE*/
CREATE TABLE #tb_invalid_logins
(
   SID VARBINARY(85) NOT NULL,
   NTLogin sysname NOT NULL PRIMARY KEY
);

/*GET INVALID LOGINS*/
INSERT #tb_invalid_logins
(
   SID,
   NTLogin
)
EXEC master..sp_validatelogins;

/*IGNORE SOME SPECIAL LOGINS*/
DELETE FROM #tb_invalid_logins
WHERE NTLogin LIKE 'NT SERVICE%';
DELETE FROM #tb_invalid_logins
WHERE NTLogin LIKE '%$';

/*Results*/
SELECT
         @MachineName AS [Server Name],
         NTLogin,
         'DROP LOGIN [' + NTLogin + ']' AS DropScript
FROM     #tb_invalid_logins
ORDER BY NTLogin;


IF OBJECT_ID('tempdb..#tb_invalid_logins') IS NOT NULL
   DROP TABLE #tb_invalid_logins;