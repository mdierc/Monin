--****************************************************************************************************************************
--* Description:                                                                                                             *
--* Check the minimum & maximum memory settings                                                                              *
--*                                                                                                                          *
--* The recommendation uses this formula:                                                                                    *
--*                                                                                                                          *
--*     1 GB of memory reserved for the OS.                                                                                  *
--*     1 GB each for every 4 GB of RAM after the initial 4 GB, up to 16 GB of RAM.                                          *
--*     1 GB each for every 8 GB in more than 16 GB of RAM.                                                                  *
--*                                                                                                                          *
--* For example, if you have a 32 GB RAM Database Server, then memory to be given to Operating System would be 6 GB:         *
--*                                                                                                                          *
--*     1 GB, the minimum allocation                                                                                         *
--*     + 3 GB, since 16 GB – 4 GB = 12 GB; 12 GB divided by 4 GB (each 4 GB gets 1 GB) is 3GB.                              *
--*     + 2 GB, as 32 GB – 16 GB = 16 GB; 16 divided by 8 (each 8 GB after 16 GB gets 1 GB) is 2 GB                          *
--*                                                                                                                          *
--* Nevertheless, 4 Gb should be the minimum for the OS as this leaves enough resources for e.g. remote session, MSTSC, etc. *
--****************************************************************************************************************************
--* Modified by             Date       Description/Features added                                                            *
--* ----------------------- ---------- ------------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                        *
--* Chris Vandekerkhove     31/01/2023 Simplified formula for maximum memory.                                                *
--* Chris Vandekerkhove     08/12/2023 Executing sp_configure cannot be executed if a Contained Availability Group exist.    *
--* Chris Vandekerkhove     14/11/2023 Show if the server is a primary/secondary node of a failover cluster.                 *
--****************************************************************************************************************************

SET NOCOUNT ON;

DECLARE @tb_temp TABLE (name VARCHAR(255),
                        minimum INT,
                        maximum INT,
                        config_value INT,
                        run_value INT);
DECLARE @MinimumMemory        INT,
        @MaximumMemory        INT,
        @TotalMemory          INT,
        @ShowAdvancedSettings INT,
        @MemoryForOS          INT,
        @RecommendedMin       INT,
		 @Edition VARCHAR(255),
        @Nodename sysname;


INSERT @tb_temp (name,
                 minimum,
                 maximum,
                 config_value,
                 run_value)
EXEC sp_configure 'show advanced options';
SET @ShowAdvancedSettings = (SELECT run_value / 1024 FROM @tb_temp);
DELETE @tb_temp;
IF @ShowAdvancedSettings = 0
BEGIN
    BEGIN TRY
        DECLARE @CmdStr VARCHAR(1024);
        SET @CmdStr = 'exec sp_configure ''show advanced options'', 1;';
        EXEC (@CmdStr);
        RECONFIGURE;
    END TRY
    BEGIN CATCH
        DECLARE @MessageStr VARCHAR(1024);
        SET @MessageStr = 'Could not access memory settings: ' + ERROR_MESSAGE();
        RAISERROR(@MessageStr, 16, 1);
        RETURN;
    END CATCH;
END;


-- Get total memory in GB
SELECT @TotalMemory = CONVERT(INT, ROUND(total_physical_memory_kb * 1.0 / 1024.0 / 1024.0, 1))
  FROM sys.dm_os_sys_memory;


-- Get minimum memory in GB
INSERT @tb_temp (name,
                 minimum,
                 maximum,
                 config_value,
                 run_value)
EXEC sp_configure 'min server memory (MB)';
SET @MinimumMemory = (SELECT run_value / 1024 FROM @tb_temp);
DELETE @tb_temp;

-- Get maximum memory in GB
INSERT @tb_temp (name,
                 minimum,
                 maximum,
                 config_value,
                 run_value)
EXEC sp_configure 'max server memory (MB)';
SET @MaximumMemory = (SELECT run_value / 1024 FROM @tb_temp);
DELETE @tb_temp;
IF @ShowAdvancedSettings = 0
BEGIN
    EXEC sp_configure 'show advanced options', 0;
    RECONFIGURE;
END;

SET @MemoryForOS = 4;
SET @RecommendedMin = (@TotalMemory - @MemoryForOS) / 4;


PRINT 'Leave ' + CONVERT(VARCHAR, @MemoryForOS) + ' Gb free for the OS.';

SET @Edition = CONVERT(VARCHAR(255), SERVERPROPERTY('Edition'));
SET @Edition = SUBSTRING(@Edition, 1, CHARINDEX(' ', @Edition) - 1);
SET @Nodename = (SELECT TOP 1 NodeName FROM sys.dm_os_cluster_nodes ORDER BY NodeName)
SET @Nodename = ISNULL(@Nodename,'N/A')


SELECT @TotalMemory AS [RAM],
       @MinimumMemory AS [Min.], 
       @RecommendedMin AS [Rec. Min.],
       @MaximumMemory AS [Max],
       @TotalMemory - @MemoryForOS AS [Rec. Max.],
       @Nodename AS [Node],
       @Edition AS Edition;

