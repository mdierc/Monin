/**********************************************************************************************************************
Description: Show version information.                                                                             
*******************************************************************************************************************
Modified by             Date       Description/Features added                                                      
----------------------- ---------- ------------------------------------------------------------------------------- 
SQL Team                ?          First version.                                                                  
PX		                2024-06-25 Added additional columns

TODO for HC
- Make sure that Dangerous versions are named and a point for improvement
- Update the versions once in a while

**********************************************************************************************************************/

SET NOCOUNT ON;

DECLARE
   @ProductVersion NVARCHAR(128),
   @ProductVersionMajor DECIMAL(10, 2),
   @ProductVersionMinor DECIMAL(10, 2),
   @DangerousVersionCorruption BIT = 0,
   @DangerousVersionSecurity BIT = 0,
   @ExtendedSupportEndDate DATE,
   @MinorVersionAvailable VARCHAR(67),
   @MachineName NVARCHAR(128);

SELECT
   @MachineName = CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + N'\'
                  + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL THEN
                            @@SERVICENAME
                         ELSE
                            CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))
                    END;



SET @ProductVersion = CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128));

SELECT
   @ProductVersionMajor = SUBSTRING(
                                      @ProductVersion,
                                      1,
                                      CHARINDEX('.', @ProductVersion) + 1
                                   ),
   @ProductVersionMinor = PARSENAME(CONVERT(VARCHAR(32), @ProductVersion), 2);

/*Temporary table with the current known versions (Source: script SqlServerVersions.sql Brent Ozar first responder kit. Downloaded 2025-01-06)*/
CREATE TABLE #SqlServerVersions
(
   MajorVersionNumber TINYINT NOT NULL,
   MinorVersionNumber SMALLINT NOT NULL,
   Branch VARCHAR(34) NOT NULL,
   [Url] VARCHAR(99) NOT NULL,
   ReleaseDate DATE NOT NULL,
   MainstreamSupportEndDate DATE NOT NULL,
   ExtendedSupportEndDate DATE NOT NULL,
   MajorVersionName VARCHAR(19) NOT NULL,
   MinorVersionName VARCHAR(67) NOT NULL,
   CONSTRAINT PK_SqlServerVersions
      PRIMARY KEY CLUSTERED (
                               MajorVersionNumber ASC,
                               MinorVersionNumber ASC,
                               ReleaseDate ASC
                            )
);

