--**********************************************************************************************************************
--* Description: Generate SELECT statement to change the page verification to CHECKSUM.                                *
--**********************************************************************************************************************
--* Modified by             Date       Description/Features added                                                      *
--* ----------------------- ---------- ------------------------------------------------------------------------------- *
--* SQL Team                ?          First version.                                                                  *
--**********************************************************************************************************************

SET NOCOUNT ON

SELECT name AS [Database], 
	page_verify_option_desc AS 'Page Verification', 
	'ALTER DATABASE ' + QUOTENAME(name) + ' SET PAGE_VERIFY CHECKSUM WITH NO_WAIT;' AS ModifyScript
FROM sys.databases
WHERE ISNULL(page_verify_option_desc, 'NONE') IN ( 'NONE', 'TORN_PAGE_DETECTION' );
