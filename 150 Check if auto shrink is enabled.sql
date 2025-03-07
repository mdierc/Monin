--**********************************************************************************************************************
--* Description:  Check for databases which have auto shrink enabled.                                                  *                                                                                                     *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--*  Maarten Dierckxsens       26/11/2020  First version.                                                              *
--**********************************************************************************************************************

SET NOCOUNT ON

SELECT @@SERVERNAME AS [Server],
       d.name AS [DatabaseName],
       d.is_auto_shrink_on AS [Auto Shrink On]
  FROM sys.databases d
 WHERE d.state_desc        = 'ONLINE'
   AND d.is_auto_shrink_on = 1;