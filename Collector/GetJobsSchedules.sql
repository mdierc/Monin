-- list jobs and schedule info with daily and weekly schedules

-- jobs with no schedule
SELECT 
	@@SERVICENAME AS InstanceName
	, j.name JobName
	, j.enabled [Enabled]
	, ISNULL(s.name, '') AS ScheduleName
	, ISNULL(s.freq_recurrence_factor, '') AS FreqRecurrenceFactor
	, 'No Schedule' AS [Frequency]
	, '' AS [Days]
	, '' AS [Time] 
FROM msdb.dbo.sysjobs AS j 
	LEFT OUTER JOIN msdb.dbo.sysjobschedules AS js 
		ON js.job_id = j.job_id
	LEFT OUTER JOIN msdb.dbo.sysschedules AS s 
		ON s.schedule_id = js.schedule_id
WHERE s.freq_type IS NULL 

UNION 

-- jobs with a daily schedule
SELECT 
	@@SERVICENAME AS InstanceName
	, j.name JobName
	, j.enabled [Enabled]
	, s.name AS ScheduleName
	, s.freq_recurrence_factor AS FreqRecurrenceFactor
	, CASE
		WHEN freq_type = 4 THEN 'Daily' 
	END [Frequency]
	, 'Every ' + CAST(s.freq_interval AS varchar(3)) + ' day(s)' AS [Days]
	, CASE 
		WHEN s.freq_subday_type = 2 THEN ' every ' + CAST(s.freq_subday_interval AS varchar(7)) 
			+ ' seconds' + ' starting at ' 
			+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
		WHEN s.freq_subday_type = 4 THEN ' every ' + CAST(s.freq_subday_interval AS varchar(7)) 
			+ ' minutes' + ' starting at ' 
			+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
		WHEN s.freq_subday_type = 8 THEN ' every ' + CAST(s.freq_subday_interval AS varchar(7)) 
			+ ' hours'   + ' starting at ' 
			+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
		ELSE ' starting at ' 
			+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
	END AS [Time] 
FROM msdb.dbo.sysjobs AS j 
	INNER JOIN msdb.dbo.sysjobschedules AS js 
		ON js.job_id = j.job_id 
	INNER JOIN msdb.dbo.sysschedules AS s 
		ON s.schedule_id = js.schedule_id 
WHERE s.freq_type = 4 

UNION 

-- jobs with a weekly schedule
SELECT 
	@@SERVICENAME AS InstanceName
	, j.name JobName
	, j.enabled [Enabled]
	, s.name AS ScheduleName
	, s.freq_recurrence_factor AS FreqRecurrenceFactor
	, CASE 
		WHEN s.freq_type = 8 THEN 'Weekly' 
	END AS [Frequency]
	, REPLACE(
		CASE WHEN s.freq_interval & 1 = 1 THEN 'Sunday, ' ELSE '' END 
		+ CASE WHEN s.freq_interval & 2 = 2 THEN 'Monday, ' ELSE '' END 
		+ CASE WHEN s.freq_interval & 4 = 4 THEN 'Tuesday, ' ELSE '' END 
		+ CASE WHEN s.freq_interval & 8 = 8 THEN 'Wednesday, ' ELSE '' END 
		+ CASE WHEN s.freq_interval & 16 = 16 THEN 'Thursday, ' ELSE '' END 
		+ CASE WHEN s.freq_interval & 32 = 32 THEN 'Friday, ' ELSE '' END 
		+ CASE WHEN s.freq_interval & 64 = 64 THEN 'Saturday, ' ELSE '' END 
		, ', '
		, ''
	) AS [Days]
	, CASE 
		WHEN s.freq_subday_type = 2 THEN ' every ' + cast(s.freq_subday_interval AS varchar(7)) 
			+ ' seconds' + ' starting at ' 
			+ stuff(stuff(RIGHT(replicate('0', 6) + cast(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
		WHEN s.freq_subday_type = 4 THEN ' every ' + cast(s.freq_subday_interval AS varchar(7)) 
			+ ' minutes' + ' starting at ' 
			+ stuff(stuff(RIGHT(replicate('0', 6) + cast(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
		WHEN s.freq_subday_type = 8 THEN ' every ' + cast(s.freq_subday_interval AS varchar(7)) 
			+ ' hours' + ' starting at ' 
			+ stuff(stuff(RIGHT(replicate('0', 6) + cast(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
		ELSE ' starting at ' 
			+ stuff(stuff(RIGHT(replicate('0', 6) + cast(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
	END [Time] 
FROM msdb.dbo.sysjobs AS j 
	INNER JOIN msdb.dbo.sysjobschedules AS js 
		ON js.job_id = j.job_id 
	INNER JOIN msdb.dbo.sysschedules AS s 
		ON s.schedule_id = js.schedule_id 
WHERE s.freq_type = 8 
ORDER BY 1, 2, 3;
