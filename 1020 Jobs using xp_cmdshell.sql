--**********************************************************************************************************************
--* Description: Find jobs which use xp_cmdshell.                                                                      *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* Vandekerkhove Christian 08/12/2022 First version.                                                                  *
--**********************************************************************************************************************

SELECT sj.name AS [Job],
       sjs.command AS [Command]
  FROM msdb..sysjobsteps sjs
  JOIN msdb..sysjobs sj
    ON sjs.job_id = sj.job_id
 WHERE sjs.command LIKE '%xp_cmdshell%'
 ORDER BY sj.name;
GO
