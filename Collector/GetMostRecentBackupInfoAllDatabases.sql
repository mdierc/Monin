WITH MostRecentBackups AS 
(
    SELECT 
		[Database] = database_name
        , LastBackupTime = MAX(bus.backup_finish_date)
        , [Type] = CASE bus.type
					WHEN 'D' THEN 'Full'
					WHEN 'I' THEN 'Differential'
					WHEN 'L' THEN 'Transaction Log'
				END
		, CopyOnly = bus.is_copy_only
    FROM msdb.dbo.backupset AS bus 
    WHERE 
		bus.type <> 'F' 
    GROUP BY 
		bus.database_name
		, bus.type
		, bus.is_copy_only
),
BackupsWithSize AS 
(
    SELECT 
		mrb.*
		, [Backup Size] = (SELECT TOP 1 CONVERT(DECIMAL(10,4), b.backup_size/1024/1024/1024) AS backup_size FROM msdb.dbo.backupset b WHERE [Database] = b.database_name AND LastBackupTime = b.backup_finish_date) 
    FROM MostRecentBackups AS mrb
)
SELECT 
    Instance = SERVERPROPERTY('ServerName')
    , [Database] = d.name
    , [State] = d.state_desc
    , [Recovery Model] = d.recovery_model_desc
	, bf.CopyOnly
    , [Last Full] = bf.LastBackupTime
    , [Time Since Last Full (in Days)] = DATEDIFF(DAY,bf.LastBackupTime,GETDATE())
    , [Full Backup Size] = bf.[Backup Size]
    , [Last Differential] = bd.LastBackupTime
    , [Time Since Last Differential (in Days)] = DATEDIFF(DAY,bd.LastBackupTime,GETDATE())
    , [Differential Backup Size] = bd.[Backup Size]
    , [Last Transaction Log] = bt.LastBackupTime
    , [Time Since Last Transaction Log (in Minutes)] = DATEDIFF(MINUTE,bt.LastBackupTime,GETDATE())
    , [Transaction Log Backup Size] = bt.[Backup Size]
FROM sys.databases d 
	LEFT OUTER JOIN BackupsWithSize AS bf 
		ON d.name = bf.[Database] AND (bf.Type = 'Full' OR bf.Type IS NULL) 
	LEFT OUTER JOIN BackupsWithSize AS bd 
		ON d.name = bd.[Database] AND (bd.Type = 'Differential' OR bd.Type IS NULL)
	LEFT OUTER JOIN BackupsWithSize AS bt 
		ON d.name = bt.[Database] AND (bt.Type = 'Transaction Log' OR bt.Type IS NULL) 
WHERE 
	d.name <> 'tempdb' 
	AND 
	d.source_database_id IS NULL;