-- SQL Prompt formatting off
INSERT INTO #SqlServerVersions
(
    MajorVersionNumber,
    MinorVersionNumber,
    Branch,
    [Url],
    ReleaseDate,
    MainstreamSupportEndDate,
    ExtendedSupportEndDate,
    MajorVersionName,
    MinorVersionName
)
VALUES
    /*2022*/
    (16, 4165, 'CU16', 'https://support.microsoft.com/en-us/help/5048033', '2024-11-14', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 16'),
    (16, 4150, 'CU15 GDR', 'https://support.microsoft.com/en-us/help/5046059', '2024-10-08', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 15 GDR'),
    (16, 4145, 'CU15', 'https://support.microsoft.com/en-us/help/5041321', '2024-09-25', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 15'),
    (16, 4140, 'CU14 GDR', 'https://support.microsoft.com/en-us/help/5042578', '2024-09-10', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 14 GDR'),
    (16, 4135, 'CU14', 'https://support.microsoft.com/en-us/help/5038325', '2024-07-23', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 14'),
    (16, 4125, 'CU13', 'https://support.microsoft.com/en-us/help/5036432', '2024-05-16', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 13'),
    (16, 4115, 'CU12', 'https://support.microsoft.com/en-us/help/5033663', '2024-03-14', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 12'),
    (16, 4105, 'CU11', 'https://support.microsoft.com/en-us/help/5032679', '2024-01-11', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 11'),
    (16, 4100, 'CU10 GDR', 'https://support.microsoft.com/en-us/help/5033592', '2024-01-09', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 10 GDR'),
    (16, 4095, 'CU10', 'https://support.microsoft.com/en-us/help/5031778', '2023-11-16', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 10'),
    (16, 4085, 'CU9', 'https://support.microsoft.com/en-us/help/5030731', '2023-10-12', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 9'),
    (16, 4075, 'CU8', 'https://support.microsoft.com/en-us/help/5029666', '2023-09-14', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 8'),
    (16, 4065, 'CU7', 'https://support.microsoft.com/en-us/help/5028743', '2023-08-10', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 7'),
    (16, 4055, 'CU6', 'https://support.microsoft.com/en-us/help/5027505', '2023-07-13', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 6'),
    (16, 4045, 'CU5', 'https://support.microsoft.com/en-us/help/5026806', '2023-06-15', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 5'),
    (16, 4035, 'CU4', 'https://support.microsoft.com/en-us/help/5026717', '2023-05-11', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 4'),
    (16, 4025, 'CU3', 'https://support.microsoft.com/en-us/help/5024396', '2023-04-13', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 3'),
    (16, 4015, 'CU2', 'https://support.microsoft.com/en-us/help/5023127', '2023-03-15', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 2'),
    (16, 4003, 'CU1', 'https://support.microsoft.com/en-us/help/5022375', '2023-02-16', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'Cumulative Update 1'),
    (16, 1050, 'RTM GDR', 'https://support.microsoft.com/kb/5021522', '2023-02-14', '2028-01-11', '2033-01-11', 'SQL Server 2022 GDR', 'RTM'),
    (16, 1000, 'RTM', '', '2022-11-15', '2028-01-11', '2033-01-11', 'SQL Server 2022', 'RTM'),
    /*2019*/
    (15, 4415, 'CU30', 'https://support.microsoft.com/kb/5049235', '2024-12-13', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 30'),
    (15, 4405, 'CU29', 'https://support.microsoft.com/kb/5046365', '2024-10-31', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 29'),
    (15, 4395, 'CU28 GDR', 'https://support.microsoft.com/kb/5046060', '2024-10-08', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 28 GDR'),
    (15, 4390, 'CU28 GDR', 'https://support.microsoft.com/kb/5042749', '2024-09-10', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 28 GDR'),
    (15, 4385, 'CU28', 'https://support.microsoft.com/kb/5039747', '2024-08-01', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 28'),
    (15, 4375, 'CU27', 'https://support.microsoft.com/kb/5037331', '2024-06-14', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 27'),
    (15, 4365, 'CU26', 'https://support.microsoft.com/kb/5035123', '2024-04-11', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 26'),
    (15, 4355, 'CU25', 'https://support.microsoft.com/kb/5033688', '2024-02-15', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 25'),
    (15, 4345, 'CU24', 'https://support.microsoft.com/kb/5031908', '2023-12-14', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 24'),
    (15, 4335, 'CU23', 'https://support.microsoft.com/kb/5030333', '2023-10-12', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 23'),
    (15, 4322, 'CU22', 'https://support.microsoft.com/kb/5027702', '2023-08-14', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 22'),
    (15, 4316, 'CU21', 'https://support.microsoft.com/kb/5025808', '2023-06-15', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 21'),
    (15, 4312, 'CU20', 'https://support.microsoft.com/kb/5024276', '2023-04-13', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 20'),
    (15, 4298, 'CU19', 'https://support.microsoft.com/kb/5023049', '2023-02-16', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 19'),
    (15, 4280, 'CU18 GDR', 'https://support.microsoft.com/kb/5021124', '2023-02-14', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 18 GDR'),
    (15, 4261, 'CU18', 'https://support.microsoft.com/en-us/help/5017593', '2022-09-28', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 18'),
    (15, 4249, 'CU17', 'https://support.microsoft.com/en-us/help/5016394', '2022-08-11', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 17'),
    (15, 4236, 'CU16 GDR', 'https://support.microsoft.com/en-us/help/5014353', '2022-06-14', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 16 GDR'),
    (15, 4223, 'CU16', 'https://support.microsoft.com/en-us/help/5011644', '2022-04-18', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 16'),
    (15, 4198, 'CU15', 'https://support.microsoft.com/en-us/help/5008996', '2022-01-07', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 15'),
    (15, 4188, 'CU14', 'https://support.microsoft.com/en-us/help/5007182', '2021-11-22', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 14'),
    (15, 4178, 'CU13', 'https://support.microsoft.com/en-us/help/5005679', '2021-10-05', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 13'),
    (15, 4153, 'CU12', 'https://support.microsoft.com/en-us/help/5004524', '2021-08-04', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 12'),
    (15, 4138, 'CU11', 'https://support.microsoft.com/en-us/help/5003249', '2021-06-10', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 11'),
    (15, 4123, 'CU10', 'https://support.microsoft.com/en-us/help/5001090', '2021-04-06', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 10'),
    (15, 4102, 'CU9', 'https://support.microsoft.com/en-us/help/5000642', '2021-02-11', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 9 '),
    (15, 4073, 'CU8 GDR', 'https://support.microsoft.com/en-us/help/4583459', '2021-01-12', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 8 GDR '),
    (15, 4073, 'CU8', 'https://support.microsoft.com/en-us/help/4577194', '2020-10-01', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 8 '),
    (15, 4063, 'CU7', 'https://support.microsoft.com/en-us/help/4570012', '2020-09-02', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 7 '),
    (15, 4053, 'CU6', 'https://support.microsoft.com/en-us/help/4563110', '2020-08-04', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 6 '),
    (15, 4043, 'CU5', 'https://support.microsoft.com/en-us/help/4548597', '2020-06-22', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 5 '),
    (15, 4033, 'CU4', 'https://support.microsoft.com/en-us/help/4548597', '2020-03-31', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 4 '),
    (15, 4023, 'CU3', 'https://support.microsoft.com/en-us/help/4538853', '2020-03-12', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 3 '),
    (15, 4013, 'CU2', 'https://support.microsoft.com/en-us/help/4536075', '2020-02-13', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 2 '),
    (15, 4003, 'CU1', 'https://support.microsoft.com/en-us/help/4527376', '2020-01-07', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'Cumulative Update 1 '),
    (15, 2070, 'GDR', 'https://support.microsoft.com/en-us/help/4517790', '2019-11-04', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'RTM GDR '),
    (15, 2000, 'RTM ', '', '2019-11-04', '2025-01-07', '2030-01-08', 'SQL Server 2019', 'RTM '),
    /*2017*/
    (14, 3485, 'RTM CU31 GDR', 'https://support.microsoft.com/kb/5046858', '2024-11-12', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 31 GDR'),
    (14, 3480, 'RTM CU31 GDR', 'https://support.microsoft.com/kb/5046061', '2024-10-08', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 31 GDR'),
    (14, 3475, 'RTM CU31 GDR', 'https://support.microsoft.com/kb/5042215', '2024-09-10', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 31 GDR'),
    (14, 3471, 'RTM CU31 GDR', 'https://support.microsoft.com/kb/5040940', '2024-07-09', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 31 GDR'),
    (14, 3465, 'RTM CU31 GDR', 'https://support.microsoft.com/kb/5029376', '2023-10-10', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 31 GDR'),
    (14, 3460, 'RTM CU31 GDR', 'https://support.microsoft.com/kb/5021126', '2023-02-14', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 31 GDR'),
    (14, 3456, 'RTM CU31', 'https://support.microsoft.com/en-us/help/5016884', '2022-09-20', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 31'),
    (14, 3451, 'RTM CU30', 'https://support.microsoft.com/en-us/help/5013756', '2022-07-13', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 30'),
    (14, 3445, 'RTM CU29 GDR', 'https://support.microsoft.com/en-us/help/5014553', '2022-06-14', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 29 GDR'),
    (14, 3436, 'RTM CU29', 'https://support.microsoft.com/en-us/help/5010786', '2022-03-31', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 29'),
    (14, 3430, 'RTM CU28', 'https://support.microsoft.com/en-us/help/5006944', '2022-01-13', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 28'),
    (14, 3421, 'RTM CU27', 'https://support.microsoft.com/en-us/help/5006944', '2021-10-27', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 27'),
    (14, 3411, 'RTM CU26', 'https://support.microsoft.com/en-us/help/5005226', '2021-09-14', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 26'),
    (14, 3401, 'RTM CU25', 'https://support.microsoft.com/en-us/help/5003830', '2021-07-12', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 25'),
    (14, 3391, 'RTM CU24', 'https://support.microsoft.com/en-us/help/5001228', '2021-05-10', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 24'),
    (14, 3381, 'RTM CU23', 'https://support.microsoft.com/en-us/help/5000685', '2021-02-25', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 23'),
    (14, 3370, 'RTM CU22 GDR', 'https://support.microsoft.com/en-us/help/4583457', '2021-01-12', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 22 GDR'),
    (14, 3356, 'RTM CU22', 'https://support.microsoft.com/en-us/help/4577467', '2020-09-10', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 22'),
    (14, 3335, 'RTM CU21', 'https://support.microsoft.com/en-us/help/4557397', '2020-07-01', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 21'),
    (14, 3294, 'RTM CU20', 'https://support.microsoft.com/en-us/help/4541283', '2020-04-07', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 20'),
    (14, 3257, 'RTM CU19', 'https://support.microsoft.com/en-us/help/4535007', '2020-02-05', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 19'),
    (14, 3257, 'RTM CU18', 'https://support.microsoft.com/en-us/help/4527377', '2019-12-09', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 18'),
    (14, 3238, 'RTM CU17', 'https://support.microsoft.com/en-us/help/4515579', '2019-10-08', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 17'),
    (14, 3223, 'RTM CU16', 'https://support.microsoft.com/en-us/help/4508218', '2019-08-01', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 16'),
    (14, 3162, 'RTM CU15', 'https://support.microsoft.com/en-us/help/4498951', '2019-05-24', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 15'),
    (14, 3076, 'RTM CU14', 'https://support.microsoft.com/en-us/help/4484710', '2019-03-25', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 14'),
    (14, 3048, 'RTM CU13', 'https://support.microsoft.com/en-us/help/4466404', '2018-12-18', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 13'),
    (14, 3045, 'RTM CU12', 'https://support.microsoft.com/en-us/help/4464082', '2018-10-24', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 12'),
    (14, 3038, 'RTM CU11', 'https://support.microsoft.com/en-us/help/4462262', '2018-09-20', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 11'),
    (14, 3037, 'RTM CU10', 'https://support.microsoft.com/en-us/help/4524334', '2018-08-27', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 10'),
    (14, 3030, 'RTM CU9', 'https://support.microsoft.com/en-us/help/4515435', '2018-07-18', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 9'),
    (14, 3029, 'RTM CU8', 'https://support.microsoft.com/en-us/help/4338363', '2018-06-21', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 8'),
    (14, 3026, 'RTM CU7', 'https://support.microsoft.com/en-us/help/4229789', '2018-05-23', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 7'),
    (14, 3025, 'RTM CU6', 'https://support.microsoft.com/en-us/help/4101464', '2018-04-17', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 6'),
    (14, 3023, 'RTM CU5', 'https://support.microsoft.com/en-us/help/4092643', '2018-03-20', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 5'),
    (14, 3022, 'RTM CU4', 'https://support.microsoft.com/en-us/help/4056498', '2018-02-20', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 4'),
    (14, 3015, 'RTM CU3', 'https://support.microsoft.com/en-us/help/4052987', '2018-01-04', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 3'),
    (14, 3008, 'RTM CU2', 'https://support.microsoft.com/en-us/help/4052574', '2017-11-28', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 2'),
    (14, 3006, 'RTM CU1', 'https://support.microsoft.com/en-us/help/4038634', '2017-10-24', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM Cumulative Update 1'),
    (14, 1000, 'RTM ', '', '2017-10-02', '2022-10-11', '2027-10-12', 'SQL Server 2017', 'RTM '),
    /*2016*/
    (13, 7045, 'SP3 Azure Feature Pack GDR', 'https://support.microsoft.com/en-us/help/5046062', '2024-10-08', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 Azure Feature Pack GDR'),
    (13, 7040, 'SP3 Azure Feature Pack GDR', 'https://support.microsoft.com/en-us/help/5042209', '2024-09-10', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 Azure Feature Pack GDR'),
    (13, 7037, 'SP3 Azure Feature Pack GDR', 'https://support.microsoft.com/en-us/help/5040944', '2024-07-09', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 Azure Feature Pack GDR'),
    (13, 7029, 'SP3 Azure Feature Pack GDR', 'https://support.microsoft.com/en-us/help/5029187', '2023-10-10', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 Azure Feature Pack GDR'),
    (13, 7024, 'SP3 Azure Feature Pack GDR', 'https://support.microsoft.com/en-us/help/5021128', '2023-02-14', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 Azure Feature Pack GDR'),
    (13, 7016, 'SP3 Azure Feature Pack GDR', 'https://support.microsoft.com/en-us/help/5015371', '2022-06-14', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 Azure Feature Pack GDR'),
    (13, 7000, 'SP3 Azure Feature Pack', 'https://support.microsoft.com/en-us/help/5014242', '2022-05-19', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 Azure Feature Pack'),
    (13, 6455, 'SP3 GDR', 'https://support.microsoft.com/kb/5046855', '2024-11-12', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 GDR'),
    (13, 6450, 'SP3 GDR', 'https://support.microsoft.com/kb/5046063', '2024-10-08', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 GDR'),
    (13, 6445, 'SP3 GDR', 'https://support.microsoft.com/kb/5042207', '2024-09-10', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 GDR'),
    (13, 6441, 'SP3 GDR', 'https://support.microsoft.com/kb/5040946', '2024-07-09', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 GDR'),
    (13, 6435, 'SP3 GDR', 'https://support.microsoft.com/kb/5029186', '2023-10-10', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 GDR'),
    (13, 6430, 'SP3 GDR', 'https://support.microsoft.com/kb/5021129', '2023-02-14', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 GDR'),
    (13, 6419, 'SP3 GDR', 'https://support.microsoft.com/en-us/help/5014355', '2022-06-14', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 GDR'),
    (13, 6404, 'SP3 GDR', 'https://support.microsoft.com/en-us/help/5006943', '2021-10-27', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3 GDR'),
    (13, 6300, 'SP3 ', 'https://support.microsoft.com/en-us/help/5003279', '2021-09-15', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 3'),
    (13, 5888, 'SP2 CU17', 'https://support.microsoft.com/en-us/help/5001092', '2021-03-29', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 17'),
    (13, 5882, 'SP2 CU16', 'https://support.microsoft.com/en-us/help/5000645', '2021-02-11', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 16'),
    (13, 5865, 'SP2 CU15 GDR', 'https://support.microsoft.com/en-us/help/4583461', '2021-01-12', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 15 GDR'),
    (13, 5850, 'SP2 CU15', 'https://support.microsoft.com/en-us/help/4577775', '2020-09-28', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 15'),
    (13, 5830, 'SP2 CU14', 'https://support.microsoft.com/en-us/help/4564903', '2020-08-06', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 14'),
    (13, 5820, 'SP2 CU13', 'https://support.microsoft.com/en-us/help/4549825', '2020-05-28', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 13'),
    (13, 5698, 'SP2 CU12', 'https://support.microsoft.com/en-us/help/4536648', '2020-02-25', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 12'),
    (13, 5598, 'SP2 CU11', 'https://support.microsoft.com/en-us/help/4527378', '2019-12-09', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 11'),
    (13, 5492, 'SP2 CU10', 'https://support.microsoft.com/en-us/help/4505830', '2019-10-08', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 10'),
    (13, 5479, 'SP2 CU9', 'https://support.microsoft.com/en-us/help/4505830', '2019-09-30', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 9'),
    (13, 5426, 'SP2 CU8', 'https://support.microsoft.com/en-us/help/4505830', '2019-07-31', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 8'),
    (13, 5337, 'SP2 CU7', 'https://support.microsoft.com/en-us/help/4495256', '2019-05-23', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 7'),
    (13, 5292, 'SP2 CU6', 'https://support.microsoft.com/en-us/help/4488536', '2019-03-19', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 6'),
    (13, 5264, 'SP2 CU5', 'https://support.microsoft.com/en-us/help/4475776', '2019-01-23', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 5'),
    (13, 5233, 'SP2 CU4', 'https://support.microsoft.com/en-us/help/4464106', '2018-11-13', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 4'),
    (13, 5216, 'SP2 CU3', 'https://support.microsoft.com/en-us/help/4458871', '2018-09-20', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 3'),
    (13, 5201, 'SP2 CU2 + Security Update', 'https://support.microsoft.com/en-us/help/4458621', '2018-08-21', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 2 + Security Update'),
    (13, 5153, 'SP2 CU2', 'https://support.microsoft.com/en-us/help/4340355', '2018-07-16', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 2'),
    (13, 5149, 'SP2 CU1', 'https://support.microsoft.com/en-us/help/4135048', '2018-05-30', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 Cumulative Update 1'),
    (13, 5103, 'SP2 GDR', 'https://support.microsoft.com/en-us/help/4583460', '2021-01-12', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 GDR'),
    (13, 5026, 'SP2 ', 'https://support.microsoft.com/en-us/help/4052908', '2018-04-24', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 2 '),
    (13, 4574, 'SP1 CU15', 'https://support.microsoft.com/en-us/help/4495257', '2019-05-16', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 15'),
    (13, 4560, 'SP1 CU14', 'https://support.microsoft.com/en-us/help/4488535', '2019-03-19', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 14'),
    (13, 4550, 'SP1 CU13', 'https://support.microsoft.com/en-us/help/4475775', '2019-01-23', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 13'),
    (13, 4541, 'SP1 CU12', 'https://support.microsoft.com/en-us/help/4464343', '2018-11-13', '2021-07-13', '2026-07-14', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 12'),
    (13, 4528, 'SP1 CU11', 'https://support.microsoft.com/en-us/help/4459676', '2018-09-17', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 11'),
    (13, 4514, 'SP1 CU10', 'https://support.microsoft.com/en-us/help/4341569', '2018-07-16', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 10'),
    (13, 4502, 'SP1 CU9', 'https://support.microsoft.com/en-us/help/4100997', '2018-05-30', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 9'),
    (13, 4474, 'SP1 CU8', 'https://support.microsoft.com/en-us/help/4077064', '2018-03-19', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 8'),
    (13, 4466, 'SP1 CU7', 'https://support.microsoft.com/en-us/help/4057119', '2018-01-04', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 7'),
    (13, 4457, 'SP1 CU6', 'https://support.microsoft.com/en-us/help/4037354', '2017-11-20', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 6'),
    (13, 4451, 'SP1 CU5', 'https://support.microsoft.com/en-us/help/4024305', '2017-09-18', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 5'),
    (13, 4446, 'SP1 CU4', 'https://support.microsoft.com/en-us/help/4024305', '2017-08-08', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 4'),
    (13, 4435, 'SP1 CU3', 'https://support.microsoft.com/en-us/help/4019916', '2017-05-15', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 3'),
    (13, 4422, 'SP1 CU2', 'https://support.microsoft.com/en-us/help/4013106', '2017-03-20', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 2'),
    (13, 4411, 'SP1 CU1', 'https://support.microsoft.com/en-us/help/3208177', '2017-01-17', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 1'),
    (13, 4224, 'SP1 CU10 + Security Update', 'https://support.microsoft.com/en-us/help/4458842', '2018-08-22', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 Cumulative Update 10 + Security Update'),
    (13, 4001, 'SP1 ', 'https://support.microsoft.com/en-us/help/3182545 ', '2016-11-16', '2019-07-09', '2019-07-09', 'SQL Server 2016', 'Service Pack 1 '),
    (13, 2216, 'RTM CU9', 'https://support.microsoft.com/en-us/help/4037357', '2017-11-20', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 9'),
    (13, 2213, 'RTM CU8', 'https://support.microsoft.com/en-us/help/4024304', '2017-09-18', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 8'),
    (13, 2210, 'RTM CU7', 'https://support.microsoft.com/en-us/help/4024304', '2017-08-08', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 7'),
    (13, 2204, 'RTM CU6', 'https://support.microsoft.com/en-us/help/4019914', '2017-05-15', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 6'),
    (13, 2197, 'RTM CU5', 'https://support.microsoft.com/en-us/help/4013105', '2017-03-20', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 5'),
    (13, 2193, 'RTM CU4', 'https://support.microsoft.com/en-us/help/3205052 ', '2017-01-17', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 4'),
    (13, 2186, 'RTM CU3', 'https://support.microsoft.com/en-us/help/3205413 ', '2016-11-16', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 3'),
    (13, 2164, 'RTM CU2', 'https://support.microsoft.com/en-us/help/3182270 ', '2016-09-22', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 2'),
    (13, 2149, 'RTM CU1', 'https://support.microsoft.com/en-us/help/3164674 ', '2016-07-25', '2018-01-09', '2018-01-09', 'SQL Server 2016', 'RTM Cumulative Update 1'),
    (13, 1601, 'RTM ', '', '2016-06-01', '2019-01-09', '2019-01-09', 'SQL Server 2016', 'RTM '),
    /*2014*/
    (12, 6449, 'SP3 CU4 GDR', 'https://support.microsoft.com/kb/5029185', '2023-10-12', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 4 GDR'),
    (12, 6444, 'SP3 CU4 GDR', 'https://support.microsoft.com/kb/5021045', '2023-02-14', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 4 GDR'),
    (12, 6439, 'SP3 CU4 GDR', 'https://support.microsoft.com/en-us/help/5014164', '2022-06-14', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 4 GDR'),
    (12, 6433, 'SP3 CU4 GDR', 'https://support.microsoft.com/en-us/help/4583462', '2021-01-12', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 4 GDR'),
    (12, 6372, 'SP3 CU4 GDR', 'https://support.microsoft.com/en-us/help/4535288', '2020-02-11', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 4 GDR'),
    (12, 6329, 'SP3 CU4', 'https://support.microsoft.com/en-us/help/4500181', '2019-07-29', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 4'),
    (12, 6259, 'SP3 CU3', 'https://support.microsoft.com/en-us/help/4491539', '2019-04-16', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 3'),
    (12, 6214, 'SP3 CU2', 'https://support.microsoft.com/en-us/help/4482960', '2019-02-19', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 2'),
    (12, 6205, 'SP3 CU1', 'https://support.microsoft.com/en-us/help/4470220', '2018-12-12', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 Cumulative Update 1'),
    (12, 6164, 'SP3 GDR', 'https://support.microsoft.com/en-us/help/4583463', '2021-01-12', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 GDR'),
    (12, 6024, 'SP3 ', 'https://support.microsoft.com/en-us/help/4022619', '2018-10-30', '2019-07-09', '2024-07-09', 'SQL Server 2014', 'Service Pack 3 '),
    (12, 5687, 'SP2 CU18', 'https://support.microsoft.com/en-us/help/4500180', '2019-07-29', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 18'),
    (12, 5632, 'SP2 CU17', 'https://support.microsoft.com/en-us/help/4491540', '2019-04-16', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 17'),
    (12, 5626, 'SP2 CU16', 'https://support.microsoft.com/en-us/help/4482967', '2019-02-19', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 16'),
    (12, 5605, 'SP2 CU15', 'https://support.microsoft.com/en-us/help/4469137', '2018-12-12', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 15'),
    (12, 5600, 'SP2 CU14', 'https://support.microsoft.com/en-us/help/4459860', '2018-10-15', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 14'),
    (12, 5590, 'SP2 CU13', 'https://support.microsoft.com/en-us/help/4456287', '2018-08-27', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 13'),
    (12, 5589, 'SP2 CU12', 'https://support.microsoft.com/en-us/help/4130489', '2018-06-18', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 12'),
    (12, 5579, 'SP2 CU11', 'https://support.microsoft.com/en-us/help/4077063', '2018-03-19', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 11'),
    (12, 5571, 'SP2 CU10', 'https://support.microsoft.com/en-us/help/4052725', '2018-01-16', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 10'),
    (12, 5563, 'SP2 CU9', 'https://support.microsoft.com/en-us/help/4055557', '2017-12-18', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 9'),
    (12, 5557, 'SP2 CU8', 'https://support.microsoft.com/en-us/help/4037356', '2017-10-16', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 8'),
    (12, 5556, 'SP2 CU7', 'https://support.microsoft.com/en-us/help/4032541', '2017-08-28', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 7'),
    (12, 5553, 'SP2 CU6', 'https://support.microsoft.com/en-us/help/4019094', '2017-08-08', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 6'),
    (12, 5546, 'SP2 CU5', 'https://support.microsoft.com/en-us/help/4013098', '2017-04-17', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 5'),
    (12, 5540, 'SP2 CU4', 'https://support.microsoft.com/en-us/help/4010394', '2017-02-21', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 4'),
    (12, 5538, 'SP2 CU3', 'https://support.microsoft.com/en-us/help/3204388 ', '2016-12-19', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 3'),
    (12, 5522, 'SP2 CU2', 'https://support.microsoft.com/en-us/help/3188778 ', '2016-10-17', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 2'),
    (12, 5511, 'SP2 CU1', 'https://support.microsoft.com/en-us/help/3178925 ', '2016-08-25', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 Cumulative Update 1'),
    (12, 5000, 'SP2 ', 'https://support.microsoft.com/en-us/help/3171021 ', '2016-07-11', '2020-01-14', '2020-01-14', 'SQL Server 2014', 'Service Pack 2 '),
    (12, 4522, 'SP1 CU13', 'https://support.microsoft.com/en-us/help/4019099', '2017-08-08', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 13'),
    (12, 4511, 'SP1 CU12', 'https://support.microsoft.com/en-us/help/4017793', '2017-04-17', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 12'),
    (12, 4502, 'SP1 CU11', 'https://support.microsoft.com/en-us/help/4010392', '2017-02-21', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 11'),
    (12, 4491, 'SP1 CU10', 'https://support.microsoft.com/en-us/help/3204399 ', '2016-12-19', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 10'),
    (12, 4474, 'SP1 CU9', 'https://support.microsoft.com/en-us/help/3186964 ', '2016-10-17', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 9'),
    (12, 4468, 'SP1 CU8', 'https://support.microsoft.com/en-us/help/3174038 ', '2016-08-15', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 8'),
    (12, 4459, 'SP1 CU7', 'https://support.microsoft.com/en-us/help/3162659 ', '2016-06-20', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 7'),
    (12, 4457, 'SP1 CU6', 'https://support.microsoft.com/en-us/help/3167392 ', '2016-05-30', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 6'),
    (12, 4449, 'SP1 CU6', 'https://support.microsoft.com/en-us/help/3144524', '2016-04-18', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 6'),
    (12, 4438, 'SP1 CU5', 'https://support.microsoft.com/en-us/help/3130926', '2016-02-22', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 5'),
    (12, 4436, 'SP1 CU4', 'https://support.microsoft.com/en-us/help/3106660', '2015-12-21', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 4'),
    (12, 4427, 'SP1 CU3', 'https://support.microsoft.com/en-us/help/3094221', '2015-10-19', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 3'),
    (12, 4422, 'SP1 CU2', 'https://support.microsoft.com/en-us/help/3075950', '2015-08-17', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 2'),
    (12, 4416, 'SP1 CU1', 'https://support.microsoft.com/en-us/help/3067839', '2015-06-19', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 Cumulative Update 1'),
    (12, 4213, 'SP1 MS15-058: GDR Security Update', 'https://support.microsoft.com/en-us/help/3070446', '2015-07-14', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 MS15-058: GDR Security Update'),
    (12, 4100, 'SP1 ', 'https://support.microsoft.com/en-us/help/3058865', '2015-05-04', '2017-10-10', '2017-10-10', 'SQL Server 2014', 'Service Pack 1 '),
    (12, 2569, 'RTM CU14', 'https://support.microsoft.com/en-us/help/3158271 ', '2016-06-20', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 14'),
    (12, 2568, 'RTM CU13', 'https://support.microsoft.com/en-us/help/3144517', '2016-04-18', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 13'),
    (12, 2564, 'RTM CU12', 'https://support.microsoft.com/en-us/help/3130923', '2016-02-22', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 12'),
    (12, 2560, 'RTM CU11', 'https://support.microsoft.com/en-us/help/3106659', '2015-12-21', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 11'),
    (12, 2556, 'RTM CU10', 'https://support.microsoft.com/en-us/help/3094220', '2015-10-19', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 10'),
    (12, 2553, 'RTM CU9', 'https://support.microsoft.com/en-us/help/3075949', '2015-08-17', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 9'),
    (12, 2548, 'RTM MS15-058: QFE Security Update', 'https://support.microsoft.com/en-us/help/3045323', '2015-07-14', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM MS15-058: QFE Security Update'),
    (12, 2546, 'RTM CU8', 'https://support.microsoft.com/en-us/help/3067836', '2015-06-19', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 8'),
    (12, 2495, 'RTM CU7', 'https://support.microsoft.com/en-us/help/3046038', '2015-04-20', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 7'),
    (12, 2480, 'RTM CU6', 'https://support.microsoft.com/en-us/help/3031047', '2015-02-16', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 6'),
    (12, 2456, 'RTM CU5', 'https://support.microsoft.com/en-us/help/3011055', '2014-12-17', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 5'),
    (12, 2430, 'RTM CU4', 'https://support.microsoft.com/en-us/help/2999197', '2014-10-21', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 4'),
    (12, 2402, 'RTM CU3', 'https://support.microsoft.com/en-us/help/2984923', '2014-08-18', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 3'),
    (12, 2381, 'RTM MS14-044: QFE Security Update', 'https://support.microsoft.com/en-us/help/2977316', '2014-08-12', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM MS14-044: QFE Security Update'),
    (12, 2370, 'RTM CU2', 'https://support.microsoft.com/en-us/help/2967546', '2014-06-27', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 2'),
    (12, 2342, 'RTM CU1', 'https://support.microsoft.com/en-us/help/2931693', '2014-04-21', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM Cumulative Update 1'),
    (12, 2269, 'RTM MS15-058: GDR Security Update ', 'https://support.microsoft.com/en-us/help/3045324', '2015-07-14', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM MS15-058: GDR Security Update '),
    (12, 2254, 'RTM MS14-044: GDR Security Update', 'https://support.microsoft.com/en-us/help/2977315', '2014-08-12', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM MS14-044: GDR Security Update'),
    (12, 2000, 'RTM ', '', '2014-04-01', '2016-07-12', '2016-07-12', 'SQL Server 2014', 'RTM '),
    /*2012*/
    (11, 7512, 'SP4 GDR Security Update', 'https://support.microsoft.com/en-us/help/5021123', '2023-02-16', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'Service Pack 4 GDR Security Update for CVE-2021-1636'),
    (11, 7507, 'SP4 GDR Security Update', 'https://support.microsoft.com/en-us/help/4583465', '2021-01-12', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'Service Pack 4 GDR Security Update for CVE-2021-1636'),
    (11, 7493, 'SP4 GDR Security Update', 'https://support.microsoft.com/en-us/help/4532098', '2020-02-11', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'Service Pack 4 GDR Security Update for CVE-2020-0618'),
    (11, 7469, 'SP4 On-Demand Hotfix Update', 'https://support.microsoft.com/en-us/help/4091266', '2018-03-28', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'Service Pack 4 SP4 On-Demand Hotfix Update'),
    (11, 7462, 'SP4 ADV180002: GDR Security Update', 'https://support.microsoft.com/en-us/help/4057116', '2018-01-12', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'Service Pack 4 ADV180002: GDR Security Update'),
    (11, 7001, 'SP4 ', 'https://support.microsoft.com/en-us/help/4018073', '2017-10-02', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'Service Pack 4 '),
    (11, 6607, 'SP3 CU10', 'https://support.microsoft.com/en-us/help/4025925', '2017-08-08', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 10'),
    (11, 6598, 'SP3 CU9', 'https://support.microsoft.com/en-us/help/4016762', '2017-05-15', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 9'),
    (11, 6594, 'SP3 CU8', 'https://support.microsoft.com/en-us/help/3205051 ', '2017-03-20', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 8'),
    (11, 6579, 'SP3 CU7', 'https://support.microsoft.com/en-us/help/3205051 ', '2017-01-17', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 7'),
    (11, 6567, 'SP3 CU6', 'https://support.microsoft.com/en-us/help/3194992 ', '2016-11-17', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 6'),
    (11, 6544, 'SP3 CU5', 'https://support.microsoft.com/en-us/help/3180915 ', '2016-09-19', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 5'),
    (11, 6540, 'SP3 CU4', 'https://support.microsoft.com/en-us/help/3165264 ', '2016-07-18', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 4'),
    (11, 6537, 'SP3 CU3', 'https://support.microsoft.com/en-us/help/3152635 ', '2016-05-16', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 3'),
    (11, 6523, 'SP3 CU2', 'https://support.microsoft.com/en-us/help/3137746', '2016-03-21', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 2'),
    (11, 6518, 'SP3 CU1', 'https://support.microsoft.com/en-us/help/3123299', '2016-01-19', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 Cumulative Update 1'),
    (11, 6020, 'SP3 ', 'https://support.microsoft.com/en-us/help/3072779', '2015-11-20', '2018-10-09', '2018-10-09', 'SQL Server 2012', 'Service Pack 3 '),
    (11, 5678, 'SP2 CU16', 'https://support.microsoft.com/en-us/help/3205416 ', '2016-11-17', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 16'),
    (11, 5676, 'SP2 CU15', 'https://support.microsoft.com/en-us/help/3205416 ', '2016-11-17', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 15'),
    (11, 5657, 'SP2 CU14', 'https://support.microsoft.com/en-us/help/3180914 ', '2016-09-19', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 14'),
    (11, 5655, 'SP2 CU13', 'https://support.microsoft.com/en-us/help/3165266 ', '2016-07-18', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 13'),
    (11, 5649, 'SP2 CU12', 'https://support.microsoft.com/en-us/help/3152637 ', '2016-05-16', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 12'),
    (11, 5646, 'SP2 CU11', 'https://support.microsoft.com/en-us/help/3137745', '2016-03-21', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 11'),
    (11, 5644, 'SP2 CU10', 'https://support.microsoft.com/en-us/help/3120313', '2016-01-19', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 10'),
    (11, 5641, 'SP2 CU9', 'https://support.microsoft.com/en-us/help/3098512', '2015-11-16', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 9'),
    (11, 5634, 'SP2 CU8', 'https://support.microsoft.com/en-us/help/3082561', '2015-09-21', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 8'),
    (11, 5623, 'SP2 CU7', 'https://support.microsoft.com/en-us/help/3072100', '2015-07-20', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 7'),
    (11, 5613, 'SP2 MS15-058: QFE Security Update', 'https://support.microsoft.com/en-us/help/3045319', '2015-07-14', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 MS15-058: QFE Security Update'),
    (11, 5592, 'SP2 CU6', 'https://support.microsoft.com/en-us/help/3052468', '2015-05-18', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 6'),
    (11, 5582, 'SP2 CU5', 'https://support.microsoft.com/en-us/help/3037255', '2015-03-16', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 5'),
    (11, 5569, 'SP2 CU4', 'https://support.microsoft.com/en-us/help/3007556', '2015-01-19', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 4'),
    (11, 5556, 'SP2 CU3', 'https://support.microsoft.com/en-us/help/3002049', '2014-11-17', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 3'),
    (11, 5548, 'SP2 CU2', 'https://support.microsoft.com/en-us/help/2983175', '2014-09-15', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 2'),
    (11, 5532, 'SP2 CU1', 'https://support.microsoft.com/en-us/help/2976982', '2014-07-23', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 Cumulative Update 1'),
    (11, 5343, 'SP2 MS15-058: GDR Security Update', 'https://support.microsoft.com/en-us/help/3045321', '2015-07-14', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 MS15-058: GDR Security Update'),
    (11, 5058, 'SP2 ', 'https://support.microsoft.com/en-us/help/2958429', '2014-06-10', '2017-01-10', '2017-01-10', 'SQL Server 2012', 'Service Pack 2 '),
    (11, 3513, 'SP1 MS15-058: QFE Security Update', 'https://support.microsoft.com/en-us/help/3045317', '2015-07-14', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 MS15-058: QFE Security Update'),
    (11, 3482, 'SP1 CU13', 'https://support.microsoft.com/en-us/help/3002044', '2014-11-17', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 13'),
    (11, 3470, 'SP1 CU12', 'https://support.microsoft.com/en-us/help/2991533', '2014-09-15', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 12'),
    (11, 3460, 'SP1 MS14-044: QFE Security Update ', 'https://support.microsoft.com/en-us/help/2977325', '2014-08-12', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 MS14-044: QFE Security Update '),
    (11, 3449, 'SP1 CU11', 'https://support.microsoft.com/en-us/help/2975396', '2014-07-21', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 11'),
    (11, 3431, 'SP1 CU10', 'https://support.microsoft.com/en-us/help/2954099', '2014-05-19', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 10'),
    (11, 3412, 'SP1 CU9', 'https://support.microsoft.com/en-us/help/2931078', '2014-03-17', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 9'),
    (11, 3401, 'SP1 CU8', 'https://support.microsoft.com/en-us/help/2917531', '2014-01-20', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 8'),
    (11, 3393, 'SP1 CU7', 'https://support.microsoft.com/en-us/help/2894115', '2013-11-18', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 7'),
    (11, 3381, 'SP1 CU6', 'https://support.microsoft.com/en-us/help/2874879', '2013-09-16', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 6'),
    (11, 3373, 'SP1 CU5', 'https://support.microsoft.com/en-us/help/2861107', '2013-07-15', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 5'),
    (11, 3368, 'SP1 CU4', 'https://support.microsoft.com/en-us/help/2833645', '2013-05-30', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 4'),
    (11, 3349, 'SP1 CU3', 'https://support.microsoft.com/en-us/help/2812412', '2013-03-18', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 3'),
    (11, 3339, 'SP1 CU2', 'https://support.microsoft.com/en-us/help/2790947', '2013-01-21', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 2'),
    (11, 3321, 'SP1 CU1', 'https://support.microsoft.com/en-us/help/2765331', '2012-11-20', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 Cumulative Update 1'),
    (11, 3156, 'SP1 MS15-058: GDR Security Update', 'https://support.microsoft.com/en-us/help/3045318', '2015-07-14', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 MS15-058: GDR Security Update'),
    (11, 3153, 'SP1 MS14-044: GDR Security Update', 'https://support.microsoft.com/en-us/help/2977326', '2014-08-12', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 MS14-044: GDR Security Update'),
    (11, 3000, 'SP1 ', 'https://support.microsoft.com/en-us/help/2674319', '2012-11-07', '2015-07-14', '2015-07-14', 'SQL Server 2012', 'Service Pack 1 '),
    (11, 2424, 'RTM CU11', 'https://support.microsoft.com/en-us/help/2908007', '2013-12-16', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 11'),
    (11, 2420, 'RTM CU10', 'https://support.microsoft.com/en-us/help/2891666', '2013-10-21', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 10'),
    (11, 2419, 'RTM CU9', 'https://support.microsoft.com/en-us/help/2867319', '2013-08-20', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 9'),
    (11, 2410, 'RTM CU8', 'https://support.microsoft.com/en-us/help/2844205', '2013-06-17', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 8'),
    (11, 2405, 'RTM CU7', 'https://support.microsoft.com/en-us/help/2823247', '2013-04-15', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 7'),
    (11, 2401, 'RTM CU6', 'https://support.microsoft.com/en-us/help/2728897', '2013-02-18', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 6'),
    (11, 2395, 'RTM CU5', 'https://support.microsoft.com/en-us/help/2777772', '2012-12-17', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 5'),
    (11, 2383, 'RTM CU4', 'https://support.microsoft.com/en-us/help/2758687', '2012-10-15', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 4'),
    (11, 2376, 'RTM MS12-070: QFE Security Update', 'https://support.microsoft.com/en-us/help/2716441', '2012-10-09', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM MS12-070: QFE Security Update'),
    (11, 2332, 'RTM CU3', 'https://support.microsoft.com/en-us/help/2723749', '2012-08-31', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 3'),
    (11, 2325, 'RTM CU2', 'https://support.microsoft.com/en-us/help/2703275', '2012-06-18', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 2'),
    (11, 2316, 'RTM CU1', 'https://support.microsoft.com/en-us/help/2679368', '2012-04-12', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM Cumulative Update 1'),
    (11, 2218, 'RTM MS12-070: GDR Security Update', 'https://support.microsoft.com/en-us/help/2716442', '2012-10-09', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM MS12-070: GDR Security Update'),
    (11, 2100, 'RTM ', '', '2012-03-06', '2017-07-11', '2022-07-12', 'SQL Server 2012', 'RTM '),
    /*2008 R2*/
    (10, 6529, 'SP3 MS15-058: QFE Security Update', 'https://support.microsoft.com/en-us/help/3045314', '2015-07-14', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'Service Pack 3 MS15-058: QFE Security Update'),
    (10, 6220, 'SP3 MS15-058: QFE Security Update', 'https://support.microsoft.com/en-us/help/3045316', '2015-07-14', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'Service Pack 3 MS15-058: QFE Security Update'),
    (10, 6000, 'SP3 ', 'https://support.microsoft.com/en-us/help/2979597', '2014-09-26', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'Service Pack 3 '),
    (10, 4339, 'SP2 MS15-058: QFE Security Update', 'https://support.microsoft.com/en-us/help/3045312', '2015-07-14', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 MS15-058: QFE Security Update'),
    (10, 4321, 'SP2 MS14-044: QFE Security Update', 'https://support.microsoft.com/en-us/help/2977319', '2014-08-14', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 MS14-044: QFE Security Update'),
    (10, 4319, 'SP2 CU13', 'https://support.microsoft.com/en-us/help/2967540', '2014-06-30', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 13'),
    (10, 4305, 'SP2 CU12', 'https://support.microsoft.com/en-us/help/2938478', '2014-04-21', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 12'),
    (10, 4302, 'SP2 CU11', 'https://support.microsoft.com/en-us/help/2926028', '2014-02-18', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 11'),
    (10, 4297, 'SP2 CU10', 'https://support.microsoft.com/en-us/help/2908087', '2013-12-17', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 10'),
    (10, 4295, 'SP2 CU9', 'https://support.microsoft.com/en-us/help/2887606', '2013-10-28', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 9'),
    (10, 4290, 'SP2 CU8', 'https://support.microsoft.com/en-us/help/2871401', '2013-08-22', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 8'),
    (10, 4285, 'SP2 CU7', 'https://support.microsoft.com/en-us/help/2844090', '2013-06-17', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 7'),
    (10, 4279, 'SP2 CU6', 'https://support.microsoft.com/en-us/help/2830140', '2013-04-15', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 6'),
    (10, 4276, 'SP2 CU5', 'https://support.microsoft.com/en-us/help/2797460', '2013-02-18', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 5'),
    (10, 4270, 'SP2 CU4', 'https://support.microsoft.com/en-us/help/2777358', '2012-12-17', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 4'),
    (10, 4266, 'SP2 CU3', 'https://support.microsoft.com/en-us/help/2754552', '2012-10-15', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 3'),
    (10, 4263, 'SP2 CU2', 'https://support.microsoft.com/en-us/help/2740411', '2012-08-31', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 2'),
    (10, 4260, 'SP2 CU1', 'https://support.microsoft.com/en-us/help/2720425', '2012-07-24', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 Cumulative Update 1'),
    (10, 4042, 'SP2 MS15-058: GDR Security Update', 'https://support.microsoft.com/en-us/help/3045313', '2015-07-14', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 MS15-058: GDR Security Update'),
    (10, 4033, 'SP2 MS14-044: GDR Security Update', 'https://support.microsoft.com/en-us/help/2977320', '2014-08-12', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 MS14-044: GDR Security Update'),
    (10, 4000, 'SP2 ', 'https://support.microsoft.com/en-us/help/2630458', '2012-07-26', '2015-10-13', '2015-10-13', 'SQL Server 2008 R2', 'Service Pack 2 '),
    (10, 2881, 'SP1 CU14', 'https://support.microsoft.com/en-us/help/2868244', '2013-08-08', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 14'),
    (10, 2876, 'SP1 CU13', 'https://support.microsoft.com/en-us/help/2855792', '2013-06-17', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 13'),
    (10, 2874, 'SP1 CU12', 'https://support.microsoft.com/en-us/help/2828727', '2013-04-15', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 12'),
    (10, 2869, 'SP1 CU11', 'https://support.microsoft.com/en-us/help/2812683', '2013-02-18', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 11'),
    (10, 2868, 'SP1 CU10', 'https://support.microsoft.com/en-us/help/2783135', '2012-12-17', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 10'),
    (10, 2866, 'SP1 CU9', 'https://support.microsoft.com/en-us/help/2756574', '2012-10-15', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 9'),
    (10, 2861, 'SP1 MS12-070: QFE Security Update', 'https://support.microsoft.com/en-us/help/2716439', '2012-10-09', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 MS12-070: QFE Security Update'),
    (10, 2822, 'SP1 CU8', 'https://support.microsoft.com/en-us/help/2723743', '2012-08-31', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 8'),
    (10, 2817, 'SP1 CU7', 'https://support.microsoft.com/en-us/help/2703282', '2012-06-18', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 7'),
    (10, 2811, 'SP1 CU6', 'https://support.microsoft.com/en-us/help/2679367', '2012-04-16', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 6'),
    (10, 2806, 'SP1 CU5', 'https://support.microsoft.com/en-us/help/2659694', '2012-02-22', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 5'),
    (10, 2796, 'SP1 CU4', 'https://support.microsoft.com/en-us/help/2633146', '2011-12-19', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 4'),
    (10, 2789, 'SP1 CU3', 'https://support.microsoft.com/en-us/help/2591748', '2011-10-17', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 3'),
    (10, 2772, 'SP1 CU2', 'https://support.microsoft.com/en-us/help/2567714', '2011-08-15', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 2'),
    (10, 2769, 'SP1 CU1', 'https://support.microsoft.com/en-us/help/2544793', '2011-07-18', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 Cumulative Update 1'),
    (10, 2550, 'SP1 MS12-070: GDR Security Update', 'https://support.microsoft.com/en-us/help/2754849', '2012-10-09', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 MS12-070: GDR Security Update'),
    (10, 2500, 'SP1 ', 'https://support.microsoft.com/en-us/help/2528583', '2011-07-12', '2013-10-08', '2013-10-08', 'SQL Server 2008 R2', 'Service Pack 1 '),
    (10, 1815, 'RTM CU13', 'https://support.microsoft.com/en-us/help/2679366', '2012-04-16', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 13'),
    (10, 1810, 'RTM CU12', 'https://support.microsoft.com/en-us/help/2659692', '2012-02-21', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 12'),
    (10, 1809, 'RTM CU11', 'https://support.microsoft.com/en-us/help/2633145', '2011-12-19', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 11'),
    (10, 1807, 'RTM CU10', 'https://support.microsoft.com/en-us/help/2591746', '2011-10-17', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 10'),
    (10, 1804, 'RTM CU9', 'https://support.microsoft.com/en-us/help/2567713', '2011-08-15', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 9'),
    (10, 1797, 'RTM CU8', 'https://support.microsoft.com/en-us/help/2534352', '2011-06-20', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 8'),
    (10, 1790, 'RTM MS11-049: QFE Security Update', 'https://support.microsoft.com/en-us/help/2494086', '2011-06-14', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM MS11-049: QFE Security Update'),
    (10, 1777, 'RTM CU7', 'https://support.microsoft.com/en-us/help/2507770', '2011-04-18', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 7'),
    (10, 1765, 'RTM CU6', 'https://support.microsoft.com/en-us/help/2489376', '2011-02-21', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 6'),
    (10, 1753, 'RTM CU5', 'https://support.microsoft.com/en-us/help/2438347', '2010-12-20', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 5'),
    (10, 1746, 'RTM CU4', 'https://support.microsoft.com/en-us/help/2345451', '2010-10-18', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 4'),
    (10, 1734, 'RTM CU3', 'https://support.microsoft.com/en-us/help/2261464', '2010-08-16', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 3'),
    (10, 1720, 'RTM CU2', 'https://support.microsoft.com/en-us/help/2072493', '2010-06-21', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 2'),
    (10, 1702, 'RTM CU1', 'https://support.microsoft.com/en-us/help/981355', '2010-05-18', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM Cumulative Update 1'),
    (10, 1617, 'RTM MS11-049: GDR Security Update', 'https://support.microsoft.com/en-us/help/2494088', '2011-06-14', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM MS11-049: GDR Security Update'),
    (10, 1600, 'RTM ', '', '2010-05-10', '2014-07-08', '2019-07-09', 'SQL Server 2008 R2', 'RTM '),
    /*2008*/
    (10, 6535, 'SP3 MS15-058: QFE Security Update', 'https://support.microsoft.com/en-us/help/3045308', '2015-07-14', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 MS15-058: QFE Security Update'),
    (10, 6241, 'SP3 MS15-058: GDR Security Update', 'https://support.microsoft.com/en-us/help/3045311', '2015-07-14', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 MS15-058: GDR Security Update'),
    (10, 5890, 'SP3 MS15-058: QFE Security Update', 'https://support.microsoft.com/en-us/help/3045303', '2015-07-14', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 MS15-058: QFE Security Update'),
    (10, 5869, 'SP3 MS14-044: QFE Security Update', 'https://support.microsoft.com/en-us/help/2984340, https://support.microsoft.com/en-us/help/2977322', '2014-08-12', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 MS14-044: QFE Security Update'),
    (10, 5861, 'SP3 CU17', 'https://support.microsoft.com/en-us/help/2958696', '2014-05-19', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 17'),
    (10, 5852, 'SP3 CU16', 'https://support.microsoft.com/en-us/help/2936421', '2014-03-17', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 16'),
    (10, 5850, 'SP3 CU15', 'https://support.microsoft.com/en-us/help/2923520', '2014-01-20', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 15'),
    (10, 5848, 'SP3 CU14', 'https://support.microsoft.com/en-us/help/2893410', '2013-11-18', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 14'),
    (10, 5846, 'SP3 CU13', 'https://support.microsoft.com/en-us/help/2880350', '2013-09-16', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 13'),
    (10, 5844, 'SP3 CU12', 'https://support.microsoft.com/en-us/help/2863205', '2013-07-15', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 12'),
    (10, 5840, 'SP3 CU11', 'https://support.microsoft.com/en-us/help/2834048', '2013-05-20', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 11'),
    (10, 5835, 'SP3 CU10', 'https://support.microsoft.com/en-us/help/2814783', '2013-03-18', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 10'),
    (10, 5829, 'SP3 CU9', 'https://support.microsoft.com/en-us/help/2799883', '2013-01-21', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 9'),
    (10, 5828, 'SP3 CU8', 'https://support.microsoft.com/en-us/help/2771833', '2012-11-19', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 8'),
    (10, 5826, 'SP3 MS12-070: QFE Security Update', 'https://support.microsoft.com/en-us/help/2716435', '2012-10-09', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 MS12-070: QFE Security Update'),
    (10, 5794, 'SP3 CU7', 'https://support.microsoft.com/en-us/help/2738350', '2012-09-17', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 7'),
    (10, 5788, 'SP3 CU6', 'https://support.microsoft.com/en-us/help/2715953', '2012-07-16', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 6'),
    (10, 5785, 'SP3 CU5', 'https://support.microsoft.com/en-us/help/2696626', '2012-05-21', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 5'),
    (10, 5775, 'SP3 CU4', 'https://support.microsoft.com/en-us/help/2673383', '2012-03-19', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 4'),
    (10, 5770, 'SP3 CU3', 'https://support.microsoft.com/en-us/help/2648098', '2012-01-16', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 3'),
    (10, 5768, 'SP3 CU2', 'https://support.microsoft.com/en-us/help/2633143', '2011-11-21', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 2'),
    (10, 5766, 'SP3 CU1', 'https://support.microsoft.com/en-us/help/2617146', '2011-10-17', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 Cumulative Update 1'),
    (10, 5538, 'SP3 MS15-058: GDR Security Update', 'https://support.microsoft.com/en-us/help/3045305', '2015-07-14', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 MS15-058: GDR Security Update'),
    (10, 5520, 'SP3 MS14-044: GDR Security Update', 'https://support.microsoft.com/en-us/help/2977321', '2014-08-12', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 MS14-044: GDR Security Update'),
    (10, 5512, 'SP3 MS12-070: GDR Security Update', 'https://support.microsoft.com/en-us/help/2716436', '2012-10-09', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 MS12-070: GDR Security Update'),
    (10, 5500, 'SP3 ', 'https://support.microsoft.com/en-us/help/2546951', '2011-10-06', '2015-10-13', '2015-10-13', 'SQL Server 2008', 'Service Pack 3 '),
    (10, 4371, 'SP2 MS12-070: QFE Security Update', 'https://support.microsoft.com/en-us/help/2716433', '2012-10-09', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 MS12-070: QFE Security Update'),
    (10, 4333, 'SP2 CU11', 'https://support.microsoft.com/en-us/help/2715951', '2012-07-16', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 11'),
    (10, 4332, 'SP2 CU10', 'https://support.microsoft.com/en-us/help/2696625', '2012-05-21', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 10'),
    (10, 4330, 'SP2 CU9', 'https://support.microsoft.com/en-us/help/2673382', '2012-03-19', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 9'),
    (10, 4326, 'SP2 CU8', 'https://support.microsoft.com/en-us/help/2648096', '2012-01-16', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 8'),
    (10, 4323, 'SP2 CU7', 'https://support.microsoft.com/en-us/help/2617148', '2011-11-21', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 7'),
    (10, 4321, 'SP2 CU6', 'https://support.microsoft.com/en-us/help/2582285', '2011-09-19', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 6'),
    (10, 4316, 'SP2 CU5', 'https://support.microsoft.com/en-us/help/2555408', '2011-07-18', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 5'),
    (10, 4311, 'SP2 MS11-049: QFE Security Update', 'https://support.microsoft.com/en-us/help/2494094', '2011-06-14', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 MS11-049: QFE Security Update'),
    (10, 4285, 'SP2 CU4', 'https://support.microsoft.com/en-us/help/2527180', '2011-05-16', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 4'),
    (10, 4279, 'SP2 CU3', 'https://support.microsoft.com/en-us/help/2498535', '2011-03-17', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 3'),
    (10, 4272, 'SP2 CU2', 'https://support.microsoft.com/en-us/help/2467239', '2011-01-17', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 2'),
    (10, 4266, 'SP2 CU1', 'https://support.microsoft.com/en-us/help/2289254', '2010-11-15', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 Cumulative Update 1'),
    (10, 4067, 'SP2 MS12-070: GDR Security Update', 'https://support.microsoft.com/en-us/help/2716434', '2012-10-09', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 MS12-070: GDR Security Update'),
    (10, 4064, 'SP2 MS11-049: GDR Security Update', 'https://support.microsoft.com/en-us/help/2494089', '2011-06-14', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 MS11-049: GDR Security Update'),
    (10, 4000, 'SP2 ', 'https://support.microsoft.com/en-us/help/2285068', '2010-09-29', '2012-10-09', '2012-10-09', 'SQL Server 2008', 'Service Pack 2 '),
    (10, 2850, 'SP1 CU16', 'https://support.microsoft.com/en-us/help/2582282', '2011-09-19', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 16'),
    (10, 2847, 'SP1 CU15', 'https://support.microsoft.com/en-us/help/2555406', '2011-07-18', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 15'),
    (10, 2841, 'SP1 MS11-049: QFE Security Update', 'https://support.microsoft.com/en-us/help/2494100', '2011-06-14', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 MS11-049: QFE Security Update'),
    (10, 2821, 'SP1 CU14', 'https://support.microsoft.com/en-us/help/2527187', '2011-05-16', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 14'),
    (10, 2816, 'SP1 CU13', 'https://support.microsoft.com/en-us/help/2497673', '2011-03-17', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 13'),
    (10, 2808, 'SP1 CU12', 'https://support.microsoft.com/en-us/help/2467236', '2011-01-17', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 12'),
    (10, 2804, 'SP1 CU11', 'https://support.microsoft.com/en-us/help/2413738', '2010-11-15', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 11'),
    (10, 2799, 'SP1 CU10', 'https://support.microsoft.com/en-us/help/2279604', '2010-09-20', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 10'),
    (10, 2789, 'SP1 CU9', 'https://support.microsoft.com/en-us/help/2083921', '2010-07-19', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 9'),
    (10, 2775, 'SP1 CU8', 'https://support.microsoft.com/en-us/help/981702', '2010-05-17', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 8'),
    (10, 2766, 'SP1 CU7', 'https://support.microsoft.com/en-us/help/979065', '2010-03-26', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 7'),
    (10, 2757, 'SP1 CU6', 'https://support.microsoft.com/en-us/help/977443', '2010-01-18', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 6'),
    (10, 2746, 'SP1 CU5', 'https://support.microsoft.com/en-us/help/975977', '2009-11-16', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 5'),
    (10, 2734, 'SP1 CU4', 'https://support.microsoft.com/en-us/help/973602', '2009-09-21', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 4'),
    (10, 2723, 'SP1 CU3', 'https://support.microsoft.com/en-us/help/971491', '2009-07-20', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 3'),
    (10, 2714, 'SP1 CU2', 'https://support.microsoft.com/en-us/help/970315', '2009-05-18', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 2'),
    (10, 2710, 'SP1 CU1', 'https://support.microsoft.com/en-us/help/969099', '2009-04-16', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 Cumulative Update 1'),
    (10, 2573, 'SP1 MS11-049: GDR Security update', 'https://support.microsoft.com/en-us/help/2494096', '2011-06-14', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 MS11-049: GDR Security update'),
    (10, 2531, 'SP1 ', '', '2009-04-01', '2011-10-11', '2011-10-11', 'SQL Server 2008', 'Service Pack 1 '),
    (10, 1835, 'RTM CU10', 'https://support.microsoft.com/en-us/help/979064', '2010-03-15', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 10'),
    (10, 1828, 'RTM CU9', 'https://support.microsoft.com/en-us/help/977444', '2010-01-18', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 9'),
    (10, 1823, 'RTM CU8', 'https://support.microsoft.com/en-us/help/975976', '2009-11-16', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 8'),
    (10, 1818, 'RTM CU7', 'https://support.microsoft.com/en-us/help/973601', '2009-09-21', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 7'),
    (10, 1812, 'RTM CU6', 'https://support.microsoft.com/en-us/help/971490', '2009-07-20', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 6'),
    (10, 1806, 'RTM CU5', 'https://support.microsoft.com/en-us/help/969531', '2009-05-18', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 5'),
    (10, 1798, 'RTM CU4', 'https://support.microsoft.com/en-us/help/963036', '2009-03-16', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 4'),
    (10, 1787, 'RTM CU3', 'https://support.microsoft.com/en-us/help/960484', '2009-01-19', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 3'),
    (10, 1779, 'RTM CU2', 'https://support.microsoft.com/en-us/help/958186', '2008-11-19', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 2'),
    (10, 1763, 'RTM CU1', 'https://support.microsoft.com/en-us/help/956717', '2008-09-22', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM Cumulative Update 1'),
    (10, 1600, 'RTM ', '', '2008-08-06', '2014-07-08', '2019-07-09', 'SQL Server 2008', 'RTM ')
-- SQL Prompt formatting on
/*Checks on version*/

/* Dangerous Build of SQL Server (Corruption) */
IF (
      @ProductVersionMajor = 11
      AND @ProductVersionMinor >= 3000
      AND @ProductVersionMinor <= 3436
   )
   OR (
         @ProductVersionMajor = 11
         AND @ProductVersionMinor = 5058
      )
   OR (
         @ProductVersionMajor = 12
         AND @ProductVersionMinor >= 2000
         AND @ProductVersionMinor <= 2342
      )
BEGIN

   SET @DangerousVersionCorruption = 1;

END;

IF (
      @ProductVersionMajor = 10
      AND @ProductVersionMinor >= 5500
      AND @ProductVersionMinor <= 5512
   )
   OR (
         @ProductVersionMajor = 10
         AND @ProductVersionMinor >= 5750
         AND @ProductVersionMinor <= 5867
      )
   OR (
         @ProductVersionMajor = 10.5
         AND @ProductVersionMinor >= 4000
         AND @ProductVersionMinor <= 4017
      )
   OR (
         @ProductVersionMajor = 10.5
         AND @ProductVersionMinor >= 4251
         AND @ProductVersionMinor <= 4319
      )
   OR (
         @ProductVersionMajor = 11
         AND @ProductVersionMinor >= 3000
         AND @ProductVersionMinor <= 3129
      )
   OR (
         @ProductVersionMajor = 11
         AND @ProductVersionMinor >= 3300
         AND @ProductVersionMinor <= 3447
      )
   OR (
         @ProductVersionMajor = 12
         AND @ProductVersionMinor >= 2000
         AND @ProductVersionMinor <= 2253
      )
   OR (
         @ProductVersionMajor = 12
         AND @ProductVersionMinor >= 2300
         AND @ProductVersionMinor <= 2370
      )
BEGIN
   SET @DangerousVersionSecurity = 1;
END;

SELECT @ExtendedSupportEndDate = v.ExtendedSupportEndDate
FROM   #SqlServerVersions v
WHERE  v.MajorVersionNumber = @ProductVersionMajor
       AND v.MinorVersionNumber = @ProductVersionMinor;

SELECT   TOP (1)
         @MinorVersionAvailable = v.MinorVersionName
FROM     #SqlServerVersions v
WHERE    v.MajorVersionNumber = @ProductVersionMajor
         AND v.MinorVersionNumber > @ProductVersionMinor
ORDER BY v.MinorVersionNumber DESC;

SELECT
   @MachineName AS [Server Name],
   SUBSTRING(@@VERSION, 22, CHARINDEX(CHAR(10), @@VERSION) - 23) AS [FullVersion],
   @ProductVersion AS VersionNumber,
   @ProductVersionMajor AS VersionMajor,
   @ProductVersionMinor AS VersionMinor,
   @DangerousVersionCorruption AS VersionWithCorruptionWarnings,
   @DangerousVersionSecurity AS VersionWithSecurityWarnings,
   @ExtendedSupportEndDate AS ExtendedSupportEnd,
   @MinorVersionAvailable AS CUAvailable;


DROP TABLE #SqlServerVersions;

