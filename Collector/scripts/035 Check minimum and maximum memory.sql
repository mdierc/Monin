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
--* Peter Kruis     05/02/2025 Just retrieve data from sys.configurations, also changed calculation to 4GB or 10%    *
--****************************************************************************************************************************

SET NOCOUNT ON;

DECLARE
   @MinimumMemory INT,
   @MaximumMemory INT,
   @TotalMemory INT,
   @ShowAdvancedSettings INT,
   @MemoryForOS INT,
   @MachineName NVARCHAR(128);


DECLARE @InstanceCount AS INT;
DECLARE @RecommendedMinimum AS INT;
DECLARE @RecommendedMaximum AS INT;

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

SELECT @TotalMemory = (total_physical_memory_kb / 1024) + 1
FROM   sys.dm_os_sys_memory;

/*
CALCULATE THE MEMORY FOR OS
1 GB of memory reserved for the OS
1 GB each for every 4 GB of RAM after the initial 4 GB, up to 16 GB of RAM
1 GB each for every 8 GB in more than 16 GB of RAM
*/

SET @TotalMemory = @TotalMemory;

IF (@TotalMemory <= 4096)
   SET @MemoryForOS = 4096;
IF (
      @TotalMemory > 4096
      AND @TotalMemory <= 16384
   )
   SET @MemoryForOS = 1024 + ((@TotalMemory - 4096) / 4);
IF (@TotalMemory > 16384)
   SET @MemoryForOS = 4096 + ((@TotalMemory - 16384) / 8);


/*GET INSTANCES ON THIS COMPUTER*/
SELECT   @InstanceCount = COUNT(*)
FROM     sys.dm_server_services
WHERE    servicename LIKE 'SQL Server (%'
GROUP BY servicename;

/*CALCULATE NEW MIN/MAX MEMORY*/
SELECT @RecommendedMinimum = (@TotalMemory - @MemoryForOS) / 4;
SELECT @RecommendedMaximum = (@TotalMemory - @MemoryForOS);

/*Retrieve current used minimum*/
SELECT @MinimumMemory = CAST(c.value_in_use AS INT) / 1024
FROM   sys.configurations AS c
WHERE  c.name = 'min server memory (MB)';

/*Retrieve current used maximum*/
SELECT @MaximumMemory = CAST(c.value_in_use AS INT) / 1024
FROM   sys.configurations AS c
WHERE  c.name = 'max server memory (MB)';

/*Bij meer dan 1 instantie laten we de Recommendations leeg, deze zijn dan niet automatisch te bepalen*/
SELECT
   @MachineName AS [Server Name],
   @TotalMemory / 1024 AS [Total memory],
   @InstanceCount AS Instances,
   @MemoryForOS / 1024 AS [Rec. OS],
   @MinimumMemory AS [Minimum memory],
   @MaximumMemory AS [Maximum memory],
   CASE WHEN @InstanceCount = 1 THEN @RecommendedMinimum / 1024 ELSE CAST(NULL AS INT) END AS [Rec. Min],
   CASE WHEN @InstanceCount = 1 THEN @RecommendedMaximum / 1024 ELSE CAST(NULL AS INT) END AS [Rec. Max],
   SERVERPROPERTY('edition') AS Edition;


