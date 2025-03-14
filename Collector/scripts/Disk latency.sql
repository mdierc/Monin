/*********************************************************************************************************************
* Description: Show some general information about the server.                                                       
*********************************************************************************************************************
* Modified by             Date       Description/Features added                                                      
* ----------------------- ---------- ------------------------------------------------------------------------------- 
* PX					  2025/03/05 First version                                                                  
*********************************************************************************************************************/

DECLARE @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

SELECT
         @MachineName AS [Server Name],
         tab.[Drive],
         tab.volume_mount_point AS [Volume Mount Point],
         CASE WHEN num_of_reads = 0 THEN 0
              ELSE (io_stall_read_ms / num_of_reads)
         END AS [Read Latency],
         CASE WHEN num_of_writes = 0 THEN 0
              ELSE (io_stall_write_ms / num_of_writes)
         END AS [Write Latency],
         CASE WHEN (
                      num_of_reads = 0
                      AND num_of_writes = 0
                   ) THEN 0
              ELSE (io_stall / (num_of_reads + num_of_writes))
         END AS [Overall Latency],
         CASE WHEN num_of_reads = 0 THEN 0
              ELSE (num_of_bytes_read / num_of_reads)
         END AS [Avg Bytes/Read],
         CASE WHEN num_of_writes = 0 THEN 0
              ELSE (num_of_bytes_written / num_of_writes)
         END AS [Avg Bytes/Write],
         CASE WHEN (
                      num_of_reads = 0
                      AND num_of_writes = 0
                   ) THEN 0
              ELSE
         ((num_of_bytes_read + num_of_bytes_written)
          / (num_of_reads + num_of_writes)
         )
         END AS [Avg Bytes/Transfer]
FROM     (
            SELECT
                     LEFT(UPPER(mf.physical_name), 2) AS Drive,
                     SUM(num_of_reads) AS num_of_reads,
                     SUM(io_stall_read_ms) AS io_stall_read_ms,
                     SUM(num_of_writes) AS num_of_writes,
                     SUM(io_stall_write_ms) AS io_stall_write_ms,
                     SUM(num_of_bytes_read) AS num_of_bytes_read,
                     SUM(num_of_bytes_written) AS num_of_bytes_written,
                     SUM(io_stall) AS io_stall,
                     vs.volume_mount_point
            FROM     sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
                     INNER JOIN sys.master_files AS mf WITH (NOLOCK) ON vfs.database_id = mf.database_id
                                                                        AND vfs.file_id = mf.file_id
                     CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.[file_id]) AS vs
            GROUP BY LEFT(UPPER(mf.physical_name), 2),
                     vs.volume_mount_point
         ) AS tab
ORDER BY [Overall Latency]
OPTION (RECOMPILE);
