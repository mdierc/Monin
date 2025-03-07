--*****************************************************************************************************************************
--* Description: Check for databases which have auto close enabled.                                                           *
--*****************************************************************************************************************************
--* Modified by               Date        Description/Features added                                                          *
--* -----------------------   ----------  -------------------------------------------------------------------------------     *
--* Maarten Dierckxsens       26/11/2020  First version.                                                                      *
-- ****************************************************************************************************************************

SET NOCOUNT ON

SELECT @@SERVERNAME AS [Server],
       d.name AS [DatabaseName],
       d.is_auto_close_on AS [Auto Close On]
  FROM sys.databases d
 WHERE d.state_desc       = 'ONLINE'
   AND d.is_auto_close_on = 1;