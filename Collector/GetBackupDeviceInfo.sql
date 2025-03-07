SELECT
    bs.database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    bs.server_name, 
    bs.user_name,
    bs.type,
    bm.physical_device_name 
FROM msdb.dbo.backupset AS bs 
        INNER JOIN msdb.dbo.backupmediafamily AS bm 
                ON bs.media_set_id = bm.media_set_id;
GO

SELECT TOP 100
        s.server_name ,
        s.database_name ,
        s.recovery_model,
        CASE s.[type]
          WHEN 'D' THEN 'Full'
          WHEN 'I' THEN 'Differential'
          WHEN 'L' THEN 'Transaction Log'
        END AS BackupType ,  
        s.name,
        s.description,
        CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize ,
        CAST(DATEDIFF(SECOND, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4))
        + ' ' + 'Seconds' TimeTaken ,
        s.backup_start_date
FROM    msdb.dbo.backupset s
        INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE   
--	s.database_name = DB_NAME() -- Remove this line for all the database
--AND 
	s.backup_start_date > GETDATE() - 01
ORDER BY backup_start_date DESC ,
        backup_finish_date;
GO