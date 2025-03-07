--**********************************************************************************************************************
--* Description: Show failed jobs but only if the job is enabled and has a schedule.                                   *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************
SET NOCOUNT ON


SELECT      sj.name AS [Job],
            CASE
                 WHEN sj.enabled = 1 THEN 'Enabled'
                 ELSE 'Disabled' END AS [Status],
            CONVERT(
                DATETIME,
                SUBSTRING(CONVERT(VARCHAR, run_date, 112), 7, 2) + '/' + SUBSTRING(CONVERT(VARCHAR, run_date, 112), 5, 2)
                + '/' + LEFT(CONVERT(VARCHAR, run_date, 112), 4) + ' '
                + LEFT(REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time))) + CONVERT(VARCHAR, run_time), 2) + ':'
                + SUBSTRING(REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time))) + CONVERT(VARCHAR, run_time), 3, 2)
                + ':'
                + SUBSTRING(REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time))) + CONVERT(VARCHAR, run_time), 5, 2),
                103) AS [Run date],
            'Step ' + CONVERT(VARCHAR, sh.step_id) + ': ' AS [Step],
            sh.message AS [Message]
  FROM      msdb..sysjobs sj
 INNER JOIN msdb..sysjobhistory sh
    ON sj.job_id = sh.job_id
  LEFT JOIN msdb..sysjobschedules ss
    ON sj.job_id = ss.job_id
 WHERE      sh.run_status = 0
   --AND sj.enabled = 1
   AND      ss.job_id IS NOT NULL
   AND      sh.step_id         > 0
   AND      CONVERT(
                DATETIME,
                SUBSTRING(CONVERT(VARCHAR, run_date, 112), 7, 2) + '/' + SUBSTRING(CONVERT(VARCHAR, run_date, 112), 5, 2)
                + '/' + LEFT(CONVERT(VARCHAR, run_date, 112), 4) + ' '
                + LEFT(REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time))) + CONVERT(VARCHAR, run_time), 2) + ':'
                + SUBSTRING(REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time))) + CONVERT(VARCHAR, run_time), 3, 2)
                + ':'
                + SUBSTRING(REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time))) + CONVERT(VARCHAR, run_time), 5, 2),
                103)           = (   SELECT MAX(CONVERT(
                                                    DATETIME,
                                                    SUBSTRING(CONVERT(VARCHAR, run_date, 112), 7, 2) + '/'
                                                    + SUBSTRING(CONVERT(VARCHAR, run_date, 112), 5, 2) + '/'
                                                    + LEFT(CONVERT(VARCHAR, run_date, 112), 4) + ' '
                                                    + LEFT(REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time)))
                                                           + CONVERT(VARCHAR, run_time), 2) + ':'
                                                    + SUBSTRING(
                                                          REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time)))
                                                          + CONVERT(VARCHAR, run_time),
                                                          3,
                                                          2) + ':'
                                                    + SUBSTRING(
                                                          REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR, run_time)))
                                                          + CONVERT(VARCHAR, run_time),
                                                          5,
                                                          2),
                                                    103))
                                       FROM msdb..sysjobhistory
                                      WHERE job_id = sh.job_id);
