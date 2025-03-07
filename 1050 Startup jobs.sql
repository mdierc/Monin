SELECT sj.name,ss.*
FROM msdb..sysjobs sj
JOIN msdb..sysjobschedules sjs ON sjs.job_id = sj.job_id
JOIN msdb..sysschedules ss ON sjs.schedule_id = ss.schedule_id
WHERE ss.freq_type = 64 -- Start when SQL Server starts