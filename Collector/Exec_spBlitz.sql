EXEC dbo.sp_Blitz @Help = 1;

EXEC dbo.sp_Blitz @IgnorePrioritiesAbove = 50;

EXEC dbo.sp_Blitz @CheckUserDatabaseObjects = 0;

EXEC dbo.sp_Blitz @CheckServerInfo = 1, @BringThePain = 1; --, @OutputType = 'MARKDOWN', @OutputServerName = 'jdn-mssql01cla', @EmailRecipients = 'maarten.dierckxsens@monin-it.be';

DECLARE @Version VARCHAR(30),
        @VersionDate DATETIME;
EXEC dbo.sp_Blitz @CheckServerInfo = 1,               -- tinyint
                  @Version = @Version OUTPUT,         -- varchar(30)
                  @VersionDate = @VersionDate OUTPUT



EXEC dbo.sp_BlitzFirst @ExpertMode = 1, @ShowSleepingSPIDs = 1;

EXEC dbo.sp_BlitzIndex @DatabaseName = '', @Mode = 0;