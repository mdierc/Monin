/*
***********************************************************************************************************************
DESCRIPTION:
Get the QueryStore Information
***********************************************************************************************************************
Modified by               Date       Description/Features added                                                      
------------------------- ---------- ----------------------------------------------------------------------------------
Christophe Platteeuw	  2025-02-13 First version
***********************************************************************************************************************
*/

SET NOCOUNT ON;

/*Define version*/
DECLARE
   @ProductVersion NVARCHAR(128),
   @ProductVersionMajor DECIMAL(10, 2),
   @ProductVersionMinor DECIMAL(10, 2);

SET @ProductVersion = CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128));

SELECT
   @ProductVersionMajor = SUBSTRING(
                                      @ProductVersion,
                                      1,
                                      CHARINDEX('.', @ProductVersion) + 1
                                   ),
   @ProductVersionMinor = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 2);

/*Variables*/
DECLARE @sql NVARCHAR(MAX) = N'', @sqltoexecuteperversion NVARCHAR(MAX) = '';

/*Drop temp table if needed*/
IF OBJECT_ID('tempdb..#GetQueryStoreOptions') IS NOT NULL
   EXEC sp_executesql N'DROP TABLE #GetQueryStoreOptions;';

/*Create temp table*/
CREATE TABLE #GetQueryStoreOptions
(
   [database_name] sysname NULL,
   [desired_state] [SMALLINT] NULL,
   [desired_state_desc] [NVARCHAR](60) NULL,
   [actual_state] [SMALLINT] NULL,
   [actual_state_desc] [NVARCHAR](60) NULL,
   [readonly_reason] [INT] NULL,
   [current_storage_size_mb] [BIGINT] NULL,
   [flush_interval_seconds] [BIGINT] NULL,
   [interval_length_minutes] [BIGINT] NULL,
   [max_storage_size_mb] [BIGINT] NULL,
   [stale_query_threshold_days] [BIGINT] NULL,
   [max_plans_per_query] [BIGINT] NULL,
   [query_capture_mode] [SMALLINT] NULL,
   [query_capture_mode_desc] [NVARCHAR](60) NULL,
   [capture_policy_execution_count] [INT] NULL,
   [capture_policy_total_compile_cpu_time_ms] [BIGINT] NULL,
   [capture_policy_total_execution_cpu_time_ms] [BIGINT] NULL,
   [capture_policy_stale_threshold_hours] [INT] NULL,
   [size_based_cleanup_mode] [SMALLINT] NULL,
   [size_based_cleanup_mode_desc] [NVARCHAR](60) NULL,
   [wait_stats_capture_mode] [SMALLINT] NULL,
   [wait_stats_capture_mode_desc] [NVARCHAR](60) NULL,
   [actual_state_additional_info] [NVARCHAR](4000) NULL,
   [free_size_mb] BIGINT NULL,
   [free_size_percentage] DECIMAL(5, 2),
);


/*Define SQL per version*/
SELECT @sqltoexecuteperversion= CASE 
	WHEN @ProductVersionMajor < 13
		THEN N'
		SELECT DB_NAME() AS DatabaseName,
-1,
''N/A'',
-1,
''N/A'',
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL;
		'
	WHEN @ProductVersionMajor = 13	/*2016*/
		THEN N'
		SELECT DB_NAME() AS DatabaseName,
desired_state,
desired_state_desc,
actual_state,
actual_state_desc,
readonly_reason,
current_storage_size_mb,
flush_interval_seconds,
interval_length_minutes,
max_storage_size_mb,
stale_query_threshold_days,
max_plans_per_query,
query_capture_mode,
query_capture_mode_desc,
NULL,
NULL,
NULL,
NULL,
size_based_cleanup_mode,
size_based_cleanup_mode_desc,
NULL,
''N/A'',
actual_state_additional_info,
max_storage_size_mb - current_storage_size_mb AS FreeSizeMB,
100 - (current_storage_size_mb / 1.0 / max_storage_size_mb) AS FreeSizePercent
FROM sys.database_query_store_options;
		'
		WHEN @ProductVersionMajor = 14	/*2017*/
		THEN N'
		SELECT DB_NAME() AS DatabaseName,
