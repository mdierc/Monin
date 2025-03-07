/*********************************************************************************************************************
* Description: Show power mode of the server, this always should be high performance                                                  
*********************************************************************************************************************
* Modified by				Date		Description/Features added                                                      
* -----------------------	----------	-------------------------------------------------------------------------------                                                                 
* PX						2025-02-05	First version                                                              
* PX						2025-02-19	Fixed typo in result set
*********************************************************************************************************************/

SET NOCOUNT ON;


DECLARE @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;

DECLARE @powerScheme VARCHAR(36);


/* Get power plan if set by group policy [Git Hub Issue #1620] */
EXEC xp_regread
   @rootkey = N'HKEY_LOCAL_MACHINE',
   @key = N'SOFTWARE\Policies\Microsoft\Power\PowerSettings',
   @value_name = N'ActivePowerScheme',
   @value = @powerScheme OUTPUT,
   @no_output = N'no_output';

IF @powerScheme IS NULL /* If power plan was not set by group policy, get local value [Git Hub Issue #1620]*/
   EXEC xp_regread
      @rootkey = N'HKEY_LOCAL_MACHINE',
      @key = N'SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes',
      @value_name = N'ActivePowerScheme',
      @value = @powerScheme OUTPUT;

SELECT
   @MachineName AS [Server Name],
   CASE @powerScheme
        WHEN 'a1841308-3541-4fab-bc81-f71556f20b4a' THEN 'Power saving mode'
        WHEN '381b4222-f694-41f0-9685-ff5bb260df2e' THEN
           'Balanced power mode'
        WHEN '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' THEN
           'High performance power mode'
        WHEN 'e9a42b02-d5df-448d-aa00-03f14749eb61' THEN
           'Ultimate performance power mode'
        ELSE 'an unknown power mode.'
   END AS [Power Scheme];