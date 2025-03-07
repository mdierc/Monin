--**********************************************************************************************************************
--* Description: If lock pages in memory is enabled, the value will be greater than 0.                                 *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON;

SELECT      DISTINCT (   SELECT service_account
                           FROM sys.dm_server_services
                          WHERE servicename LIKE 'SQL Server (%') AS [Service account],
                     'Disabled' AS [Lock pages in memory]
  FROM      sys.dm_os_memory_nodes MN
 INNER JOIN sys.dm_os_nodes N
    ON MN.memory_node_id = N.memory_node_id
 WHERE      N.node_state_desc        <> 'ONLINE DAC'
   AND      MN.locked_page_allocations_kb = 0
 ORDER BY 1;