desired_state,
desired_state_desc,
actual_state,
actual_state_desc,
readonly_reason,
current_storage_size_mb,
flush_interval_seconds,
interval_length_minutes,
max_storage_size_mb,
stale_query_threshold_days,
max_plans_per_query,
query_capture_mode,
query_capture_mode_desc,
NULL,
NULL,
NULL,
NULL,
size_based_cleanup_mode,
size_based_cleanup_mode_desc,
wait_stats_capture_mode,
wait_stats_capture_mode_desc,
actual_state_additional_info,
max_storage_size_mb - current_storage_size_mb AS FreeSizeMB,
100 - (current_storage_size_mb / 1.0 / max_storage_size_mb) AS FreeSizePercent
FROM sys.database_query_store_options;
		'
		WHEN @ProductVersionMajor = 15	/*2019*/
		THEN N'
SELECT DB_NAME() AS DatabaseName,
desired_state,
desired_state_desc,
actual_state,
actual_state_desc,
readonly_reason,
current_storage_size_mb,
flush_interval_seconds,
interval_length_minutes,
max_storage_size_mb,
stale_query_threshold_days,
max_plans_per_query,
query_capture_mode,
query_capture_mode_desc,
capture_policy_execution_count,
capture_policy_total_compile_cpu_time_ms,
capture_policy_total_execution_cpu_time_ms,
capture_policy_stale_threshold_hours,
size_based_cleanup_mode,
size_based_cleanup_mode_desc,
wait_stats_capture_mode,
wait_stats_capture_mode_desc,
actual_state_additional_info,
max_storage_size_mb - current_storage_size_mb AS FreeSizeMB,
100 - (current_storage_size_mb / 1.0 / max_storage_size_mb) AS FreeSizePercent
FROM sys.database_query_store_options;
		'
		WHEN @ProductVersionMajor = 16	/*2022*/
		THEN N'
SELECT DB_NAME() AS DatabaseName,
desired_state,
desired_state_desc,
actual_state,
actual_state_desc,
readonly_reason,
current_storage_size_mb,
flush_interval_seconds,
interval_length_minutes,
max_storage_size_mb,
stale_query_threshold_days,
max_plans_per_query,
query_capture_mode,
query_capture_mode_desc,
capture_policy_execution_count,
capture_policy_total_compile_cpu_time_ms,
capture_policy_total_execution_cpu_time_ms,
capture_policy_stale_threshold_hours,
size_based_cleanup_mode,
size_based_cleanup_mode_desc,
wait_stats_capture_mode,
wait_stats_capture_mode_desc,
actual_state_additional_info,
max_storage_size_mb - current_storage_size_mb AS FreeSizeMB,
100 - (current_storage_size_mb / 1.0 / max_storage_size_mb) AS FreeSizePercent
FROM sys.database_query_store_options;
		'
		WHEN @ProductVersionMajor = 17	/*2025*/
		THEN N'
SELECT DB_NAME() AS DatabaseName,
desired_state,
desired_state_desc,
actual_state,
actual_state_desc,
readonly_reason,
current_storage_size_mb,
flush_interval_seconds,
interval_length_minutes,
max_storage_size_mb,
stale_query_threshold_days,
max_plans_per_query,
query_capture_mode,
query_capture_mode_desc,
capture_policy_execution_count,
capture_policy_total_compile_cpu_time_ms,
capture_policy_total_execution_cpu_time_ms,
capture_policy_stale_threshold_hours,
size_based_cleanup_mode,
size_based_cleanup_mode_desc,
wait_stats_capture_mode,
wait_stats_capture_mode_desc,
actual_state_additional_info,
max_storage_size_mb - current_storage_size_mb AS FreeSizeMB,
100 - (current_storage_size_mb / 1.0 / max_storage_size_mb) AS FreeSizePercent
FROM sys.database_query_store_options;
		'
	END

/*Make sql to execute*/
SELECT 
	@sql += 
	N'USE '+QUOTENAME(d.name)+'' + @sqltoexecuteperversion

   FROM     sys.databases d
   WHERE    d.state_desc = 'ONLINE'
            AND database_id > 4
   ORDER BY d.name;

/*Exectute dyn. SQL*/
INSERT INTO #GetQueryStoreOptions
EXEC sp_executesql @sql;

/*Resultset*/
SELECT *
FROM   #GetQueryStoreOptions;

/*Cleanup*/
DROP TABLE #GetQueryStoreOptions;

/*end*/

