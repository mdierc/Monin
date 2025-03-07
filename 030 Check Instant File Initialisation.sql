--**********************************************************************************************************************
--* Description: Check if instant file initialisation is enabled.                                                      *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON;

IF RIGHT(@@version, LEN(@@version) - 3 - CHARINDEX(' ON ', @@VERSION)) NOT LIKE 'Windows%'
    BEGIN
        SELECT  
                
                LEFT(@@VERSION, CHARINDEX('-', @@VERSION) - 2) + ' '
                + CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(300)) AS [SQL Server Version] ,
                'N/A' AS [service_account] ,
                'N/A' AS [instant_file_initialization_enabled]
    END
ELSE
    BEGIN
        IF EXISTS ( SELECT  0
                    FROM    sys.all_objects AO
                            INNER JOIN sys.all_columns AC ON AC.object_id = AO.object_id
                    WHERE   AO.name LIKE '%dm_server_services%'
                            AND AC.name = 'instant_file_initialization_enabled' )
            BEGIN
                EXEC('   SELECT  
                
                LEFT(@@VERSION, CHARINDEX(''-'', @@VERSION) - 2)  + '' '' +  CAST(SERVERPROPERTY(''ProductVersion'') AS NVARCHAR(300) ) AS [SQL Server Version],
                service_account ,
                instant_file_initialization_enabled
                FROM    sys.dm_server_services
                WHERE   servicename LIKE ''SQL Server (%'' AND instant_file_initialization_enabled <> ''Y''')
            END
        ELSE
            BEGIN
                SELECT  
                        
                        LEFT(@@VERSION, CHARINDEX('-', @@VERSION) - 2) + ' '
                        + CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(300)) AS [SQL Server Version] ,
                        service_account AS [service_account] ,
                        'N/A' AS [instant_file_initialization_enabled]
                FROM    sys.dm_server_services
                WHERE   servicename LIKE 'SQL Server (%'
            END  
    END
