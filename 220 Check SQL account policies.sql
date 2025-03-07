-- Check settings for the SQL accounts

SELECT name AS [SQLlogin],
       is_policy_checked,
       is_expiration_checked
  FROM sys.sql_logins
 WHERE name <> 'sa'
   AND name NOT LIKE '##%'
   AND (is_policy_checked = 0 OR is_expiration_checked = 0)
 ORDER BY name;