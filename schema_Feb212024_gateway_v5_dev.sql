USE [gateway_v5_dev]
GO
/****** Object:  UserDefinedTableType [dbo].[messageList]    Script Date: 22/02/2024 00:40:03 ******/
CREATE TYPE [dbo].[messageList] AS TABLE(
	[created] [datetime] NOT NULL,
	[processed] [datetime] NULL,
	[completed] [datetime] NULL,
	[messageText] [varchar](255) NULL,
	[transactionGUID] [varchar](38) NULL,
	[source] [varchar](15) NULL,
	[destination] [varchar](15) NULL,
	[type] [varchar](5) NULL,
	[status] [varchar](10) NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[CreateDateRange]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[CreateDateRange] (@DateFrom datetime,@DateTo datetime,@DatePart varchar(10),@Incr int)
Returns 
@ReturnVal Table (RetVal datetime)

As
Begin

-- Syntax Select * from [dbo].[udf-Create-Range-Date]('2016-10-01','2020-10-01','YY',1) 
-- Syntax Select * from [dbo].[udf-Create-Range-Date]('2016-10-01','2020-10-01','DD',1) 
-- Syntax Select * from [dbo].[udf-Create-Range-Date]('2016-10-01','2016-10-31','MI',15) 
-- Syntax Select * from [dbo].[udf-Create-Range-Date]('2016-10-01','2016-10-02','SS',1) 

    With DateTable As (
        Select DateFrom = @DateFrom
        Union All
        Select Case @DatePart
               When 'YY' then DateAdd(YY, @Incr, df.dateFrom)
               When 'QQ' then DateAdd(QQ, @Incr, df.dateFrom)
               When 'MM' then DateAdd(MM, @Incr, df.dateFrom)
               When 'WK' then DateAdd(WK, @Incr, df.dateFrom)
               When 'DD' then DateAdd(DD, @Incr, df.dateFrom)
               When 'HH' then DateAdd(HH, @Incr, df.dateFrom)
               When 'MI' then DateAdd(MI, @Incr, df.dateFrom)
               When 'SS' then DateAdd(SS, @Incr, df.dateFrom)
               End
        From DateTable DF
        Where DF.DateFrom < @DateTo
    )

    Insert into @ReturnVal(RetVal) Select DateFrom From DateTable option (maxrecursion 32767)

    Return
End



GO
/****** Object:  UserDefinedFunction [dbo].[CSVToTable]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[CSVToTable] (@InStr VARCHAR(MAX))
RETURNS 
@TempTab TABLE (id INT NOT NULL)

AS
BEGIN

	--  This function takes a comma separated value string and converts it into a table with an INT column

	--  The REPLACE part ensures the string is terminated with a single comma by appending one, and removing all double commas from the string. 
	SET @InStr = REPLACE(@InStr + ',', ',,', ',')
	DECLARE @SP INT
	DECLARE @VALUE VARCHAR(1000)

	WHILE PATINDEX('%,%', @INSTR ) <> 0 
	BEGIN
   		SELECT  @SP = PATINDEX('%,%',@INSTR)
   		SELECT  @VALUE = LEFT(@INSTR , @SP - 1)
   		SELECT  @INSTR = STUFF(@INSTR, 1, @SP, '')
   		INSERT INTO @TempTab(id) VALUES (@VALUE)
	END

	RETURN

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnEndOfDay]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnEndOfDay] ( @DaysBack INT = 0 ) 
RETURNS DATETIME 
BEGIN 
    DECLARE @endDate AS DATETIME;
	SET @endDate = DATEADD(ms, -3, DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE())-@DaysBack, 0));
	RETURN @endDate; 
END








GO
/****** Object:  UserDefinedFunction [dbo].[fnEndOfMonth]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnEndOfMonth] ( @MonthsBack INT = 0 )
RETURNS DATETIME 
BEGIN 
    DECLARE @endDate AS DATETIME;
	SET @endDate = DATEADD(ms, -3, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-@MonthsBack, 0));
	RETURN @endDate; 
END







GO
/****** Object:  UserDefinedFunction [dbo].[fnGetCountryCode]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnGetCountryCode](@countryCode varchar(10), @numberNPA varchar(10))  
RETURNS varchar(10)   
AS   
-- Returns normalized country code  
BEGIN  
    DECLARE @ret varchar(10);  
	IF @countryCode = 1 
		BEGIN
			IF @numberNPA IN ('800','888','877','866','855','844')
				SET @ret = CONCAT(@countryCode,@numberNPA)
			ELSE IF @numberNPA IN ('204','226','236','249','250','289','306','343','365','403','416','418','431','437','438','450','506','514','519','548','579','581','587','604','613','639','647','705','709','778','780','782','807','819','825','867','873','902','905')
				SET @ret = '1CA'
			ELSE
				SET @ret = '1US';
		END
	ELSE
		BEGIN
			SET @ret = @countryCode
		END;
		  
    RETURN @ret;  
END



GO
/****** Object:  UserDefinedFunction [dbo].[fnGetHour]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnGetHour] ( @HoursBack INT = 0 ) 
RETURNS DATETIME 
BEGIN 
	DECLARE @startDate AS DATETIME;
	SET @startDate = DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE())-@HoursBack, 0);
	RETURN @startDate; 
END


 





GO
/****** Object:  UserDefinedFunction [dbo].[fnStartOfDay]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnStartOfDay] ( @DaysBack INT = 0 ) 
RETURNS DATETIME 
BEGIN 
	DECLARE @startDate AS DATETIME;
	SET @startDate = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE())-@DaysBack, 0);
	RETURN @startDate; 
END


 




GO
/****** Object:  UserDefinedFunction [dbo].[fnStartOfMonth]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnStartOfMonth] ( @MonthsBack INT = 0 )
RETURNS DATETIME 
BEGIN 
	DECLARE @startDate AS DATETIME;
	SET @startDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-@MonthsBack, 0);
	RETURN @startDate; 
END







GO
/****** Object:  UserDefinedFunction [dbo].[parseMessageData]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[parseMessageData]
(  
	@BinaryColumn AS BINARY(4000)
)  
RETURNS NVARCHAR(2000) 
BEGIN   
	DECLARE @Counter INT, @ColumnLength INT, @Byte BINARY, @MessageText VARCHAR(2000);

	SET @ColumnLength = LEN(@BinaryColumn);
	SET @MessageText = '';

	SET @Byte = (SELECT SUBSTRING(@BinaryColumn, 1, 1));
	IF @Byte = 0x05 
		SET @Counter = 7
	ELSE
		SET @Counter = 1;

	WHILE (@Counter <= @ColumnLength) 
	BEGIN
	    SET @Byte = (SELECT SUBSTRING(@BinaryColumn, @Counter, 1));
		IF @Byte != 0x00 SET @MessageText += CHAR(@Byte);
	    SET @Counter = @Counter + 1;
	END; 

	RETURN REPLACE(REPLACE(REPLACE(@MessageText, CHAR(13), ''), CHAR(10), ''),',',' ')  ; 
END






GO
/****** Object:  Table [dbo].[account]    Script Date: 22/02/2024 00:40:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[account](
	[accountID] [int] IDENTITY(5000,1) NOT NULL,
	[accountGUID] [char](36) NOT NULL,
	[accountParentID] [int] NOT NULL,
	[accountRegistrationID] [int] NULL,
	[accountIDPublic]  AS ([accountID]+(237425465)),
	[name] [varchar](100) NOT NULL,
	[billingType] [smallint] NOT NULL,
	[email] [varchar](100) NOT NULL,
	[phone1] [varchar](50) NOT NULL,
	[phone1isMobile] [bit] NOT NULL,
	[phone2] [varchar](50) NULL,
	[phone2isMobile] [bit] NULL,
	[address1] [varchar](50) NOT NULL,
	[address2] [varchar](50) NULL,
	[city] [varchar](50) NOT NULL,
	[state] [varchar](50) NOT NULL,
	[zip] [varchar](50) NOT NULL,
	[country] [varchar](50) NOT NULL,
	[website] [varchar](100) NULL,
	[replyAbout] [varchar](160) NULL,
	[replyHelp] [varchar](160) NULL,
	[replyStop] [varchar](160) NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[defaultConnectionID] [int] NULL,
	[isReseller] [bit] NOT NULL,
	[brandRelationship] [varchar](50) NULL,
	[cspID] [varchar](20) NULL,
	[cspEmail] [varchar](100) NULL,
	[maxConnectionsOverride] [smallint] NOT NULL,
	[deactivatedDate] [datetime] NULL,
 CONSTRAINT [PK_account] PRIMARY KEY CLUSTERED 
(
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[displayAccountNameView]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[displayAccountNameView] AS
    SELECT a.accountID, a.accountParentID,a.email, p.name AS parentAccountName, a.name AS subAccountName, p.name + ' - ' + a.name AS displayAccountName
    FROM account a
    INNER JOIN account p ON a.accountParentID = p.accountID
    WHERE a.accountParentID != 1 AND a.accountID NOT IN (0,1)
    UNION   
    SELECT a.accountID, a.accountParentID,a.email, '' AS parentAccountName, '' AS subAccountName, a.name AS displayAccountName
    FROM account a
    WHERE a.accountParentID = 1 OR a.accountID IN (1)
GO
/****** Object:  UserDefinedFunction [dbo].[ExplodeDates]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[ExplodeDates](@startdate datetime, @enddate datetime)
returns table as
return (
with 
 N0 as (SELECT 1 as n UNION ALL SELECT 1)
,N1 as (SELECT 1 as n FROM N0 t1, N0 t2)
,N2 as (SELECT 1 as n FROM N1 t1, N1 t2)
,N3 as (SELECT 1 as n FROM N2 t1, N2 t2)
,N4 as (SELECT 1 as n FROM N3 t1, N3 t2)
,N5 as (SELECT 1 as n FROM N4 t1, N4 t2)
,N6 as (SELECT 1 as n FROM N5 t1, N5 t2)
,nums as (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) as num FROM N6)
SELECT DATEADD(day,num-1,@startdate) as thedate
FROM nums
WHERE num <= DATEDIFF(day,@startdate,@enddate) + 1
);


GO
/****** Object:  Table [dbo].[accountProperty]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountProperty](
	[accountPropertyID] [int] IDENTITY(1,1) NOT NULL,
	[accountID] [int] NOT NULL,
	[accountGUID] [char](36) NOT NULL,
	[name] [char](50) NOT NULL,
	[value] [char](50) NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_accountProperty] PRIMARY KEY CLUSTERED 
(
	[accountPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[accountRegistration]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountRegistration](
	[accountRegistrationID] [int] IDENTITY(1,1) NOT NULL,
	[accountName] [varchar](100) NOT NULL,
	[address1] [varchar](50) NOT NULL,
	[address2] [varchar](50) NULL,
	[city] [varchar](25) NOT NULL,
	[state] [varchar](20) NOT NULL,
	[zip] [varchar](15) NOT NULL,
	[country] [varchar](25) NOT NULL,
	[website] [varchar](100) NULL,
	[firstName] [varchar](50) NOT NULL,
	[lastName] [varchar](50) NOT NULL,
	[email] [varchar](100) NOT NULL,
	[phone] [varchar](45) NOT NULL,
	[phoneIsMobile] [bit] NOT NULL,
	[userName] [varchar](50) NOT NULL,
	[userPassword] [varchar](50) NOT NULL,
	[termsVersion] [smallint] NOT NULL,
	[verificationKey] [char](32) NOT NULL,
	[created] [datetime] NOT NULL,
	[verified] [datetime] NULL,
	[approved] [datetime] NULL,
	[provisioned] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
	[serviceProviderAccountName] [varchar](50) NULL,
	[serviceProviderFirstName] [varchar](50) NULL,
	[serviceProviderLastName] [varchar](50) NULL,
	[serviceProviderEmail] [varchar](100) NULL,
	[serviceProviderPhone] [varchar](50) NULL,
 CONSTRAINT [PK_accountRegistration] PRIMARY KEY CLUSTERED 
(
	[accountRegistrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[accountUser]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[accountUser](
	[accountUserID] [int] IDENTITY(5000,1) NOT NULL,
	[accountUserGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[firstName] [varchar](50) NOT NULL,
	[lastName] [varchar](50) NOT NULL,
	[email] [varchar](100) NOT NULL,
	[phone1] [varchar](50) NOT NULL,
	[phone2] [varchar](50) NULL,
	[phone1isMobile] [bit] NOT NULL,
	[phone2isMobile] [bit] NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[tosAccepted] [datetime] NULL,
	[address1] [varchar](50) NULL,
	[address2] [varchar](50) NULL,
	[city] [varchar](50) NULL,
	[state] [varchar](50) NULL,
	[zip] [varchar](50) NULL,
	[country] [varchar](50) NULL,
	[portalSettings] [ntext] NULL,
 CONSTRAINT [PK_accountUser] PRIMARY KEY CLUSTERED 
(
	[accountUserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[api]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[api](
	[apiID] [int] IDENTITY(1,1) NOT NULL,
	[apiGUID] [char](36) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](255) NULL,
	[baseURI] [varchar](255) NULL,
	[baseURIDisplay] [varchar](255) NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_api] PRIMARY KEY CLUSTERED 
(
	[apiID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[apiResource]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiResource](
	[apiResourceID] [int] IDENTITY(1,1) NOT NULL,
	[apiResourceGUID] [char](36) NOT NULL,
	[apiID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](255) NULL,
	[requestMethodPost] [bit] NOT NULL,
	[requestMethodGet] [bit] NOT NULL,
	[requestMethodPut] [bit] NOT NULL,
	[requestMethodDelete] [bit] NOT NULL,
	[responseMethodJSON] [bit] NOT NULL,
	[responseMethodXML] [bit] NOT NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_apiResource] PRIMARY KEY CLUSTERED 
(
	[apiResourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[apiResourceParameter]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiResourceParameter](
	[apiResourceParameterID] [int] IDENTITY(1,1) NOT NULL,
	[apiResourceParameterGUID] [char](36) NOT NULL,
	[apiResourceID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](1000) NULL,
	[maxLength] [int] NOT NULL,
	[isRequired] [bit] NOT NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_apiResourceParameter] PRIMARY KEY CLUSTERED 
(
	[apiResourceParameterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auditTrail]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auditTrail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[auditTrailAction] [varchar](max) NOT NULL,
	[auditTrailStatus] [varchar](max) NULL,
	[auditTrailDescription] [varchar](max) NULL,
	[accountUserID] [int] NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[adminUserID] [int] NULL,
 CONSTRAINT [PK_auditTrail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[authenticationFailure]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authenticationFailure](
	[authenticationFailureID] [int] IDENTITY(1,1) NOT NULL,
	[authenticationFailureGUID] [char](36) NULL,
	[authenticationTypeID] [tinyint] NULL,
	[authenticationFailureTypeID] [tinyint] NULL,
	[ipAddress] [varchar](50) NULL,
	[username] [varchar](50) NULL,
	[password] [varchar](50) NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_authenticationFailure] PRIMARY KEY CLUSTERED 
(
	[authenticationFailureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[blockCodeNumber]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blockCodeNumber](
	[blockCodeNumberID] [int] IDENTITY(50000000,1) NOT NULL,
	[blockCodeNumberGUID] [char](36) NOT NULL,
	[blockCodeNumberType] [tinyint] NULL,
	[code] [varchar](15) NOT NULL,
	[number] [varchar](15) NOT NULL,
	[action] [tinyint] NOT NULL,
	[actionOrigin] [tinyint] NOT NULL,
	[note] [varchar](512) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[messageGUID] [char](36) NULL,
 CONSTRAINT [PK_blockCodeNumber] PRIMARY KEY CLUSTERED 
(
	[blockCodeNumberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cacheConnectionCodeAssign]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cacheConnectionCodeAssign](
	[cacheConnectionCodeAssignID] [bigint] IDENTITY(1,1) NOT NULL,
	[code] [varchar](15) NOT NULL,
	[connectionID] [int] NOT NULL,
	[cacheStatus] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_cacheConnectionCodeAssign] PRIMARY KEY CLUSTERED 
(
	[cacheConnectionCodeAssignID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[code]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[code](
	[codeID] [int] IDENTITY(50000000,1) NOT NULL,
	[codeGUID] [char](36) NOT NULL,
	[codeTypeID] [int] NOT NULL,
	[itemCode] [int] NOT NULL,
	[shared] [bit] NOT NULL,
	[code] [varchar](50) NOT NULL,
	[ton] [tinyint] NOT NULL,
	[npi] [tinyint] NOT NULL,
	[name] [varchar](100) NULL,
	[emailAddress] [varchar](75) NULL,
	[emailDomain] [varchar](50) NULL,
	[emailTemplateID] [tinyint] NULL,
	[number] [varchar](15) NULL,
	[codeRegistrationID] [int] NOT NULL,
	[espid] [varchar](10) NULL,
	[netNumberID] [int] NULL,
	[providerID] [int] NOT NULL,
	[voice] [bit] NOT NULL,
	[voiceForwardTypeID] [tinyint] NULL,
	[voiceForwardDestination] [varchar](255) NULL,
	[publishStatus] [bit] NULL,
	[publishUpdate] [tinyint] NULL,
	[notePrivate] [varchar](255) NULL,
	[replyHelp] [varchar](160) NULL,
	[replyStop] [varchar](160) NULL,
	[available] [bit] NULL,
	[surcharge] [bit] NULL,
	[active] [bit] NOT NULL,
	[deactivated] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[audit] [bit] NULL,
	[campaignID] [varchar](10) NULL,
	[mnoStatus] [varchar](2000) NULL,
	[mnoIsPool] [bit] NULL,
 CONSTRAINT [PK_code] PRIMARY KEY CLUSTERED 
(
	[codeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeAudit]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeAudit](
	[codeAuditID] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](15) NOT NULL,
	[espid] [varchar](10) NULL,
	[netNumberID] [int] NULL,
	[espidAudit] [varchar](10) NULL,
	[netNumberIDAudit] [int] NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_codeAudit] PRIMARY KEY CLUSTERED 
(
	[codeAuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeOverride]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeOverride](
	[codeOverrideID] [int] IDENTITY(1,1) NOT NULL,
	[codeOverrideGUID] [char](36) NOT NULL,
	[connectionID] [int] NOT NULL,
	[code] [varchar](15) NOT NULL,
	[number] [varchar](15) NOT NULL,
	[replacementCode] [varchar](15) NOT NULL,
	[action] [tinyint] NOT NULL,
	[note] [varchar](512) NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_codeOverride] PRIMARY KEY CLUSTERED 
(
	[codeOverrideID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeParameter]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeParameter](
	[codeParameterID] [int] IDENTITY(1,1) NOT NULL,
	[codeParameterGUID] [char](36) NOT NULL,
	[codeParameterTypeID] [smallint] NOT NULL,
	[codeID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[value] [varchar](100) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_codeParameter] PRIMARY KEY CLUSTERED 
(
	[codeParameterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codePublishLog]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codePublishLog](
	[codePublishLogID] [int] IDENTITY(1,1) NOT NULL,
	[filename] [varchar](150) NULL,
	[transferSuccess] [smallint] NULL,
	[count] [int] NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_codePublishLog] PRIMARY KEY CLUSTERED 
(
	[codePublishLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeRegistration]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeRegistration](
	[codeRegistrationID] [int] IDENTITY(5000000,1) NOT NULL,
	[codeRegistrationGUID] [char](36) NOT NULL,
	[codeTypeID] [int] NOT NULL,
	[code] [varchar](50) NOT NULL,
	[ton] [tinyint] NULL,
	[npi] [tinyint] NULL,
	[connectionID] [int] NULL,
	[name] [varchar](100) NULL,
	[codeSourceID] [int] NULL,
	[assigneeName] [varchar](100) NULL,
	[assigneeAddress1] [varchar](50) NULL,
	[assigneeAddress2] [varchar](50) NULL,
	[assigneeCity] [varchar](50) NULL,
	[assigneeState] [varchar](50) NULL,
	[assigneeZip] [varchar](50) NULL,
	[documentURL] [varchar](255) NULL,
	[notePublic] [varchar](255) NULL,
	[notePrivate] [varchar](255) NULL,
	[status] [tinyint] NOT NULL,
	[created] [datetime] NOT NULL,
	[verified] [datetime] NULL,
	[completed] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
	[termsAccept] [smallint] NULL,
 CONSTRAINT [PK_codeRegistration] PRIMARY KEY CLUSTERED 
(
	[codeRegistrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeRegistryParameterTSS]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeRegistryParameterTSS](
	[codeRegistryParameterTSSID] [int] IDENTITY(1,1) NOT NULL,
	[accountID] [int] NOT NULL,
	[tspid] [int] NOT NULL,
	[businessName] [varchar](50) NOT NULL,
	[contactName] [varchar](50) NOT NULL,
	[contactJobTitle] [varchar](50) NOT NULL,
	[contactPhone] [varchar](15) NOT NULL,
	[contactEmail] [varchar](50) NOT NULL,
	[url] [varchar](250) NOT NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NULL,
 CONSTRAINT [PK_codeRegistryParameterTSS] PRIMARY KEY CLUSTERED 
(
	[codeRegistryParameterTSSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[codeType]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[codeType](
	[codeTypeID] [int] NOT NULL,
	[codeTypeCode] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_codeType] PRIMARY KEY CLUSTERED 
(
	[codeTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[connection]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[connection](
	[connectionID] [int] IDENTITY(5000,1) NOT NULL,
	[connectionGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[name] [varchar](100) NOT NULL,
	[codeDistributionMethodID] [tinyint] NOT NULL,
	[defaultCodeID] [int] NULL,
	[destinationNumberFormat] [bit] NOT NULL,
	[enforceOptOut] [bit] NOT NULL,
	[disableInNetworkRouting] [bit] NULL,
	[messageExpirationHours] [smallint] NULL,
	[segmentedMessageOption] [smallint] NOT NULL,
	[replyHelp] [varchar](160) NULL,
	[replyStop] [varchar](160) NULL,
	[registeredDeliveryDisable] [bit] NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[enableInboundSC] [tinyint] NOT NULL,
	[utf16HttpStrip] [bit] NOT NULL,
	[spamFilterMO] [bit] NOT NULL,
	[spamFilterMT] [bit] NOT NULL,
	[s3Bucket] [varchar](250) NULL,
	[s3ApiKey] [varchar](50) NULL,
	[s3ApiSecret] [varchar](50) NULL,
	[s3Params] [varchar](2000) NULL,
	[spamOfflineMO] [bit] NOT NULL,
	[spamOfflineMT] [bit] NOT NULL,
	[moHttpTlvs] [bit] NOT NULL,
 CONSTRAINT [PK_connection] PRIMARY KEY CLUSTERED 
(
	[connectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[connectionAuthorization]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[connectionAuthorization](
	[connectionAuthorizationID] [bigint] IDENTITY(1,1) NOT NULL,
	[connectionID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_connectionAuthorization] PRIMARY KEY CLUSTERED 
(
	[connectionAuthorizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[connectionCodeAssign]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[connectionCodeAssign](
	[connectionID] [int] NOT NULL,
	[codeID] [int] NOT NULL,
	[default] [bit] NULL,
	[created] [datetime] NOT NULL,
	[created2] [date] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_connectionCodeAssign] PRIMARY KEY CLUSTERED 
(
	[connectionID] ASC,
	[codeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[connectionCodeAssignHistory]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[connectionCodeAssignHistory](
	[connectionCodeAssignHistoryID] [int] IDENTITY(50000000,1) NOT NULL,
	[connectionID] [int] NOT NULL,
	[codeID] [int] NOT NULL,
	[action] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[created2] [date] NOT NULL,
 CONSTRAINT [PK_connectionCodeAssignHistory] PRIMARY KEY CLUSTERED 
(
	[connectionCodeAssignHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[connectionRole]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[connectionRole](
	[connectionRoleID] [bigint] IDENTITY(1,1) NOT NULL,
	[connectionID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_connectionRole] PRIMARY KEY CLUSTERED 
(
	[connectionRoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[credential]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[credential](
	[credentialID] [int] IDENTITY(5000,1) NOT NULL,
	[credentialGUID] [char](36) NOT NULL,
	[connectionID] [int] NOT NULL,
	[name] [varchar](100) NULL,
	[apiKey] [char](32) NOT NULL,
	[apiSecret] [char](32) NOT NULL,
	[systemID] [char](8) NULL,
	[password] [char](8) NULL,
	[firewallRequired] [bit] NOT NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_credential] PRIMARY KEY CLUSTERED 
(
	[credentialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[firewall]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[firewall](
	[firewallID] [int] IDENTITY(5000,1) NOT NULL,
	[firewallGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[ipAddress] [varchar](50) NOT NULL,
	[ipSubnet] [tinyint] NOT NULL,
	[active] [bit] NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_firewall] PRIMARY KEY CLUSTERED 
(
	[firewallID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[httpCapture]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[httpCapture](
	[httpCaptureID] [int] IDENTITY(1,1) NOT NULL,
	[httpCaptureGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[transactionGUID] [char](36) NULL,
	[remoteAddress] [varchar](15) NULL,
	[userAgent] [varchar](255) NULL,
	[requestMethod] [varchar](10) NULL,
	[queryString] [varchar](max) NULL,
	[requestBody] [varchar](max) NULL,
	[completed] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_httpCapture] PRIMARY KEY CLUSTERED 
(
	[httpCaptureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[item]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item](
	[itemCode] [int] NOT NULL,
	[name] [varchar](45) NULL,
	[created] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_item] PRIMARY KEY CLUSTERED 
(
	[itemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[keyword]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[keyword](
	[keywordID] [int] IDENTITY(5000,1) NOT NULL,
	[keywordGUID] [char](36) NOT NULL,
	[connectionID] [int] NOT NULL,
	[codeID] [int] NOT NULL,
	[keyword] [varchar](50) NOT NULL,
	[keywordReply] [varchar](160) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[active] [bit] NOT NULL,
 CONSTRAINT [PK_keyword] PRIMARY KEY CLUSTERED 
(
	[keywordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[loadCode]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[loadCode](
	[code] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[loadPathfinderAnnexure]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[loadPathfinderAnnexure](
	[CountryCode] [varchar](50) NULL,
	[CountryName] [varchar](100) NULL,
	[SPNName] [varchar](100) NULL,
	[SPN] [char](10) NULL,
	[SPNType] [varchar](50) NULL,
	[MCC] [char](10) NULL,
	[MNC] [char](10) NULL,
	[PrimaryMCCMNC] [char](10) NULL,
	[ALTSPN] [char](10) NULL,
	[ParentSPN] [char](10) NULL,
	[NumberBlock] [char](10) NULL,
	[Onboard] [char](10) NULL,
	[Remote] [varchar](50) NULL,
	[RemoteFull] [varchar](50) NULL,
	[FixedGeo] [char](10) NULL,
	[FixedPremium] [char](10) NULL,
	[FixedNonGeo] [char](10) NULL,
	[Mobile] [char](10) NULL,
	[MobileCDMA] [char](10) NULL,
	[MobileGT] [char](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[maintenanceSchedule]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[maintenanceSchedule](
	[maintenanceScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[maintenanceScheduleGUID] [char](36) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[description] [varchar](max) NOT NULL,
	[start] [datetime] NOT NULL,
	[end] [datetime] NOT NULL,
	[reoccurring] [bit] NOT NULL,
	[pattern] [varchar](10) NULL,
	[active] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_maintenanceSchedule] PRIMARY KEY CLUSTERED 
(
	[maintenanceScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[message]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[message](
	[messageID] [bigint] IDENTITY(1,1) NOT NULL,
	[messageGUID] [char](36) NOT NULL,
	[messageType] [varchar](20) NOT NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NOT NULL,
	[source] [varchar](50) NOT NULL,
	[destination] [varchar](50) NOT NULL,
	[audit] [datetime] NOT NULL,
	[redeliver] [bit] NOT NULL,
	[messageText] [nvarchar](2000) NULL,
	[messageMetadata] [nvarchar](max) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_message] PRIMARY KEY CLUSTERED 
(
	[messageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[messageResult]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[messageResult](
	[messageResultID] [bigint] IDENTITY(1,1) NOT NULL,
	[messageResultGUID] [char](36) NOT NULL,
	[messageGUID] [char](36) NOT NULL,
	[redeliver] [bit] NOT NULL,
	[result] [smallint] NOT NULL,
	[auditResult] [datetime] NULL,
	[auditRecordResult] [datetime] NULL,
	[messageResultMetadata] [nvarchar](max) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_messageResult] PRIMARY KEY CLUSTERED 
(
	[messageResultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[notificationSubscription]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notificationSubscription](
	[notificationSubscriptionID] [int] IDENTITY(1,1) NOT NULL,
	[connectionID] [int] NOT NULL,
	[notificationType] [varchar](50) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_notificationSubscription] PRIMARY KEY CLUSTERED 
(
	[notificationSubscriptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[number]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[number](
	[numberID] [int] IDENTITY(500000000,1) NOT NULL,
	[numberGUID] [char](36) NOT NULL,
	[number] [varchar](50) NOT NULL,
	[countryCode] [int] NOT NULL,
	[numberOperatorID] [int] NOT NULL,
	[wireless] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_number] PRIMARY KEY CLUSTERED 
(
	[numberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberAreaPrefix]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberAreaPrefix](
	[npa] [int] NOT NULL,
	[nxx] [int] NOT NULL,
	[stateCodeAlpha2] [char](2) NULL,
	[rateCenter] [varchar](50) NULL,
	[utcOffset] [smallint] NULL,
	[daylightSavings] [char](1) NULL,
 CONSTRAINT [PK_numberAreaPrefix] PRIMARY KEY CLUSTERED 
(
	[npa] ASC,
	[nxx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberCountry]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberCountry](
	[countryCode] [int] NOT NULL,
	[countryName] [varchar](255) NULL,
	[countryCodeAlpha2] [char](2) NOT NULL,
	[zoneCode] [int] NULL,
	[gmtOffsetStart] [smallint] NULL,
	[gmtOffsetEnd] [smallint] NULL,
 CONSTRAINT [PK_numberCountry] PRIMARY KEY CLUSTERED 
(
	[countryCode] ASC,
	[countryCodeAlpha2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberCountryNPAExtended]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberCountryNPAExtended](
	[countryCode] [int] NOT NULL,
	[countryName] [varchar](150) NOT NULL,
	[countryCodeNormalized] [varchar](4) NULL,
 CONSTRAINT [PK_numberCountryNPAExtended] PRIMARY KEY CLUSTERED 
(
	[countryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberCountryNPAOverride]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberCountryNPAOverride](
	[numberCountryNPAOverrideID] [int] IDENTITY(1,1) NOT NULL,
	[numberCountryNPAOverrideGUID] [char](36) NOT NULL,
	[connectionID] [int] NOT NULL,
	[codeID] [int] NOT NULL,
	[countryCodeNormalized] [varchar](5) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_numberCountryNPAOverride] PRIMARY KEY CLUSTERED 
(
	[numberCountryNPAOverrideID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberCountrySurcharge]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberCountrySurcharge](
	[countryCode] [int] NULL,
	[countryName] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberOperator]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberOperator](
	[numberOperatorID] [int] IDENTITY(1,1) NOT NULL,
	[numberOperatorGUID] [char](36) NOT NULL,
	[providerSPN] [varchar](50) NOT NULL,
	[providerAltSPN] [varchar](50) NULL,
	[providerParentSPN] [varchar](50) NULL,
	[primaryMCCMNC] [char](1) NULL,
	[operatorParent] [smallint] NULL,
	[operatorName] [varchar](100) NOT NULL,
	[operatorType] [varchar](50) NOT NULL,
	[countryCode] [int] NOT NULL,
	[mcc] [char](3) NULL,
	[mnc] [char](3) NULL,
	[wireless] [char](1) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_numberOperator] PRIMARY KEY CLUSTERED 
(
	[numberOperatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberOperatorNetNumber]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberOperatorNetNumber](
	[numberOperatorID] [int] NOT NULL,
	[numberOperatorIDPublic]  AS (concat((38),[numberOperatorID])),
	[numberOperatorGUID] [char](36) NOT NULL,
	[serviceProvider] [varchar](255) NULL,
	[serviceProviderPublic]  AS (replace(replace([serviceProvider],'Syniverse',''),'Sybase365','')),
	[networkProvider] [varchar](255) NULL,
	[operatorType] [varchar](25) NULL,
	[mcc] [varchar](255) NULL,
	[mnc] [varchar](255) NULL,
	[countryCode] [int] NULL,
	[countryAbbreviation] [varchar](5) NULL,
	[countryName] [varchar](100) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_numberOperatorNetNumber] PRIMARY KEY CLUSTERED 
(
	[numberOperatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberOperatorSyniverse]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberOperatorSyniverse](
	[numberOperatorID] [int] NOT NULL,
	[numberOperatorIDPublic]  AS (concat((38),[numberOperatorID])),
	[numberOperatorGUID] [char](36) NOT NULL,
	[numberOperatorParentID] [int] NULL,
	[serviceProvider] [varchar](255) NULL,
	[serviceProviderPublic]  AS (replace(replace(replace(replace(replace(replace(replace([serviceProvider],'Syniverse',''),'Sybase365',''),'360 NETWORKS',''),'BANDWIDTH.COM',''),'BANDWIDTH',''),'SAP',''),'LAB','')),
	[operatorType] [varchar](25) NULL,
	[mcc] [varchar](255) NULL,
	[mnc] [varchar](255) NULL,
	[countryName] [varchar](100) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_numberOperatorSyniverse] PRIMARY KEY CLUSTERED 
(
	[numberOperatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberState]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberState](
	[stateCodeAlpha2] [char](10) NOT NULL,
	[stateName] [varchar](50) NOT NULL,
	[countryCodeAlpha3] [varchar](50) NOT NULL,
 CONSTRAINT [PK_numberState] PRIMARY KEY CLUSTERED 
(
	[stateCodeAlpha2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[numberZone]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[numberZone](
	[numberZoneCode] [int] NOT NULL,
	[name] [varchar](50) NULL,
 CONSTRAINT [PK_numberZone] PRIMARY KEY CLUSTERED 
(
	[numberZoneCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[partnerCampaign]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[partnerCampaign](
	[partnerCampaignId] [int] IDENTITY(1,1) NOT NULL,
	[campaignId] [varchar](20) NOT NULL,
	[downstreamCnpId] [varchar](20) NULL,
	[upstreamCnpId] [varchar](20) NULL,
	[sharingStatus] [varchar](20) NULL,
	[sharedDate] [datetime] NULL,
	[statusDate] [datetime] NULL,
	[attRecordStatus] [varchar](20) NULL,
	[tmobileRecordStatus] [varchar](20) NULL,
	[uscellularRecordStatus] [varchar](20) NULL,
	[verizonRecordStatus] [varchar](20) NULL,
	[published] [bit] NOT NULL,
	[accountID] [int] NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[readyToPublish] [bit] NOT NULL,
	[mnoIsPool] [bit] NULL,
	[brandId] [varchar](20) NULL,
	[usecase] [varchar](50) NULL,
	[status] [varchar](20) NULL,
	[createDate] [datetime] NULL,
	[deploymentStatus] [varchar](25) NULL,
	[deploymentUpdated] [datetime] NULL,
	[description] [varchar](4096) NULL,
	[subscriberOptin] [bit] NULL,
	[subscriberOptout] [bit] NULL,
	[subscriberHelp] [bit] NULL,
	[directLending] [bit] NULL,
	[numberPool] [bit] NULL,
	[embeddedLink] [bit] NULL,
	[embeddedPhone] [bit] NULL,
	[ageGated] [bit] NULL,
	[sample1] [varchar](1024) NULL,
	[sample2] [varchar](1024) NULL,
	[sample3] [varchar](1024) NULL,
	[sample4] [varchar](1024) NULL,
	[sample5] [varchar](1024) NULL,
	[messageFlow] [varchar](2048) NULL,
	[optinKeywords] [varchar](255) NULL,
	[optoutKeywords] [varchar](255) NULL,
	[helpKeywords] [varchar](255) NULL,
	[optinMessage] [varchar](320) NULL,
	[optoutMessage] [varchar](320) NULL,
	[helpMessage] [varchar](320) NULL,
	[sharedCampaignBrand] [varchar](4096) NULL,
	[clearskyRecordStatus] [varchar](20) NULL,
	[interopRecordStatus] [varchar](20) NULL,
 CONSTRAINT [PK_partnerCampaign] PRIMARY KEY CLUSTERED 
(
	[partnerCampaignId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[partnerCampaignCode]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[partnerCampaignCode](
	[partnerCampaignCodeId] [int] IDENTITY(1,1) NOT NULL,
	[campaignId] [varchar](20) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_partnerCampaignCode] PRIMARY KEY CLUSTERED 
(
	[partnerCampaignCodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[partnerCampaignLog]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[partnerCampaignLog](
	[partnerCampaignLogId] [int] IDENTITY(1,1) NOT NULL,
	[campaignId] [varchar](20) NOT NULL,
	[downstreamCnpId] [varchar](20) NULL,
	[upstreamCnpId] [varchar](20) NULL,
	[sharingStatus] [varchar](20) NULL,
	[sharedDate] [datetime] NULL,
	[statusDate] [datetime] NULL,
	[statusMessage] [varchar](2000) NULL,
	[recordStatus] [varchar](20) NOT NULL,
	[accountID] [int] NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_partnerCampaignLog] PRIMARY KEY CLUSTERED 
(
	[partnerCampaignLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[provider]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[provider](
	[providerID] [int] NOT NULL,
	[providerGUID] [char](36) NOT NULL,
	[providerCode] [int] NOT NULL,
	[providerTypeCode] [varchar](25) NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](50) NULL,
	[displayName] [varchar](50) NULL,
	[active] [bit] NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_provider] PRIMARY KEY CLUSTERED 
(
	[providerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[route]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[route](
	[routeID] [int] IDENTITY(5000,1) NOT NULL,
	[routeGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NULL,
	[acceptDeny] [smallint] NOT NULL,
	[sourceCodeCompare] [varchar](50) NULL,
	[destinationCodeCompare] [varchar](50) NULL,
	[messageDataCompare] [varchar](max) NULL,
	[numberOperatorID] [int] NOT NULL,
	[routeSequence] [int] NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_route] PRIMARY KEY CLUSTERED 
(
	[routeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[routeAction]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[routeAction](
	[routeActionID] [int] IDENTITY(50000,1) NOT NULL,
	[routeActionGUID] [char](36) NOT NULL,
	[routeID] [int] NOT NULL,
	[routeActionTypeID] [int] NOT NULL,
	[routeActionValue] [int] NOT NULL,
	[active] [bit] NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[routeActionSequence] [smallint] NOT NULL,
 CONSTRAINT [PK_routeAction] PRIMARY KEY CLUSTERED 
(
	[routeActionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[routeActionType]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[routeActionType](
	[routeActionTypeID] [int] IDENTITY(1,1) NOT NULL,
	[routeActionTypeGUID] [char](36) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_routeActionType] PRIMARY KEY CLUSTERED 
(
	[routeActionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[routeConnection]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[routeConnection](
	[routeConnectionID] [int] IDENTITY(500000,1) NOT NULL,
	[routeConnectionGUID] [char](36) NOT NULL,
	[accountID] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[protocol] [varchar](50) NULL,
	[method] [varchar](50) NULL,
	[host] [varchar](100) NULL,
	[port] [int] NULL,
	[path] [varchar](100) NULL,
	[queryString] [varchar](255) NULL,
	[userName] [varchar](50) NULL,
	[password] [varchar](50) NULL,
	[created] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[active] [bit] NULL,
 CONSTRAINT [PK_routeConnection] PRIMARY KEY CLUSTERED 
(
	[routeConnectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[schema_migrations]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[schema_migrations](
	[version] [varchar](255) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sysdiagrams]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysdiagrams](
	[name] [nvarchar](160) NOT NULL,
	[principal_id] [int] NOT NULL,
	[diagram_id] [int] NOT NULL,
	[version] [int] NULL,
	[definition] [varbinary](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SchemaLog]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SchemaLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LogDate] [datetime] NULL,
	[DatabaseName] [nvarchar](100) NULL,
	[LoginName] [nvarchar](100) NULL,
	[IPAddress] [nvarchar](50) NULL,
	[HostName] [nvarchar](50) NULL,
	[EventType] [nvarchar](100) NULL,
	[ObjectName] [nvarchar](100) NULL,
	[ObjectType] [nvarchar](100) NULL,
	[SqlQuery] [ntext] NULL,
	[EventData] [xml] NULL,
 CONSTRAINT [PK__tbl_Admi__3214EC07C6815E56] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[timezone]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[timezone](
	[timezoneID] [tinyint] IDENTITY(1,1) NOT NULL,
	[timezoneLocation] [varchar](30) NOT NULL,
	[gmtDescription] [varchar](11) NOT NULL,
	[gmtOffset] [smallint] NOT NULL,
 CONSTRAINT [PK_timezone] PRIMARY KEY CLUSTERED 
(
	[timezoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnCodeAudit]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnCodeAudit](
	[auditDate] [datetime] NOT NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NULL,
	[codeID] [int] NOT NULL,
	[code] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnNumber]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnNumber](
	[txnNumberID] [bigint] IDENTITY(1,1) NOT NULL,
	[txnNumberGUID] [char](36) NULL,
	[accountID] [int] NULL,
	[connectionID] [int] NOT NULL,
	[providerID] [int] NOT NULL,
	[providerName] [varchar](50) NULL,
	[mode] [smallint] NULL,
	[destinationNumber] [varchar](50) NOT NULL,
	[destinationNumberCountryCode] [varchar](50) NOT NULL,
	[destinationNumberNPA] [varchar](50) NOT NULL,
	[destinationNumberNXX] [varchar](50) NOT NULL,
	[destinationNumberOperatorID] [int] NOT NULL,
	[spn] [varchar](50) NULL,
	[mcc] [varchar](500) NULL,
	[mnc] [varchar](500) NULL,
	[wireless] [bit] NULL,
	[cache] [bit] NOT NULL,
	[created] [datetime] NOT NULL,
	[processed] [datetime] NULL,
	[completed] [datetime] NULL,
	[lastUpdated] [datetime] NOT NULL,
	[deactivationCarrierID] [int] NULL,
	[deactivationCarrierName] [varchar](150) NULL,
	[deactivationDate] [datetime] NULL,
 CONSTRAINT [PK_txnNumber] PRIMARY KEY CLUSTERED 
(
	[txnNumberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnSurcharge]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnSurcharge](
	[logged] [varchar](50) NULL,
	[accountIDPublic] [int] NULL,
	[accountName] [varchar](100) NULL,
	[operatorID] [varchar](50) NULL,
	[operatorName] [varchar](50) NULL,
	[mtCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnVoiceOrig]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnVoiceOrig](
	[txnVoiceID] [bigint] IDENTITY(1,1) NOT NULL,
	[txnVoiceGUID] [char](36) NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NOT NULL,
	[providerID] [int] NULL,
	[sipServer] [varchar](50) NOT NULL,
	[cdrGUID] [varchar](36) NOT NULL,
	[sourceNumber] [varchar](15) NOT NULL,
	[sourceNumberCountryCode] [varchar](4) NULL,
	[sourceNumberNPA] [varchar](3) NULL,
	[sourceNumberNXX] [varchar](3) NULL,
	[sourceIPAddress] [varchar](20) NULL,
	[destinationCode] [varchar](15) NOT NULL,
	[destinationCountryCode] [varchar](4) NULL,
	[destinationCodeNPA] [varchar](3) NULL,
	[destinationCodeNXX] [varchar](3) NULL,
	[providerName] [varchar](50) NULL,
	[created] [datetime] NOT NULL,
	[completed] [datetime] NULL,
	[duration] [int] NULL,
	[terminationCauseID] [int] NULL,
	[terminationCauseMessage] [varchar](250) NULL,
	[forwardType] [varchar](15) NULL,
	[lastUpdated] [datetime] NOT NULL,
	[archived] [bit] NULL,
	[minutes]  AS (ceiling(([duration]*(1.0))/(60.0))),
 CONSTRAINT [PK_txnVoiceOrig] PRIMARY KEY CLUSTERED 
(
	[txnVoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[txnVoiceTerm]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnVoiceTerm](
	[txnVoiceID] [bigint] IDENTITY(1,1) NOT NULL,
	[txnVoiceGUID] [char](36) NULL,
	[accountID] [int] NOT NULL,
	[connectionID] [int] NOT NULL,
	[providerID] [int] NULL,
	[sipServer] [varchar](50) NOT NULL,
	[cdrGUID] [varchar](36) NOT NULL,
	[sourceCode] [varchar](15) NOT NULL,
	[sourceCountryCode] [varchar](4) NULL,
	[sourceCodeNPA] [varchar](3) NULL,
	[sourceCodeNXX] [varchar](3) NULL,
	[sourceIPAddress] [varchar](20) NULL,
	[destinationIPAddress] [varchar](20) NULL,
	[destinationNumber] [varchar](15) NOT NULL,
	[destinationCountryCode] [varchar](4) NULL,
	[destinationNumberNPA] [varchar](3) NULL,
	[destinationNumberNXX] [varchar](3) NULL,
	[providerName] [varchar](50) NULL,
	[created] [datetime] NOT NULL,
	[completed] [datetime] NULL,
	[duration] [int] NULL,
	[terminationCauseID] [int] NULL,
	[terminationCauseMessage] [varchar](250) NULL,
	[forwardType] [varchar](15) NULL,
	[lastUpdated] [datetime] NOT NULL,
	[archived] [bit] NULL,
	[minutes]  AS (ceiling(([duration]*(1.0))/(60.0))),
 CONSTRAINT [PK_txnVoiceTerm] PRIMARY KEY CLUSTERED 
(
	[txnVoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xDialogueComm_Codes]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xDialogueComm_Codes](
	[code] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xnpa-nxx-can-ctr-full]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xnpa-nxx-can-ctr-full](
	[Area Code] [varchar](50) NULL,
	[Prefix] [varchar](50) NULL,
	[Province] [varchar](50) NULL,
	[RateCenter] [varchar](50) NULL,
	[Time Zone] [varchar](50) NULL,
	[DST] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xnpa-nxx-ctr-full]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xnpa-nxx-ctr-full](
	[Area Code] [varchar](50) NULL,
	[Prefix] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[RateCenter] [varchar](50) NULL,
	[Time Zone] [varchar](50) NULL,
	[DST] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xnumberAreaPrefix]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xnumberAreaPrefix](
	[npa] [int] NOT NULL,
	[nxx] [int] NOT NULL,
	[stateCodeAlpha2] [char](2) NULL,
	[rateCenter] [varchar](50) NULL,
	[utcOffset] [smallint] NULL,
	[daylightSavings] [char](1) NULL,
 CONSTRAINT [PK_xnumberAreaPrefix] PRIMARY KEY CLUSTERED 
(
	[npa] ASC,
	[nxx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[xTempBulkAction]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[xTempBulkAction](
	[code] [varchar](15) NOT NULL,
	[codeRegistrationID] [int] NULL,
	[connectionID] [int] NULL,
 CONSTRAINT [PK_xTempBulkAction] PRIMARY KEY CLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_accountUser_accountUserID_active]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_accountUser_accountUserID_active] ON [dbo].[accountUser]
(
	[accountUserID] ASC,
	[active] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_accountId_auditTrail]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_accountId_auditTrail] ON [dbo].[auditTrail]
(
	[accountID] ASC,
	[connectionID] ASC
)
INCLUDE([auditTrailStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_Created] ON [dbo].[auditTrail]
(
	[created] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_blockCodeNumber_action]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_blockCodeNumber_action] ON [dbo].[blockCodeNumber]
(
	[action] ASC
)
INCLUDE([blockCodeNumberID],[code],[number]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_blockCodeNumber_blockCodeNumberType]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_blockCodeNumber_blockCodeNumberType] ON [dbo].[blockCodeNumber]
(
	[blockCodeNumberType] ASC
)
INCLUDE([code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_blockCodeNumber_code_number]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_blockCodeNumber_code_number] ON [dbo].[blockCodeNumber]
(
	[code] ASC,
	[number] ASC
)
INCLUDE([action]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_active]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_active] ON [dbo].[code]
(
	[active] ASC
)
INCLUDE([codeID],[shared],[code],[providerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_active_code]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_active_code] ON [dbo].[code]
(
	[active] ASC,
	[code] ASC
)
INCLUDE([codeID],[ton],[npi]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_active_emailAddress]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_active_emailAddress] ON [dbo].[code]
(
	[active] ASC,
	[emailAddress] ASC
)
INCLUDE([codeID],[code],[emailTemplateID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_available]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_available] ON [dbo].[code]
(
	[available] ASC
)
INCLUDE([code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_code]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_code] ON [dbo].[code]
(
	[code] ASC
)
INCLUDE([codeID],[providerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_code_active_available]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_code_active_available] ON [dbo].[code]
(
	[code] ASC,
	[active] ASC,
	[available] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_codeGUID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_codeGUID] ON [dbo].[code]
(
	[codeGUID] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_codeID_active]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_codeID_active] ON [dbo].[code]
(
	[codeID] ASC,
	[active] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_providerID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_providerID] ON [dbo].[code]
(
	[providerID] ASC
)
INCLUDE([code]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_publishStatus_espid]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_publishStatus_espid] ON [dbo].[code]
(
	[publishStatus] ASC,
	[espid] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_code_publishUpdate]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_publishUpdate] ON [dbo].[code]
(
	[publishUpdate] ASC
)
INCLUDE([codeID],[code],[espid],[publishStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_code_voice_active_voiceForwardTypeID_voiceForwardDestination]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_code_voice_active_voiceForwardTypeID_voiceForwardDestination] ON [dbo].[code]
(
	[voice] ASC,
	[active] ASC,
	[voiceForwardTypeID] ASC,
	[voiceForwardDestination] ASC
)
INCLUDE([codeID],[code],[codeRegistrationID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_codeOverride_action]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_codeOverride_action] ON [dbo].[codeOverride]
(
	[action] ASC
)
INCLUDE([codeOverrideID],[code],[replacementCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_codeOverride_code_replacementCode]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_codeOverride_code_replacementCode] ON [dbo].[codeOverride]
(
	[code] ASC,
	[replacementCode] ASC
)
INCLUDE([action]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_codeID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [idx_codeID] ON [dbo].[codeParameter]
(
	[codeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connection_defaultCodeID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connection_defaultCodeID] ON [dbo].[connection]
(
	[defaultCodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionAuthorization_connectionID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionAuthorization_connectionID] ON [dbo].[connectionAuthorization]
(
	[connectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssign_codeID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssign_codeID] ON [dbo].[connectionCodeAssign]
(
	[codeID] ASC
)
INCLUDE([connectionID],[default]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssign_created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssign_created] ON [dbo].[connectionCodeAssign]
(
	[created] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_action]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_action] ON [dbo].[connectionCodeAssignHistory]
(
	[action] ASC
)
INCLUDE([connectionID],[codeID],[created]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_action_created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_action_created] ON [dbo].[connectionCodeAssignHistory]
(
	[action] ASC,
	[created] ASC
)
INCLUDE([connectionID],[codeID],[created2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_codeID_created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_codeID_created] ON [dbo].[connectionCodeAssignHistory]
(
	[codeID] ASC,
	[created] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_connectionID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_connectionID] ON [dbo].[connectionCodeAssignHistory]
(
	[connectionID] ASC
)
INCLUDE([codeID],[created2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_connectionID_action]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_connectionID_action] ON [dbo].[connectionCodeAssignHistory]
(
	[connectionID] ASC,
	[action] ASC
)
INCLUDE([codeID],[created]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_connectionID_action_created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_connectionID_action_created] ON [dbo].[connectionCodeAssignHistory]
(
	[connectionID] ASC,
	[action] ASC,
	[created] ASC
)
INCLUDE([codeID],[created2]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_connectionID_created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_connectionID_created] ON [dbo].[connectionCodeAssignHistory]
(
	[connectionID] ASC,
	[created] ASC
)
INCLUDE([codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionCodeAssignHistory_created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionCodeAssignHistory_created] ON [dbo].[connectionCodeAssignHistory]
(
	[created] ASC
)
INCLUDE([connectionID],[codeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_connectionRole_connectionID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_connectionRole_connectionID] ON [dbo].[connectionRole]
(
	[connectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_firewall_firewallID_accountID_connectionID_active]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_firewall_firewallID_accountID_connectionID_active] ON [dbo].[firewall]
(
	[firewallID] ASC,
	[accountID] ASC,
	[connectionID] ASC,
	[active] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_firewall_ipAddress]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_firewall_ipAddress] ON [dbo].[firewall]
(
	[ipAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [AK_message_messageGUID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_message_messageGUID] ON [dbo].[message]
(
	[messageGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_notificationSubscription_connectionID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_notificationSubscription_connectionID] ON [dbo].[notificationSubscription]
(
	[connectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_number_number]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_number_number] ON [dbo].[number]
(
	[number] ASC
)
INCLUDE([numberID],[countryCode],[numberOperatorID],[numberGUID],[wireless],[created],[lastUpdated]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_number_number_lastUpdated_numberOperatorID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_number_number_lastUpdated_numberOperatorID] ON [dbo].[number]
(
	[number] ASC,
	[lastUpdated] ASC,
	[numberOperatorID] ASC
)
INCLUDE([numberID],[numberGUID],[countryCode],[wireless],[created]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_number_numberOperatorID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_number_numberOperatorID] ON [dbo].[number]
(
	[numberOperatorID] ASC
)
INCLUDE([numberID],[numberGUID],[countryCode],[wireless]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_numberAreaPrefix_stateCodeAlpha2]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_numberAreaPrefix_stateCodeAlpha2] ON [dbo].[numberAreaPrefix]
(
	[stateCodeAlpha2] ASC
)
INCLUDE([npa]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_countryCodeNormalized]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [idx_countryCodeNormalized] ON [dbo].[numberCountryNPAExtended]
(
	[countryCodeNormalized] ASC
)
INCLUDE([countryCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_partnerCampaign_campaignId]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_partnerCampaign_campaignId] ON [dbo].[partnerCampaign]
(
	[campaignId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_partnerCampaignCode_campaignId]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_partnerCampaignCode_campaignId] ON [dbo].[partnerCampaignCode]
(
	[campaignId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_partnerCampaignLog_campaignId]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_partnerCampaignLog_campaignId] ON [dbo].[partnerCampaignLog]
(
	[campaignId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_route_routeID_routeSequence]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_route_routeID_routeSequence] ON [dbo].[route]
(
	[routeID] ASC,
	[routeSequence] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_route_routeSequence]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_route_routeSequence] ON [dbo].[route]
(
	[routeSequence] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_routeAction_active]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_routeAction_active] ON [dbo].[routeAction]
(
	[active] ASC
)
INCLUDE([routeActionID],[routeID],[routeActionTypeID],[routeActionValue],[routeActionSequence]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_routeAction_routeID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_routeAction_routeID] ON [dbo].[routeAction]
(
	[routeID] ASC
)
INCLUDE([routeActionID],[routeActionGUID],[routeActionTypeID],[routeActionValue],[active]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_accountID_created_countryCode]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [idx_accountID_created_countryCode] ON [dbo].[txnNumber]
(
	[accountID] ASC,
	[created] ASC
)
INCLUDE([destinationNumberCountryCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_accountID_txnNumberGUID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [idx_accountID_txnNumberGUID] ON [dbo].[txnNumber]
(
	[txnNumberGUID] ASC,
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_txnNumber_accountID_created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_txnNumber_accountID_created] ON [dbo].[txnNumber]
(
	[accountID] ASC,
	[created] ASC
)
INCLUDE([destinationNumberCountryCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_txnNumber_txnNumberGUID_accountID]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_txnNumber_txnNumberGUID_accountID] ON [dbo].[txnNumber]
(
	[txnNumberGUID] ASC,
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_txnVoiceOrig_accountID_created]    Script Date: 22/02/2024 00:40:04 ******/
CREATE NONCLUSTERED INDEX [IDX_txnVoiceOrig_accountID_created] ON [dbo].[txnVoiceOrig]
(
	[accountID] ASC,
	[created] ASC
)
INCLUDE([destinationCode],[destinationCodeNPA],[forwardType],[minutes]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_accountGUID]  DEFAULT (newid()) FOR [accountGUID]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[account] ADD  CONSTRAINT [DF_account_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[accountProperty] ADD  CONSTRAINT [DF_accountProperty_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[accountRegistration] ADD  CONSTRAINT [DF_accountRegistration_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[accountRegistration] ADD  CONSTRAINT [DF_accountRegistration_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_accountUserGUID]  DEFAULT (newid()) FOR [accountUserGUID]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_phone1isMobile]  DEFAULT ((0)) FOR [phone1isMobile]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_phone2isMobile]  DEFAULT ((0)) FOR [phone2isMobile]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[accountUser] ADD  CONSTRAINT [DF_accountUser_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[api] ADD  CONSTRAINT [DF_api_apiGUID]  DEFAULT (newid()) FOR [apiGUID]
GO
ALTER TABLE [dbo].[api] ADD  CONSTRAINT [DF_api_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[api] ADD  CONSTRAINT [DF_api_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[apiResource] ADD  CONSTRAINT [DF_apiResource_apiResourceGUID]  DEFAULT (newid()) FOR [apiResourceGUID]
GO
ALTER TABLE [dbo].[apiResource] ADD  CONSTRAINT [DF_apiResource_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[apiResource] ADD  CONSTRAINT [DF_apiResource_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[apiResourceParameter] ADD  CONSTRAINT [DF_apiResourceParameter_apiResourceParameterGUID]  DEFAULT (newid()) FOR [apiResourceParameterGUID]
GO
ALTER TABLE [dbo].[apiResourceParameter] ADD  CONSTRAINT [DF_apiResourceParameter_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[apiResourceParameter] ADD  CONSTRAINT [DF_apiResourceParameter_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[auditTrail] ADD  CONSTRAINT [DF_auditTrail_createDate]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[auditTrail] ADD  CONSTRAINT [DF_auditTrail_updated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[authenticationFailure] ADD  CONSTRAINT [DF_authenticationFailure_authenticationFailureGUID]  DEFAULT (newid()) FOR [authenticationFailureGUID]
GO
ALTER TABLE [dbo].[authenticationFailure] ADD  CONSTRAINT [DF_authenticationFailure_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[authenticationFailure] ADD  CONSTRAINT [DF_authenticationFailure_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[blockCodeNumber] ADD  CONSTRAINT [DF_blockCodeNumber_blockCodeNumberGUID]  DEFAULT (newid()) FOR [blockCodeNumberGUID]
GO
ALTER TABLE [dbo].[blockCodeNumber] ADD  CONSTRAINT [DF_blockCodeNumber_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[blockCodeNumber] ADD  CONSTRAINT [DF_blockCodeNumber_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[cacheConnectionCodeAssign] ADD  CONSTRAINT [DF_cacheConnectionCodeAssign_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_codeGUID]  DEFAULT (newid()) FOR [codeGUID]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_itemCode]  DEFAULT ((0)) FOR [itemCode]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_shared]  DEFAULT ((0)) FOR [shared]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_ton]  DEFAULT ((1)) FOR [ton]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_npi]  DEFAULT ((1)) FOR [npi]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_emailTemplateID]  DEFAULT ((0)) FOR [emailTemplateID]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_voice]  DEFAULT ((0)) FOR [voice]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_surcharge]  DEFAULT ((0)) FOR [surcharge]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_deactivated]  DEFAULT ((0)) FOR [deactivated]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[code] ADD  CONSTRAINT [DF_code_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[codeAudit] ADD  CONSTRAINT [DF_codeAudit_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeOverride] ADD  CONSTRAINT [DF_codeOverride_codeOverrideGUID]  DEFAULT (newid()) FOR [codeOverrideGUID]
GO
ALTER TABLE [dbo].[codeOverride] ADD  CONSTRAINT [DF_codeOverride_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeParameter] ADD  CONSTRAINT [DF_codeParameter_codeParameterGUID]  DEFAULT (newid()) FOR [codeParameterGUID]
GO
ALTER TABLE [dbo].[codeParameter] ADD  CONSTRAINT [DF_codeParameter_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeParameter] ADD  CONSTRAINT [DF_codeParameter_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[codePublishLog] ADD  CONSTRAINT [DF_codePublishLog_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codePublishLog] ADD  CONSTRAINT [DF_codePublishLog_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_codeRegistrationGUID]  DEFAULT (newid()) FOR [codeRegistrationGUID]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_ton]  DEFAULT ((1)) FOR [ton]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_npi]  DEFAULT ((1)) FOR [npi]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeRegistration] ADD  CONSTRAINT [DF_codeRegistration_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[codeRegistryParameterTSS] ADD  CONSTRAINT [DF_codeRegistryParameterTSS_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[codeRegistryParameterTSS] ADD  CONSTRAINT [DF_codeRegistryParameterTSS_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_connectionGUID]  DEFAULT (newid()) FOR [connectionGUID]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_destinationNumberFormat]  DEFAULT ((0)) FOR [destinationNumberFormat]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_enforceOptOut]  DEFAULT ((0)) FOR [enforceOptOut]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_disableInNetworkRouting]  DEFAULT ((0)) FOR [disableInNetworkRouting]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_segmentedMessageOption]  DEFAULT ((2)) FOR [segmentedMessageOption]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_registeredDeliveryDisable]  DEFAULT ((0)) FOR [registeredDeliveryDisable]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_enableInboundSC]  DEFAULT ((0)) FOR [enableInboundSC]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_utf16HttpStrip]  DEFAULT ((0)) FOR [utf16HttpStrip]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_spamFilterMO]  DEFAULT ((0)) FOR [spamFilterMO]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_spamFilterMT]  DEFAULT ((0)) FOR [spamFilterMT]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_spamOfflineMO]  DEFAULT ((0)) FOR [spamOfflineMO]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_spamOfflineMT]  DEFAULT ((0)) FOR [spamOfflineMT]
GO
ALTER TABLE [dbo].[connection] ADD  CONSTRAINT [DF_connection_moHttpTlvs]  DEFAULT ((0)) FOR [moHttpTlvs]
GO
ALTER TABLE [dbo].[connectionAuthorization] ADD  CONSTRAINT [DF_connectionAuthorization_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[connectionAuthorization] ADD  CONSTRAINT [DF_connectionAuthorization_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[connectionCodeAssign] ADD  CONSTRAINT [DF_connectionCodeAssign_default]  DEFAULT ((0)) FOR [default]
GO
ALTER TABLE [dbo].[connectionCodeAssign] ADD  CONSTRAINT [DF_connectionCodeAssign_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[connectionCodeAssign] ADD  CONSTRAINT [DF_connectionCodeAssign_created2]  DEFAULT (getutcdate()) FOR [created2]
GO
ALTER TABLE [dbo].[connectionCodeAssign] ADD  CONSTRAINT [DF_connectionCodeAssign_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[connectionCodeAssignHistory] ADD  CONSTRAINT [DF_connectionCodeAssignHistory_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[connectionCodeAssignHistory] ADD  CONSTRAINT [DF_connectionCodeAssignHistory_created2]  DEFAULT (getutcdate()) FOR [created2]
GO
ALTER TABLE [dbo].[connectionRole] ADD  CONSTRAINT [DF_connectionRole_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[connectionRole] ADD  CONSTRAINT [DF_connectionRole_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[credential] ADD  CONSTRAINT [DF_credential_credentialGUID]  DEFAULT (newid()) FOR [credentialGUID]
GO
ALTER TABLE [dbo].[credential] ADD  CONSTRAINT [DF_credential_firewallRequired]  DEFAULT ((1)) FOR [firewallRequired]
GO
ALTER TABLE [dbo].[credential] ADD  CONSTRAINT [DF_credential_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[credential] ADD  CONSTRAINT [DF_credential_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[firewall] ADD  CONSTRAINT [DF_firewall_firewallGUID]  DEFAULT (newid()) FOR [firewallGUID]
GO
ALTER TABLE [dbo].[firewall] ADD  CONSTRAINT [DF_firewall_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[firewall] ADD  CONSTRAINT [DF_firewall_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[httpCapture] ADD  CONSTRAINT [DF_httpCapture_httpCaptureGUID]  DEFAULT (newid()) FOR [httpCaptureGUID]
GO
ALTER TABLE [dbo].[httpCapture] ADD  CONSTRAINT [DF_httpCapture_completed]  DEFAULT (getutcdate()) FOR [completed]
GO
ALTER TABLE [dbo].[httpCapture] ADD  CONSTRAINT [DF_httpCapture_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[item] ADD  CONSTRAINT [DF_item_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[item] ADD  CONSTRAINT [DF_item_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[keyword] ADD  CONSTRAINT [DF_keyword_keywordGUID]  DEFAULT (newid()) FOR [keywordGUID]
GO
ALTER TABLE [dbo].[keyword] ADD  CONSTRAINT [DF_keyword_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[keyword] ADD  CONSTRAINT [DF_keyword_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[maintenanceSchedule] ADD  CONSTRAINT [DF_maintenanceSchedule_maintenanceScheduleGUID]  DEFAULT (newid()) FOR [maintenanceScheduleGUID]
GO
ALTER TABLE [dbo].[maintenanceSchedule] ADD  CONSTRAINT [DF_maintenanceSchedule_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[maintenanceSchedule] ADD  CONSTRAINT [DF_maintenanceSchedule_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[message] ADD  CONSTRAINT [DF_message_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[message] ADD  CONSTRAINT [DF_message_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[messageResult] ADD  CONSTRAINT [DF_messageResult_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[messageResult] ADD  CONSTRAINT [DF_messageResult_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[notificationSubscription] ADD  CONSTRAINT [DF_notificationSubscription_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[notificationSubscription] ADD  CONSTRAINT [DF_notificationSubscription_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[number] ADD  CONSTRAINT [DF_number_numberGUID]  DEFAULT (newid()) FOR [numberGUID]
GO
ALTER TABLE [dbo].[number] ADD  CONSTRAINT [DF_number_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[number] ADD  CONSTRAINT [DF_number_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[numberCountryNPAOverride] ADD  CONSTRAINT [DF_numberCountryNPAOverride_numberCountryNPAOverrideGUID]  DEFAULT (newid()) FOR [numberCountryNPAOverrideGUID]
GO
ALTER TABLE [dbo].[numberCountryNPAOverride] ADD  CONSTRAINT [DF_numberCountryNPAOverride_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[numberCountryNPAOverride] ADD  CONSTRAINT [DF_numberCountryNPAOverride_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[numberOperator] ADD  CONSTRAINT [DF_numberOperator_numberOperatorGUID]  DEFAULT (newid()) FOR [numberOperatorGUID]
GO
ALTER TABLE [dbo].[numberOperator] ADD  CONSTRAINT [DF_numberOperator_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[numberOperator] ADD  CONSTRAINT [DF_numberOperator_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[numberOperatorNetNumber] ADD  CONSTRAINT [DF_numberOperatorNetNumber_numberOperatorGUID]  DEFAULT (newid()) FOR [numberOperatorGUID]
GO
ALTER TABLE [dbo].[numberOperatorNetNumber] ADD  CONSTRAINT [DF_numberOperatorNetNumber_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[numberOperatorNetNumber] ADD  CONSTRAINT [DF_numberOperatorNetNumber_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[numberOperatorSyniverse] ADD  CONSTRAINT [DF_numberOperatorSyniverse_numberOperatorGUID]  DEFAULT (newid()) FOR [numberOperatorGUID]
GO
ALTER TABLE [dbo].[numberOperatorSyniverse] ADD  CONSTRAINT [DF_numberOperatorSyniverse_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[numberOperatorSyniverse] ADD  CONSTRAINT [DF_numberOperatorSyniverse_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[partnerCampaign] ADD  CONSTRAINT [DF_partnerCampaign_published]  DEFAULT ((0)) FOR [published]
GO
ALTER TABLE [dbo].[partnerCampaign] ADD  CONSTRAINT [DF_partnerCampaign_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[partnerCampaign] ADD  CONSTRAINT [DF_partnerCampaign_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[partnerCampaign] ADD  CONSTRAINT [DF_partnerCampaign_readyToPublish]  DEFAULT ((0)) FOR [readyToPublish]
GO
ALTER TABLE [dbo].[partnerCampaignCode] ADD  CONSTRAINT [DF_partnerCampaignCode_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[partnerCampaignCode] ADD  CONSTRAINT [DF_partnerCampaignCode_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[partnerCampaignLog] ADD  CONSTRAINT [DF_partnerCampaignLog_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[partnerCampaignLog] ADD  CONSTRAINT [DF_partnerCampaignLog_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [DF_provider_providerGUID]  DEFAULT (newid()) FOR [providerGUID]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [DF_provider_active]  DEFAULT ((0)) FOR [active]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [DF_provider_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [DF_provider_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[route] ADD  CONSTRAINT [DF_route_routeGUID]  DEFAULT (newid()) FOR [routeGUID]
GO
ALTER TABLE [dbo].[route] ADD  CONSTRAINT [DF_route_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[route] ADD  CONSTRAINT [DF_route_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_routeActionGUID]  DEFAULT (newid()) FOR [routeActionGUID]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_routeActionValue]  DEFAULT ((0)) FOR [routeActionValue]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[routeAction] ADD  CONSTRAINT [DF_routeAction_routeActionSequence]  DEFAULT ((1)) FOR [routeActionSequence]
GO
ALTER TABLE [dbo].[routeActionType] ADD  CONSTRAINT [DF_routeActionType_routeActionTypeGUID]  DEFAULT (newid()) FOR [routeActionTypeGUID]
GO
ALTER TABLE [dbo].[routeActionType] ADD  CONSTRAINT [DF_routeActionType_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[routeActionType] ADD  CONSTRAINT [DF_routeActionType_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[routeConnection] ADD  CONSTRAINT [DF_routeConnection_routeConnectionGUID]  DEFAULT (newid()) FOR [routeConnectionGUID]
GO
ALTER TABLE [dbo].[routeConnection] ADD  CONSTRAINT [DF_routeConnection_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[routeConnection] ADD  CONSTRAINT [DF_routeConnection_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[routeConnection] ADD  CONSTRAINT [DF_routeConnection_active]  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[tbl_SchemaLog] ADD  CONSTRAINT [DF_tbl_SchemaChangeHistory_logDate]  DEFAULT (getutcdate()) FOR [LogDate]
GO
ALTER TABLE [dbo].[txnNumber] ADD  CONSTRAINT [DF_txnNumber_txnNumberGUID]  DEFAULT (newid()) FOR [txnNumberGUID]
GO
ALTER TABLE [dbo].[txnNumber] ADD  CONSTRAINT [DF_txnNumber_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[txnNumber] ADD  CONSTRAINT [DF_txnNumber_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[txnVoiceOrig] ADD  CONSTRAINT [DF_txnVoiceOrig_txnVoiceGUID]  DEFAULT (newid()) FOR [txnVoiceGUID]
GO
ALTER TABLE [dbo].[txnVoiceOrig] ADD  CONSTRAINT [DF_txnVoiceOrig_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[txnVoiceOrig] ADD  CONSTRAINT [DF_txnVoiceOrig_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[txnVoiceTerm] ADD  CONSTRAINT [DF_txnVoiceTerm_txnVoiceGUID]  DEFAULT (newid()) FOR [txnVoiceGUID]
GO
ALTER TABLE [dbo].[txnVoiceTerm] ADD  CONSTRAINT [DF_txnVoiceTerm_created]  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[txnVoiceTerm] ADD  CONSTRAINT [DF_txnVoiceTerm_lastUpdated]  DEFAULT (getutcdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[message]  WITH CHECK ADD  CONSTRAINT [JSON_message_messageMetadata] CHECK  ((isjson([messageMetadata])=(1)))
GO
ALTER TABLE [dbo].[message] CHECK CONSTRAINT [JSON_message_messageMetadata]
GO
ALTER TABLE [dbo].[messageResult]  WITH CHECK ADD  CONSTRAINT [JSON_message_messageResultMetadata] CHECK  ((isjson([messageResultMetadata])=(1)))
GO
ALTER TABLE [dbo].[messageResult] CHECK CONSTRAINT [JSON_message_messageResultMetadata]
GO
/****** Object:  StoredProcedure [dbo].[accountDeleteByAccountID]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[accountDeleteByAccountID]
	@accountID INT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	DECLARE @count INT; 

	BEGIN TRANSACTION

		SET @count = (SELECT COUNT(blockCodeNumberID) FROM blockCodeNumber WHERE code IN ( SELECT code FROM code WHERE codeID IN ( SELECT codeID FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)))));
		PRINT 'blockCodeNumber:' + CAST(@count AS VARCHAR(10));
		DELETE FROM blockCodeNumber WHERE code IN ( SELECT code FROM code WHERE codeID IN ( SELECT codeID FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID))));

		SET @count = (SELECT COUNT (cacheConnectionCodeAssignID) FROM cacheConnectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'cacheConnectionCodeAssign:' + CAST(@count AS VARCHAR(10));
		DELETE FROM cacheConnectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (codeRegistrationID) FROM codeRegistration WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'codeRegistration:' + CAST(@count AS VARCHAR(10));
		DELETE FROM codeRegistration WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (credentialID) FROM credential WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'credential:' + CAST(@count AS VARCHAR(10));
		DELETE FROM credential WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (firewallID) FROM firewall WHERE accountID IN (@accountID));
		PRINT 'firewall:' + CAST(@count AS VARCHAR(10));
		DELETE FROM firewall WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (keywordID) FROM keyword WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'keyword:' + CAST(@count AS VARCHAR(10));
		DELETE FROM keyword WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT(routeActionID) FROM routeAction WHERE routeID IN (SELECT routeID FROM route WHERE accountID IN (@accountID)));
		PRINT 'routeAction:' + CAST(@count AS VARCHAR(10));
		DELETE FROM routeAction WHERE routeID IN (SELECT routeID FROM route WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (routeConnectionID) FROM routeConnection WHERE accountID IN (@accountID));
		PRINT 'routeConnection:' + CAST(@count AS VARCHAR(10));
		DELETE FROM routeConnection WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (connectionID) FROM xTempBulkAction WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'xTempBulkAction:' + CAST(@count AS VARCHAR(10));
		DELETE FROM xTempBulkAction WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));


		SET @count = (SELECT COUNT (routeID) FROM route WHERE accountID IN (@accountID));
		PRINT 'route:' + CAST(@count AS VARCHAR(10));
		DELETE FROM route WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (connectionID) FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID)));
		PRINT 'connectionCodeAssign:' + CAST(@count AS VARCHAR(10));
		DELETE FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (@accountID));

		SET @count = (SELECT COUNT (connectionID) FROM connection WHERE accountID IN (@accountID));
		PRINT 'connection:' + CAST(@count AS VARCHAR(10));
		DELETE FROM connection WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (accountUserID) FROM accountUser WHERE accountID IN (@accountID));
		PRINT 'accountUser:' + CAST(@count AS VARCHAR(10));
		DELETE FROM accountUser WHERE accountID IN (@accountID);

		SET @count = (SELECT COUNT (@accountID) FROM account WHERE accountID IN (@accountID));
		PRINT 'account:' + CAST(@count AS VARCHAR(10));
		DELETE FROM account WHERE accountID IN (@accountID);

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[accountDisableByAccountID]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[accountDisableByAccountID]
	@accountID INT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	BEGIN TRANSACTION

    	UPDATE account SET active = 0 WHERE accountID = @accountID;

		UPDATE connection SET active = 0 WHERE accountID = @accountID;

		UPDATE credential SET active = 0 WHERE connectionID IN (select connectionID FROM connection WHERE accountID = @accountID);

		UPDATE routeAction SET active = 0 WHERE routeID IN (select routeID FROM route WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID = @accountID));
	
		SELECT 'Account, Connections, Credentials, and Route Actions have been Disabled';

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[accountEnableByAccountID]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[accountEnableByAccountID]
	@accountID INT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	BEGIN TRANSACTION

    UPDATE account SET active = 1 WHERE accountID = @accountID;

	UPDATE connection SET active = 1 WHERE accountID = @accountID;

	UPDATE credential SET active = 1 WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID = @accountID);

	UPDATE routeAction SET active = 1 WHERE routeID IN (SELECT routeID FROM route WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID = @accountID));
	
	SELECT 'Account, Connections, Credentials, and Route Actions have been ENABLED' ;

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[approveAccountRegistration]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[approveAccountRegistration]
	@accountRegistrationID INT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	BEGIN TRANSACTION

		--update verified in case they did not verify
		UPDATE accountRegistration SET verified = getUTCDate() WHERE accountRegistrationID = @accountRegistrationID AND verified IS NULL;
    	UPDATE accountRegistration SET approved = getUTCDate() WHERE accountRegistrationID = @accountRegistrationID;

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[checkCode]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[checkCode]
	@code varchar(15)
WITH EXECUTE AS 'dbo' 
AS
BEGIN


	SET NOCOUNT ON;

	SELECT
	  a.created,
	  b.created AS [assigned],
	  b.accountID,
	  b.accountName,
	  b.connectionID,
	  b.connectionName,
	  a.code,
	  a.codeTypeID,
	  a.codeRegistrationID,
	  a.voice,
	  a.surcharge,
	  a.espid,
	  a.providerID,
	  p.name AS [providerName],
	  a.publishStatus,
	  a.publishUpdate,
	  a.active,
	  a.deactivated,
	  a.available,
	  a.name,
	  a.emailAddress,
	  a.emailDomain,
	  a.voiceForwardTypeID,
	  a.voiceForwardDestination,
	  a.replyHelp,
	  a.replyStop,
	  a.notePrivate
	FROM code a WITH (NOLOCK) LEFT JOIN (
	  SELECT 
		ac.name AS [accountName],
		f.accountID,
		codeID,
		e.connectionID,
		f.connectionGUID,
		f.name AS connectionName,
		e.created,
		ac.active
	  FROM connectionCodeAssign e WITH (NOLOCK), connection f WITH (NOLOCK), account ac WITH (NOLOCK)
	  WHERE e.connectionID = f.connectionID
	  AND	f.accountID = ac.accountID
	) b ON a.codeID = b.codeID
	LEFT JOIN provider p WITH (NOLOCK) 
		ON a.providerID = p.providerID
	WHERE a.code = @code


END
GO
/****** Object:  StoredProcedure [dbo].[checkOperatorID]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[checkOperatorID]
	@operatorID	INT
AS	 
BEGIN 
	
	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	SELECT	numberOperatorID AS operatorID, 
			operatorName,
			CASE WHEN numberOperatorID IN (
					SELECT	numberOperatorID
					FROM	numberOperator WITH (NOLOCK)
					WHERE	operatorName LIKE '%wireless%'
					AND	NOT	operatorName LIKE '%aerialink%'
				 ) THEN 'wireless'
				 WHEN numberOperatorID IN (
					SELECT	numberOperatorID
					FROM	numberOperator WITH (NOLOCK)
					WHERE	((operatorName LIKE '%VONAGE%')
					OR		(operatorName LIKE '%SKPE%')
					OR		(operatorName LIKE '%GOOGLE%')
					OR		(operatorName LIKE '%RINGCENTRAL%')
					OR		(operatorName LIKE '%TWILIO%')
					OR		(operatorName LIKE '%BANDWIDTH%'))
					AND NOT operatorName LIKE '%wireless%'
				 ) THEN 'exception'
				 ELSE 'OK' END AS [type]
	FROM	numberOperator WITH (NOLOCK)
	WHERE	numberOperatorID = @operatorID


END 








GO
/****** Object:  StoredProcedure [dbo].[createNewConnection]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[createNewConnection] 
	-- Add the parameters for the stored procedure here
	@connectionName varchar(150),
	@accountID INT

AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	declare @connectionID INT;
	declare @connectionGroupID INT;
	declare @routeID INT;

	BEGIN TRANSACTION

	--#STEP 1: INSERT connection : we will always create one default connection for them
	INSERT connection (accountID,name,codeDistributionMethodID,
		enforceOptOut,messageExpirationHours,
		active,created,lastUpdated)
	VALUES (@accountID,@connectionName,0,
		
		0,24,
		1,getUTCDate(),getUTCDate());
	
	--#get newly created connectionID
	SET @connectionID = SCOPE_IDENTITY();

	--#STEP 2: insert connectionGroup : we will always create one default connectionGroup for them
	insert connectionGroup (accountID, name, created, lastUpdated)
	values (@accountID, @connectionName, getUTCDate(), getUTCDate())

	--#get newly created connectionID
	set @connectionGroupID = SCOPE_IDENTITY()

	--#STEP 3: insert connectionGroupAssign : we will always create one default record tying the connection and connectionGroup together
	insert connectionGroupAssign (connectionGroupID, connectionID)
	values (@connectionGroupID,@connectionID)
	
	--#STEP 4: INSERT route : create default route
	INSERT route (accountID,connectionID,acceptDeny,sourceCodeCompare,destinationCodeCompare,messageDataCompare,numberOperatorID,
				validityDateStart,validityDateEnd,validityTimeStart,validityTimeEnd,routeSequence,
				created,lastUpdated)
	VALUES (@accountID, @connectionID, 1, 0, 0, 0, 0, 
				'1900-01-01 00:00:00', '2900-01-01 00:00:00', '00:00:00', '23:59:59', 1,
				getUTCDate(), getUTCDate());
	
	--#get newly created routeID
	SET @routeID = SCOPE_IDENTITY();
	
	--#STEP 5: Provide access to SMS MT, reports and query/publish leased codes.
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 1, 0, 1, getUTCDate(), getUTCDate());
	
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 10, 0, 1, getUTCDate(), getUTCDate());
	
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 17, 0, 1, getUTCDate(), getUTCDate());
	
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 18, 0, 1, getUTCDate(), getUTCDate());
	
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	VALUES (@routeID, 19, 0, 1, getUTCDate(), getUTCDate());
	
	SELECT 'createNewConnection Completed', @connectionID;

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[deProvisionConnectionCodeAssign]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[deProvisionConnectionCodeAssign]
	@code varchar(15), 
	@connectionID INT 
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	declare @@codeID int;
	declare @@shared int;

	BEGIN TRANSACTION

		SET @@codeID = (SELECT TOP 1 c.codeID FROM code c, connectionCodeAssign cca WHERE c.code = @code AND c.codeID = cca.codeID AND cca.connectionID = @connectionID);
		SET @@shared = (SELECT c.shared FROM code c WHERE c.codeID = @@codeID);

		PRINT @@codeID

		IF @@codeID > 0
			BEGIN
				DELETE connectionCodeAssign WHERE connectionID = @connectionID AND codeID = @@codeID;
				UPDATE code SET active=@@shared, deactivated=0, available=0 WHERE codeID = @@codeID;
				INSERT connectionCodeAssignHistory (connectionID, codeID, action, created) VALUES (@connectionID, @@codeID, 0, getutcdate());
				INSERT cacheConnectionCodeAssign (code, connectionID, cacheStatus) VALUES (@code, @connectionID, 0);
				--we are not making the code available yet as were not sure how to handle 50's which are not our numbers yet
				--i.e cannot make an LOA code available following deact as it is not ours
				SELECT 'true' AS result; --code was deleted FROM connectionCodeAssign, but NOT the code table.
			END
		ELSE
			SELECT 'false' AS result; --nothing was done, no code match

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END












GO
/****** Object:  StoredProcedure [dbo].[disableMMS]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[disableMMS]
	@code varchar(15), 
	@connectionID INT
WITH EXECUTE AS 'dbo' 
AS
BEGIN

	DECLARE @codeID INT;
	DECLARE @currentESPID VARCHAR(10);
	DECLARE @itemCode INT;
	DECLARE @inConnection INT = 0;
	DECLARE @errorMessage VARCHAR(255);

	SET NOCOUNT ON;

	BEGIN TRY

		SET @codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @currentESPID = (SELECT espid FROM code WHERE codeID = @codeID);
		SET @itemCode = (SELECT itemCode FROM code WHERE codeID = @codeID);
		SET @inConnection = (SELECT COUNT(*) FROM connectionCodeAssign WHERE codeID = @codeID AND connectionID = @connectionID);

		IF (@inConnection > 0) AND (@itemCode = 101)
		BEGIN
			IF (@currentESPID IN ('E136'))
			BEGIN
				--UPDATE code SET mms=0, espid='E0B4', publishUpdate=2 WHERE codeID = @codeID;
				UPDATE code SET espid='E0B4', publishUpdate=2 WHERE codeID = @codeID;
				SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
			END
			ELSE IF (@currentESPID IN ('E19B'))
			BEGIN
				--UPDATE code SET mms=0 WHERE codeID = @codeID;
				SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
			END
			ELSE
				SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END
		ELSE
		BEGIN
			SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END

	END TRY
	BEGIN CATCH

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed', @code, @connectionID;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[dlrLookup]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dlrLookup]
	@dlrTransactionGUID VARCHAR(40) = ''
AS	 
BEGIN 
	SET NOCOUNT ON 

	SELECT	mt.transactionGUID AS [mtTransactionGUID],
			dlr.txnSMSDeliverGUID AS [dlrTransactionGUID],
			CASE WHEN CONVERT(INT, SUBSTRING(mt.messageData,1,1)) = 5 THEN CONVERT(INT, SUBSTRING(mt.messageData,5,1)) ELSE NULL END AS [totalSegments],
			CASE WHEN CONVERT(INT, SUBSTRING(mt.messageData,1,1)) = 5 THEN CONVERT(INT, SUBSTRING(mt.messageData,6,1)) ELSE NULL END AS [segmentNumber],
			CASE 
				WHEN dlr.messageText IS NULL THEN 'NO DLR' 
				WHEN LTRIM(RTRIM(dlr.messageText))  = '' THEN 'EMPTY'
				WHEN (PATINDEX('%err:%',dlr.messageText))-(PATINDEX('%stat:%',dlr.messageText)+5) < 1 THEN 'INVALID'
				WHEN LEFT(dlr.messageText,3) = 'id:' THEN SUBSTRING(dlr.messageText, PATINDEX('%stat:%',dlr.messageText)+5, (PATINDEX('%err:%',dlr.messageText))-(PATINDEX('%stat:%',dlr.messageText)+5)) 
				ELSE 'INVALID'
			END AS [dlrStatus],
			CASE 
				WHEN dlr.messageText IS NULL THEN 'NO ERR' 
				WHEN LTRIM(RTRIM(dlr.messageText)) = '' THEN 'EMPTY'
				WHEN (PATINDEX('%text:%',dlr.messageText))-(PATINDEX('%err:%',dlr.messageText)+4) < 1 THEN 'INVALID'
				WHEN LEFT(dlr.messageText,3) = 'id:' THEN SUBSTRING(dlr.messageText, PATINDEX('%err:%',dlr.messageText)+4, (PATINDEX('%text:%',dlr.messageText))-(PATINDEX('%err:%',dlr.messageText)+4)) 
				ELSE 'INVALID'	
			END AS [dlrResultCode]
	FROM	SMSMTsubmit mt WITH (NOLOCK)
	INNER	JOIN (
		SELECT	TOP 1	mts.segmentGroupGUID,
						rss.auditResult AS [created]
		FROM	SMSMTsubmit mts WITH (NOLOCK),
				SMSMTresult rss WITH (NOLOCK)
		WHERE	rss.providerTransactionID = @dlrTransactionGUID
		AND		mts.transactionGUID = rss.transactionGUID
	) seg ON mt.segmentGroupGUID = seg.segmentGroupGUID
	LEFT OUTER JOIN SMSMTresult rs WITH (NOLOCK) ON (mt.transactionGUID = rs.transactionGUID AND rs.result = 2)
	LEFT OUTER JOIN txnSMSDeliver dlr WITH (NOLOCK) ON dlr.txnSMSDeliverGUID = rs.providerTransactionID
	ORDER	BY [segmentNumber]

END 






GO
/****** Object:  StoredProcedure [dbo].[dlrLookup_new]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[dlrLookup_new]
	@dlrTransactionGUID VARCHAR(40) = ''
AS	 
BEGIN 
	SET NOCOUNT ON 

	SELECT	mt.transactionGUID AS [mtTransactionGUID],
			dlr.transactionGUID AS [dlrTransactionGUID],
			[totalSegments] = (SELECT COUNT(*) FROM SMSMTsubmit (NOLOCK) WHERE segmentGroupGUID = mt.segmentGroupGUID),
			ROW_NUMBER() OVER(ORDER BY auditSubmit ASC) [segmentNumber],
			CASE 
				WHEN dlr.messageText IS NULL THEN 'NO DLR' 
				WHEN LTRIM(RTRIM(dlr.messageText))  = '' THEN 'EMPTY'
				WHEN (PATINDEX('%err:%',dlr.messageText))-(PATINDEX('%stat:%',dlr.messageText)+5) < 1 THEN 'INVALID'
				WHEN LEFT(dlr.messageText,3) = 'id:' THEN SUBSTRING(dlr.messageText, PATINDEX('%stat:%',dlr.messageText)+5, (PATINDEX('%err:%',dlr.messageText))-(PATINDEX('%stat:%',dlr.messageText)+5)) 
				ELSE 'INVALID'
			END AS [dlrStatus],
			CASE 
				WHEN dlr.messageText IS NULL THEN 'NO ERR' 
				WHEN LTRIM(RTRIM(dlr.messageText)) = '' THEN 'EMPTY'
				WHEN (PATINDEX('%text:%',dlr.messageText))-(PATINDEX('%err:%',dlr.messageText)+4) < 1 THEN 'INVALID'
				WHEN LEFT(dlr.messageText,3) = 'id:' THEN SUBSTRING(dlr.messageText, PATINDEX('%err:%',dlr.messageText)+4, (PATINDEX('%text:%',dlr.messageText))-(PATINDEX('%err:%',dlr.messageText)+4)) 
				ELSE 'INVALID'	
			END AS [dlrResultCode]
	FROM	SMSMTsubmit mt WITH (NOLOCK)
	LEFT OUTER JOIN SMSMTresult rs WITH (NOLOCK) ON (mt.transactionGUID = rs.transactionGUID AND rs.result = 2)
	LEFT OUTER JOIN SMSDeliver dlr WITH (NOLOCK) ON dlr.transactionGUID = rs.providerTransactionID
	WHERE	mt.segmentGroupGUID IN (
		SELECT	TOP 1	mts.segmentGroupGUID
		FROM	SMSMTsubmit mts WITH (NOLOCK),
				SMSMTresult rss WITH (NOLOCK)
		WHERE	rss.providerTransactionID = @dlrTransactionGUID
		AND		mts.transactionGUID = rss.transactionGUID
	) 
	ORDER	BY [segmentNumber]



END 





GO
/****** Object:  StoredProcedure [dbo].[enableMMS]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[enableMMS]
	@code varchar(15), 
	@connectionID INT
WITH EXECUTE AS 'dbo' 
AS
BEGIN

	DECLARE @codeID INT;
	DECLARE @currentESPID VARCHAR(10);
	DECLARE @itemCode INT;
	DECLARE @inConnection INT = 0;
	DECLARE @mmsConnection INT = 0;
	DECLARE @errorMessage VARCHAR(255);

	SET NOCOUNT ON;

	BEGIN TRY

		SET @codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @currentESPID = (SELECT espid FROM code WHERE codeID = @codeID);
		SET @itemCode = (SELECT itemCode FROM code WHERE codeID = @codeID);
		SET @inConnection = (SELECT COUNT(*) FROM connectionCodeAssign WHERE codeID = @codeID AND connectionID = @connectionID);
		SET @mmsConnection = (SELECT COUNT(*) FROM routeAction WHERE routeActionTypeID = 10 AND routeID IN (SELECT routeID FROM [route] WHERE connectionID = @connectionID));

		PRINT 'In Connection: ' + CAST(@inConnection AS VARCHAR(5));
		PRINT 'Item Code: ' + CAST(@itemCode AS VARCHAR(5));
		PRINT 'Connection has MMS route: ' + CAST(@mmsConnection AS VARCHAR(5));

		IF (@inConnection > 0) AND (@itemCode = 101) AND (@mmsConnection > 0)
		BEGIN
			IF (@currentESPID IN ('E0B4','E0B5','E136'))
			BEGIN
				--UPDATE code SET mms=1, espid='E136', publishUpdate=2 WHERE codeID = @codeID;
				UPDATE code SET  espid='E136', publishUpdate=2 WHERE codeID = @codeID;
				SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
			END
			ELSE IF (@currentESPID IN ('E19B'))
			BEGIN
				--UPDATE code SET mms=1 WHERE codeID = @codeID;
				SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
			END
			ELSE
				SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END
		ELSE
		BEGIN
			SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END

	END TRY
	BEGIN CATCH

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[getAccountLatency]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getAccountLatency]
	@accountID INT = 1
AS	 
BEGIN 

	SET NOCOUNT ON 

	SELECT AVG(DATEDIFF(millisecond,[start],[complete])) AS latencyMS
	FROM (
		SELECT	mt.auditSubmit [start],
				[complete] = (
					SELECT	TOP 1 auditResult
					FROM	smsMTResult AS mtr with (nolock)
					WHERE	RESULT = 1
					AND		transactionGUID = mt.transactionGUID
				)
		FROM	SMSMTsubmit mt (NOLOCK)
		WHERE	mt.auditSubmit >= DATEADD(minute, -5, GETUTCDATE())
		AND		mt.accountID = @accountID
	) a


END 







GO
/****** Object:  StoredProcedure [dbo].[getAccountMDR]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getAccountMDR]
	@type		VARCHAR(3),
	@accountID	INT,
	@includeConnection INT = 0
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	DECLARE @activityStart	AS DATETIME;
	DECLARE @activityEnd	AS DATETIME;

	SET @activityStart	= (SELECT DATEADD(HOUR, -2, DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()), 0)));
	SET @activityEnd	= (SELECT DATEADD(HOUR, -1, DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()), 0)));

	IF @includeConnection = 0
	BEGIN

		IF @type = 'DLR'
		BEGIN

		  --DLR / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSDeliverGUID AS [MessageGUID],
			'DLR' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			LEFT(a.[messageText],106) AS [StatusMsg]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b  WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND(esmClass = 4 OR esmClass = 8)
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID;

		END
		ELSE IF @type = 'MO'
		BEGIN

		  --MO / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSDeliverGUID AS [MessageGUID],
			'MO' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			[Processed],
			[Completed]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK)
		  WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND esmClass != 4
				AND esmClass != 8
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID;

		END
		ELSE
		BEGIN

		  --MT / Outbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSSubmitGUID AS [MessageGUID],
			'MT' AS [Type],
			sourceCode AS [Source],
			destinationNumber AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			[Processed],
			[Completed],
			[SegmentGroupGUID],
			[SegmentTotal] =
			  CASE
				WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
			  ELSE NULL END,
			[SegmentNumber] =
			  CASE
				WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
			  ELSE NULL END,
  			a.[providerTransactionID] AS [TransactionID]
		  FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID

		END
	END
	ELSE
	BEGIN

		IF @type = 'DLR'
		BEGIN

		  --DLR / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			txnSMSDeliverGUID AS [MessageGUID],
			'DLR' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			LEFT(a.[messageText],106) AS [StatusMsg]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b  WITH (NOLOCK), connection c WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND(esmClass = 4 OR esmClass = 8)
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID;

		END
		ELSE IF @type = 'MO'
		BEGIN

			--MO / INBOUND
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnMMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				0 AS [Dcs],
				0 AS [EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				'MMS' AS [MsgType]
			FROM	txnMMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			UNION
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnSMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				[Dcs],
				[EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				'SMS' AS [MsgType]
			FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND esmClass != 4
				AND esmClass != 8
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			ORDER BY [Created]

		END
		ELSE
		BEGIN

			--MT / Outbound
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnMMSSubmitGUID AS [MessageGUID],
				'MT' AS [Type],
				sourceCode AS [Source],
				destinationNumber AS [Destination],
				0 AS [Dcs],
				0 AS [EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				NULL AS [SegmentGroupGUID],
				0 AS [SegmentTotal],
				0 AS [SegmentNumber],
				a.[providerTransactionID] AS [TransactionID],
				'MMS' AS [MsgType]
			FROM	txnMMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			UNION
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnSMSSubmitGUID AS [MessageGUID],
				'MT' AS [Type],
				sourceCode AS [Source],
				destinationNumber AS [Destination],
				[Dcs],
				[EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				[SegmentGroupGUID],
				[SegmentTotal] =
				CASE
					WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
				ELSE NULL END,
				[SegmentNumber] =
				CASE
					WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
				ELSE NULL END,
				a.[providerTransactionID] AS [TransactionID],
				'SMS' AS [MsgType]
			FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			ORDER BY [created]

		END

	END

END 










GO
/****** Object:  StoredProcedure [dbo].[getAccountMDRbyRange]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getAccountMDRbyRange]
	@type				VARCHAR(3),
	@accountID			INT,
	@activityStart		DATETIME,
	@activityEnd		DATETIME,
	@includeConnection	INT = 0,
	@includeContent		INT = 1
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	IF @type = 'DLR'
	BEGIN
		PRINT 'Get DLR data'
		--DLR / Inbound

		SELECT	
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				a.txnSMSDeliverGUID AS [MessageGUID],
				mt.txnSMSSubmitGUID AS [SourceMessageGUID],
				'DLR' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				CAST(a.[Dcs] AS VARCHAR(10)) AS [Dcs],
				CAST(a.[EsmClass] AS VARCHAR(10)) AS [EsmClass],
				a.[Created],
				a.[Processed],
				a.[Completed],
				CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE dbo.parseMessageData(a.[messageData]) END AS [MessageText]
		FROM	account b WITH (NOLOCK), connection c WITH (NOLOCK), txnSMSDeliver a WITH (NOLOCK)
		LEFT	OUTER JOIN txnSMSSubmit mt WITH (NOLOCK) ON  a.txnSMSDeliverID = mt.txnSMSDeliverID
		WHERE	a.created >= @activityStart AND a.created < @activityEnd
		AND		b.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
		AND		a.esmClass IN (4,8)
		AND		a.accountID = b.accountID
		AND		a.connectionID = c.connectionID

	END
	ELSE IF @type = 'MO'
	BEGIN
		PRINT 'Get MO data'
		--MO / INBOUND
		SELECT	
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				a.txnSMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				a.sourceNumber AS [Source],
				a.destinationCode AS [Destination],
				CAST(a.[Dcs] AS VARCHAR(10)) AS [Dcs],
				CAST(a.[EsmClass] AS VARCHAR(10)) AS [EsmClass],
				a.[Created],
				a.[Processed],
				a.[Completed],
				CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE dbo.parseMessageData(a.[messageData]) END AS [MessageText],
				'SMS' AS [MsgType]
		FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
		WHERE	a.created >= @activityStart AND a.created < @activityEnd
		AND		b.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
		AND		esmClass NOT IN (4,8)
		AND		a.accountID = b.accountID
		AND		a.connectionID = c.connectionID
		UNION ALL
		SELECT	
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				a.txnMMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				a.sourceNumber AS [Source],
				a.destinationCode AS [Destination],
				'N/A' AS [Dcs],
				'N/A' AS [EsmClass],
				a.[Created],
				a.[Processed],
				a.[Completed],
				CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE a.[MessageText] END AS [MessageText],
				'MMS' AS [MsgType]
		FROM	txnMMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
		WHERE	a.created >= @activityStart AND a.created < @activityEnd
		AND		b.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
		AND		dlr=0
		AND		a.accountID = b.accountID
		AND		a.connectionID = c.connectionID
		ORDER BY [Created]

	END
	ELSE
	BEGIN
		PRINT 'Get MT Data'
		--MT / Outbound
		SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			a.txnMMSSubmitGUID AS [MessageGUID],
			'MT' AS [Type],
			a.sourceCode AS [Source],
			a.destinationNumber AS [Destination],
			'N/A' AS [Dcs],
			'N/A' AS [EsmClass],
			a.[Created],
			a.[Processed],
			a.[Completed],
			CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE a.[MessageText] END AS [MessageText],
			NULL AS [SegmentGroupGUID],
			0 AS [SegmentTotal],
			0 AS [SegmentNumber],
			a.[providerTransactionID] AS [TransactionID],
			'MMS' AS [MsgType]
		FROM	txnMMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
		WHERE a.created >= @activityStart AND a.created < @activityEnd
			AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
			AND a.accountID = b.accountID
			AND a.connectionID = c.connectionID
		UNION ALL
		SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			a.txnSMSSubmitGUID AS [MessageGUID],
			'MT' AS [Type],
			a.sourceCode AS [Source],
			a.destinationNumber AS [Destination],
			CAST(a.[Dcs] AS VARCHAR(10)) AS [Dcs],
			CAST(a.[EsmClass] AS VARCHAR(10)) AS [EsmClass],
			a.[Created],
			a.[Processed],
			a.[Completed],
			CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE dbo.parseMessageData(a.[messageData]) END AS [MessageText],
			a.[segmentGroupGUID],
			[SegmentTotal] =
			CASE
				WHEN a.[segmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
			ELSE NULL END,
			[SegmentNumber] =
			CASE
				WHEN a.[segmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
			ELSE NULL END,
			a.[providerTransactionID] AS [TransactionID],
			'SMS' AS [MsgType]
		FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
		WHERE a.created >= @activityStart AND a.created < @activityEnd
			AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
			AND a.accountID = b.accountID
			AND a.connectionID = c.connectionID
		UNION ALL
		SELECT 
			a.accountGUID AS [AccountGUID],
			a.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			MT.[transactionGUID] AS [MessageGUID],
			'MT' AS [Type],
			MT.sourceCode AS [Source],
			MT.destinationNumber AS [Destination],
			CAST(mt.[Dcs] AS VARCHAR(10)) AS [Dcs],
			CAST(mt.[EsmClass] AS VARCHAR(10)) AS [EsmClass],
			mt.auditSubmit AS [Created],
			p.auditResult AS [Processed],
			rs.auditResult AS [Complete],
			CASE WHEN @includeContent = 0 THEN ' -- redacted -- ' ELSE mt.messageText END AS [MessageText],
			mt.segmentGroupGUID AS [SegmentGroupGUID],
			[SegmentTotal] =
			CASE
				WHEN mt.[segmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
			ELSE NULL END,
			[SegmentNumber] =
			CASE
				WHEN mt.[segmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
			ELSE NULL END,
			rs.[providerTransactionID] AS [TransactionID],
			'SMS' AS [MsgType]
		FROM SMSMTSubmit mt WITH (NOLOCK)
		LEFT JOIN account a WITH (NOLOCK)
			ON mt.accountID = a.accountID
		LEFT JOIN connection c WITH (NOLOCK)
			ON mt.connectionID = c.connectionID
		LEFT OUTER JOIN SMSMTResult p WITH (NOLOCK)
			ON mt.transactionGUID = p.transactionGUID AND p.result = 0
		LEFT OUTER JOIN smsMTResult rs WITH (NOLOCK)
			on mt.transactionGUID = rs.transactionGUID
			AND	rs.result IN (
				1, -- SUCCESS: got response back success
				4, -- PHANTOM: phantom message
			   -1, -- NACK: message nacked by provider
			   -2, -- FAIL: internal fail
			   -3, -- ERROR: internal error
			   -6, -- BLOCKED: message blocked
			   -7, -- UNHANDLED: response unhandled (you should NEVER see this)
			   -8, -- INVALID: message was invalid
			   -9, -- UNROUTABLE: message is unrouteable
			  -10  -- TOOLONG: message took too long to send (24 hours)
			)
		WHERE mt.accountID IN (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
		AND auditSubmit BETWEEN @activityStart AND @activityEnd
		ORDER BY [created]

	END

END 
GO
/****** Object:  StoredProcedure [dbo].[getAccountMDRdaily]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getAccountMDRdaily]
	@type		VARCHAR(3),
	@accountID	INT,
	@includeConnection INT = 0
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	DECLARE @activityStart	AS DATETIME;
	DECLARE @activityEnd	AS DATETIME;

	SET @activityStart	= dbo.fnStartOfDay(1);
	SET @activityEnd	= dbo.fnEndOfDay(1);

	IF @includeConnection = 0
	BEGIN

		IF @type = 'DLR'
		BEGIN

		  --DLR / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSDeliverGUID AS [MessageGUID],
			'DLR' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			LEFT(a.[messageText],106) AS [StatusMsg]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b  WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND(esmClass = 4 OR esmClass = 8)
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID;

		END
		ELSE IF @type = 'MO'
		BEGIN

		  --MO / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSDeliverGUID AS [MessageGUID],
			'MO' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			[Processed],
			[Completed]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK)
		  WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND esmClass != 4
				AND esmClass != 8
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID;

		END
		ELSE
		BEGIN

		  --MT / Outbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			txnSMSSubmitGUID AS [MessageGUID],
			'MT' AS [Type],
			sourceCode AS [Source],
			destinationNumber AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			[Processed],
			[Completed],
			[SegmentGroupGUID],
			[SegmentTotal] =
			  CASE
				WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
			  ELSE NULL END,
			[SegmentNumber] =
			  CASE
				WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
			  ELSE NULL END,
  			a.[providerTransactionID] AS [TransactionID]
		  FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID

		END
	END
	ELSE
	BEGIN

		IF @type = 'DLR'
		BEGIN

		  --DLR / Inbound
		  SELECT
			b.accountGUID AS [AccountGUID],
			b.name AS [AccountName],
			c.connectionGUID AS [ConnectionGUID],
			c.name AS [ConnectionName],
			txnSMSDeliverGUID AS [MessageGUID],
			'DLR' AS [Type],
			sourceNumber AS [Source],
			destinationCode AS [Destination],
			[Dcs],
			[EsmClass],
			a.[Created],
			LEFT(a.[messageText],106) AS [StatusMsg]
		  FROM	txnSMSDeliver a WITH (NOLOCK), account b  WITH (NOLOCK), connection c WITH (NOLOCK)
		  WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND(esmClass = 4 OR esmClass = 8)
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID;

		END
		ELSE IF @type = 'MO'
		BEGIN

			--MO / INBOUND
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnMMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				0 AS [Dcs],
				0 AS [EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				'MMS' AS [MsgType]
			FROM	txnMMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			UNION
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnSMSDeliverGUID AS [MessageGUID],
				'MO' AS [Type],
				sourceNumber AS [Source],
				destinationCode AS [Destination],
				[Dcs],
				[EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				'SMS' AS [MsgType]
			FROM	txnSMSDeliver a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE	a.created >= @activityStart AND a.created < @activityEnd
				AND esmClass != 4
				AND esmClass != 8
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			ORDER BY [Created]

		END
		ELSE
		BEGIN

			--MT / Outbound
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnMMSSubmitGUID AS [MessageGUID],
				'MT' AS [Type],
				sourceCode AS [Source],
				destinationNumber AS [Destination],
				0 AS [Dcs],
				0 AS [EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				NULL AS [SegmentGroupGUID],
				0 AS [SegmentTotal],
				0 AS [SegmentNumber],
				a.[providerTransactionID] AS [TransactionID],
				'MMS' AS [MsgType]
			FROM	txnMMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			UNION
			SELECT
				b.accountGUID AS [AccountGUID],
				b.name AS [AccountName],
				c.connectionGUID AS [ConnectionGUID],
				c.name AS [ConnectionName],
				txnSMSSubmitGUID AS [MessageGUID],
				'MT' AS [Type],
				sourceCode AS [Source],
				destinationNumber AS [Destination],
				[Dcs],
				[EsmClass],
				a.[Created],
				[Processed],
				[Completed],
				[SegmentGroupGUID],
				[SegmentTotal] =
				CASE
					WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 5, 1))
				ELSE NULL END,
				[SegmentNumber] =
				CASE
					WHEN [SegmentGroupGUID] IS NOT NULL THEN CONVERT(int, SUBSTRING(messageData, 6, 1))
				ELSE NULL END,
				a.[providerTransactionID] AS [TransactionID],
				'SMS' AS [MsgType]
			FROM	txnSMSSubmit a WITH (NOLOCK), account b WITH (NOLOCK), connection c WITH (NOLOCK)
			WHERE a.created >= @activityStart AND a.created < @activityEnd
				AND a.accountID in (select accountID from account where accountParentID = @accountID OR accountID = @accountID)
				AND a.accountID = b.accountID
				AND a.connectionID = c.connectionID
			ORDER BY [created]

		END

	END

END 












GO
/****** Object:  StoredProcedure [dbo].[getCodeAssignedDetail]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getCodeAssignedDetail]
	@connectionID INT,
	@code VARCHAR(50) = '',
	@page INT = 1,
	@pageSize INT = 100
AS	 
BEGIN 

	SET NOCOUNT ON 

	DECLARE @CodeLength INT = LEN(@code)

	PRINT @CodeLength

	SELECT	a.code, 
			c.connectionGUID, 
			a.name as emailName, 
			emailDomain, 
			emailAddress
	FROM	code a WITH (NOLOCK), connectionCodeAssign b WITH (NOLOCK), connection c WITH (NOLOCK) 
	WHERE	a.codeID = b.codeID
	AND		b.connectionID = c.connectionID
	AND		b.connectionID = @connectionID
	AND		(@CodeLength = 0 OR (LEFT(code, @CodeLength) = @code))
	ORDER	BY code OFFSET (@pageSize * (@page - 1)) ROWS FETCH NEXT @pageSize ROWS ONLY; 

END 



GO
/****** Object:  StoredProcedure [dbo].[getCodeStatus]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[getCodeStatus]
	@code VARCHAR(15) = ''
AS	 
BEGIN 

	SET NOCOUNT ON 

	SELECT
	  a.created,
	  b.created AS [assigned],
	  b.accountName,
	  b.accountID,
	  b.connectionName,
	  b.connectionID,
	  a.code,
	  a.codeID,
	  a.codeTypeID,
	  a.codeRegistrationID,
	  a.voice,
	  a.surcharge,
	  a.espid,
	  a.providerID,
	  p.name AS [providerName],
	  a.publishStatus,
	  a.publishUpdate,
	  a.active,
	  a.deactivated,
	  a.available,
	  a.name,
	  a.emailAddress,
	  a.emailDomain,
	  a.voiceForwardTypeID,
	  a.voiceForwardDestination,
	  a.replyHelp,
	  a.replyStop
	FROM code a WITH (NOLOCK) LEFT JOIN (
	  SELECT 
		ac.name AS [accountName],
		f.accountID,
		codeID,
		e.connectionID,
		f.connectionGUID,
		f.name AS connectionName,
		e.created,
		ac.active
	  FROM connectionCodeAssign e WITH (NOLOCK), connection f WITH (NOLOCK), account ac WITH (NOLOCK)
	  WHERE e.connectionID = f.connectionID
	  AND	f.accountID = ac.accountID
	) b ON a.codeID = b.codeID
	LEFT JOIN provider p WITH (NOLOCK) 
		ON a.providerID = p.providerID
	WHERE a.code = @code;

END
GO
/****** Object:  StoredProcedure [dbo].[getConcatenationCount]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getConcatenationCount]
	@accountID	INT,
	@monthsBack INT = 0
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	IF OBJECT_ID('tempdb..#smsConcatenated') IS NOT NULL DROP TABLE #smsConcatenated;

	DECLARE @startDate AS DATETIME;
	DECLARE @endDate AS DATETIME;

	SET @startDate = dbo.fnStartOfMonth(@monthsBack);
	SET @endDate = dbo.fnEndOfMonth(@monthsBack);

	SELECT  (CAST(CREATED AS DATE)) AS [date],
			(CONVERT([varchar](10), messageData, 2) + ':' + sourceCode + ':' + destinationNumber) AS [key],
			(CONVERT(INT, SUBSTRING(messageData,5,1))) AS [totalSegments],
			([created]) AS [created]
	INTO	#smsConcatenated
	FROM	txnSMSSUbmit (NOLOCK) 
	WHERE	accountID = @accountID
	AND		created BETWEEN @startDate AND @endDate
	AND		esmClass = 64;

	WITH concatenated AS ( 
		SELECT	MIN([created]) AS [firstSegment],
				MAX([created]) AS [lastSegment],
				DATEDIFF(SECOND,MIN([created]),MAX([created])) AS [timeSpan],
				MAX([key]) AS [key],
				MIN([totalSegments]) AS [expectedSegments],
				COUNT(*) AS [totalSegments]
		FROM	#smsConcatenated
		GROUP	BY [date],[key]
	)

	SELECT  MIN([totalSegments]) AS [minSegments],
			MAX([totalSegments]) AS [maxSegments],
			AVG([totalSegments]) AS [avgSegments],
			COUNT(*) AS [totalMessages],
			SUM([totalSegments]) AS [totalSegments]
	FROM	concatenated
	WHERE	totalSegments > 1;

	IF OBJECT_ID('tempdb..#smsConcatenated') IS NOT NULL DROP TABLE #smsConcatenated;


END 





GO
/****** Object:  StoredProcedure [dbo].[getConnectionIDforAccountByAccountID]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getConnectionIDforAccountByAccountID]
	@accountID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT a.name AS accountName, c.name AS connectionName, c.connectionID
	FROM connection c, account a
	WHERE c.accountID = a.accountID
	AND a.accountID = @accountID
	ORDER BY c.name ASC
END

GO
/****** Object:  StoredProcedure [dbo].[getConnectionIDforAccountByAccountName]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getConnectionIDforAccountByAccountName]
	@accountName varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
select a.name as accountName,c.name as connectionName,c.connectionID
from connection c, account a
where c.accountID = a.accountID
and a.name like '%'+@accountName + '%'
order by c.name asc
END





GO
/****** Object:  StoredProcedure [dbo].[getFreeSpace]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getFreeSpace]
AS	 
BEGIN 
	SET NOCOUNT ON 

	;WITH 
		t(s) AS (
			SELECT	CONVERT(DECIMAL(12,2),CAST(SUM(size) AS DECIMAL(12,2))*8/1024.0)  
			FROM	sys.database_files  
			WHERE	[type] % 2 = 0 
		),
		d(s) AS (
			SELECT	CONVERT(DECIMAL(12,2),CAST(SUM(total_pages) AS DECIMAL(12,2))*8/1024.0) 
			FROM sys.partitions AS p 
			INNER JOIN sys.allocation_units AS a 
			ON p.[partition_id] = a.container_id 
		)
	SELECT	Allocated_Space = t.s, 
			Available_Space = t.s - d.s, 
			[Available_%] = CONVERT(DECIMAL(5,2), (t.s - d.s)*100.0/t.s) 
	FROM	t CROSS APPLY d;

END 



GO
/****** Object:  StoredProcedure [dbo].[getMessages]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[getMessages]
	@connectionID INT,
	@startDate VARCHAR(25) = '',
	@endDate VARCHAR(25) = '',
	@source VARCHAR(15) = '',
	@destination VARCHAR(15) = '',
	@startRow INT = 1,
	@maxRows INT = 1000,
	@messageType VARCHAR(5) = 'MT',
	@sortOrder VARCHAR(5) = 'ASC'
AS	 
BEGIN 
	SET NOCOUNT ON 

	DECLARE @@start DATETIME = @startDate; 
	DECLARE @@end DATETIME = @endDate;
	DECLARE @@maxRows INT = @maxRows;
	DECLARE @@startRow INT = @startRow;
	DECLARE @@connectionID INT = @connectionID;
	DECLARE @@source VARCHAR(15) = @source;
	DECLARE @@destination VARCHAR(15) = @destination;
	DECLARE @@sortOrder VARCHAR(5) = @sortOrder;
	DECLARE @@messageType VARCHAR(5) = @messageType;
	
	IF @@start = '' SET @@start = dbo.fnStartOfDay(0);
	IF @@end = '' SET @@end = dbo.fnEndOfDay(0);
	IF @@maxRows > 1000 SET @@maxRows = 1000;

	PRINT @@start;
	PRINT @@end;
	PRINT @@maxRows;
	PRINT @@startRow;
	PRINT @@connectionID;
	PRINT @@source;
	PRINT @@destination;
	PRINT @@sortOrder;

	IF (@@connectionID IN (302))
	BEGIN

		IF @@end > DATEADD(DAY,1,@@start) 
		BEGIN
			SET @@end = DATEADD(DAY,1,@@start)
		END

	END

	IF (@@messageType='MT')
	BEGIN

		SELECT 
			mt.auditSubmit AS [created],
			p.auditResult AS [processed],
			c.auditResult AS [complete],
			mt.messageText,
			MT.[transactionGUID],
			sourceCode AS [source],
			destinationNumber AS [destination],
			'MT' AS [type],
			CASE 
				WHEN mode=1 THEN 'Phantom' 
				WHEN mode=0 AND c.auditResult IS NULL THEN 'Pending'
				WHEN mode=0 AND c.auditResult IS NOT NULL AND (c.result = 1 OR c.result = 4) THEN 'Success'
				ELSE 'Failed'
			END AS [status]
		FROM SMSMTSubmit mt WITH (NOLOCK)
		LEFT OUTER JOIN SMSMTResult p WITH (NOLOCK)
			ON mt.transactionGUID = p.transactionGUID AND p.result = 0
		LEFT OUTER JOIN smsMTResult c WITH (NOLOCK) 
			ON mt.transactionGUID = c.transactionGUID AND (c.result = 1 OR c.result = 4)  /*(1,4,-1,-2,-3,-6,-7,-8,-9,-10)*/
		WHERE connectionID = @@connectionID
		AND auditSubmit BETWEEN @@start AND @@end
		AND	(@@source = '' OR sourceCode = @@source)
		AND	(@@destination = '' OR destinationNumber = @@destination)
		ORDER BY 
			auditSubmit ASC
			OFFSET (@@startRow-1) ROWS FETCH NEXT @@maxRows ROWS ONLY;

	END
	ELSE 
	BEGIN

		SELECT 
			created,
			processed,
			completed,
			messageText,
			txnSMSDeliverGUID AS [transactionGUID],
			sourceNumber AS [source],
			destinationCode AS [destination],
			'MO' AS [type],
			CASE 
				WHEN completed IS NULL THEN 'Pending'
				WHEN completed IS NOT NULL AND (forwardSystemID IS NOT NULL OR forwardStatusCodeHTTP IN ('200','201')) THEN 'Success'
				ELSE 'Failed'
			END AS [status]
		FROM 
			txnSMSDeliver WITH (NOLOCK)
		WHERE 
			connectionID = @@connectionID
		AND created BETWEEN @@start AND @@end
		AND	esmClass NOT IN (4,8)
		AND	(@@source = '' OR sourceNumber = @@source)
		AND	(@@destination = '' OR destinationCode = @@destination)
		ORDER BY 
			created ASC
			OFFSET (@@startRow-1) ROWS FETCH NEXT @@maxRows ROWS ONLY;	
						
	END
END
GO
/****** Object:  StoredProcedure [dbo].[getNumberCountryNPAOverride]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getNumberCountryNPAOverride]
	@destinationCode CHAR(50),
	@sourceNumber CHAR(50)
AS	 
BEGIN 
	SET NOCOUNT ON 

	SELECT	cn.*, c.code, c.codeID 
	FROM	numberCountryNPAOverride npa, code c, connection cn
	WHERE countryCodeNormalized = (
		SELECT  countryCodeNormalized
		FROM	numberCountryNPAExtended WITH (NOLOCK)
		WHERE	countryCode = LEFT(@sourceNumber, LEN(countryCode))
	)
	AND	c.code = @destinationCode
	AND npa.connectionID = cn.connectionID
	AND	npa.codeID = c.codeID

END 






GO
/****** Object:  StoredProcedure [dbo].[getRecentAccountRegistrations]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getRecentAccountRegistrations]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT top 10 * from accountRegistration order by accountRegistrationID desc 

END





GO
/****** Object:  StoredProcedure [dbo].[getRouteActions]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[getRouteActions]
	@sourceCode VARCHAR(50),
	@destinationCode VARCHAR(50),
	@connectionID INT,
	@routeActionTypeID INT
AS	 
BEGIN 
	SET NOCOUNT ON 

	DECLARE @MaxRows INT;

	IF @routeActionTypeID IN (1,10)
		SET @MaxRows = 1;
	ELSE
		SET @MaxRows = 9999;

	SELECT	TOP (SELECT @MaxRows)
			b.routeActionTypeID, 
			b.routeActionValue, 
			dc.providerID
	FROM	route a with (NOLOCK)
			INNER JOIN routeAction b with (NOLOCK) 
				ON a.routeID = b.routeID
			INNER JOIN connection c with (NOLOCK) 
				ON c.connectionID = a.connectionID 
			LEFT OUTER JOIN code dc with (NOLOCK)  
				ON dc.code = @sourceCode
	WHERE	a.connectionID = @connectionID 
			AND a.routeID IN (
				SELECT	routeID
				FROM	route rt (NOLOCK)
				WHERE	connectionID = @connectionID 
				AND		rt.sourceCodeCompare = '0'
				AND		rt.destinationCodeCompare = '0'
			)
			AND b.active = 1 
			AND c.active = 1
			AND (
					((@routeActionTypeID IN (1,10) AND b.routeActionTypeID = @routeActionTypeID))
				OR	((@routeActionTypeID NOT IN (1,10) AND b.routeActionTypeID >= 2))
			)
	ORDER	BY routeSequence DESC

END
GO
/****** Object:  StoredProcedure [dbo].[getVoiceConfig]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getVoiceConfig]
AS
BEGIN
    -- Using NOCOUNT to reduce traffic and load on the system.
    SET NOCOUNT ON
    SELECT
        LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.name,',',''),'&','_'),'/',''),'(',''),')',''),' ','_'),'-','_'),'.',''),'___','_'),'__','_')) AS [name],
        d.code,
        d.voiceForwardTypeID,
        d.voiceForwardDestination,
        CASE WHEN d.codeRegistrationID IN (750) OR b.accountID IN (7) THEN 'false' ELSE 'true' END AS [mediaBypass]
    FROM account a (NOLOCK), connection b (NOLOCK), connectionCodeAssign c (NOLOCK), code d (NOLOCK)
    WHERE a.accountID = b.accountID
        AND b.connectionID = c.connectionID
        AND c.codeID = d.codeID
        AND d.voice = 1
        AND d.active = 1
        AND d.voiceForwardDestination IS NOT NULL
        AND RTRIM(LTRIM(d.voiceForwardDestination)) != ''
        AND
            (
                d.voiceForwardTypeID IN (1,3)
                OR
                (
                    d.voiceForwardTypeID = 2
                    AND
                    LEFT(d.voiceForwardDestination,4) IN (
                        SELECT  countryCode
                        FROM    numberCountryNPAExtended
                        WHERE   countryCodeNormalized IN ('1USA','1CAN','18xx')
                        AND     countryCode NOT IN (
                            SELECT  CONCAT('1',npa) AS [NPA]
                            FROM    numberAreaPrefix
                            WHERE   stateCodeAlpha2 IN ('AK','HI')
                        )
                    )
                )
            )
    UNION ALL
    SELECT
        'e_telecocom' AS [name],
        d.code,
        '1' AS voiceForwardTypeID,
        '68.64.83.168' AS voiceForwardDestination,
        'true' AS [mediaBypass]
    FROM code d (NOLOCK)
    WHERE d.voice = 1
        AND d.available = 1
        AND d.voiceForwardDestination IS NULL
        AND d.codeRegistrationID IN (200,550,700)
    ORDER BY name, code
END


GO
/****** Object:  StoredProcedure [dbo].[getVoicePRIMARY]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[getVoicePRIMARY]
AS	 
BEGIN 

	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	SELECT
		LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.name,',',''),'&','_'),'/',''),'(',''),')',''),' ','_'),'-','_'),'.',''),'___','_'),'__','_')) AS [name],
		d.code,
		d.voiceForwardTypeID,
		d.voiceForwardDestination,
		CASE WHEN d.codeRegistrationID IN (750) OR b.accountID IN (7) THEN 'false' ELSE 'true' END AS [mediaBypass]
	FROM account a (NOLOCK), connection b (NOLOCK), connectionCodeAssign c (NOLOCK), code d (NOLOCK)
	WHERE a.accountID = b.accountID
		AND b.connectionID = c.connectionID
		AND c.codeID = d.codeID
		AND d.voice = 1
		AND d.active = 1
		AND d.voiceForwardDestination IS NOT NULL
		AND RTRIM(LTRIM(d.voiceForwardDestination)) != ''
		AND 
			( 
				d.voiceForwardTypeID IN (1,3) 
				OR
				(
					d.voiceForwardTypeID = 2
					AND
					LEFT(d.voiceForwardDestination,4) IN (
						SELECT	countryCode
						FROM	numberCountryNPAExtended
						WHERE	countryCodeNormalized IN ('1USA','1CAN','18xx')
						AND		countryCode NOT IN (
							SELECT	CONCAT('1',npa) AS [NPA]
							FROM	numberAreaPrefix
							WHERE	stateCodeAlpha2 IN ('AK','HI')
						)
					)
				)
			)
	UNION ALL
	SELECT
		'e_telecocom' AS [name],
		d.code,
		'1' AS voiceForwardTypeID,
		'68.64.83.168' AS voiceForwardDestination,
		'true' AS [mediaBypass]
	FROM code d (NOLOCK)
	WHERE d.voice = 1
		AND d.available = 1
		AND d.voiceForwardDestination IS NULL
		AND d.codeRegistrationID IN (200,550,700)
	ORDER BY name, code

END 









GO
/****** Object:  StoredProcedure [dbo].[incrementDeliverRetryCount]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[incrementDeliverRetryCount]
	-- Add the parameters for the stored procedure here
	@txnSMSDeliverID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE txnSMSDeliver SET forwardRetryCount = forwardRetryCount+1 WHERE txnSMSDeliverID = @txnSMSDeliverID
END




GO
/****** Object:  StoredProcedure [dbo].[mosaicSwitchToESPID]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mosaicSwitchToESPID]
	@code varchar(15), 
	@connectionID INT
WITH EXECUTE AS 'dbo'  
AS
BEGIN

	DECLARE @codeID INT;
	DECLARE @currentESPID VARCHAR(10);
	DECLARE @inConnection INT = 0;
	DECLARE @errorMessage VARCHAR(255);

	SET NOCOUNT ON;

	BEGIN TRY

		SET @codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @currentESPID = (SELECT espid FROM code WHERE codeID = @codeID);
		SET @inConnection = (SELECT COUNT(*) FROM connectionCodeAssign ca, connection co WHERE ca.codeID = @codeID AND ca.connectionID = @connectionID AND ca.connectionID=co.connectionID AND co.accountID IN (SELECT accountID FROM account WHERE accountID=44 OR accountParentID=44));

		PRINT 'In Connection: ' + CAST(@inConnection AS VARCHAR(5));

		IF (@inConnection > 0) AND (@currentESPID != 'E911')
		BEGIN
			UPDATE code SET publishStatus=1, espid='E911', publishUpdate=2 WHERE codeID = @codeID;
			SELECT 'Success' AS [result], @code AS [code], @connectionID AS [connectionID];
		END
		ELSE
		BEGIN
			SELECT 'Failed' AS [result], @code AS [code], @connectionID AS [connectionID];
		END

	END TRY
	BEGIN CATCH

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed', @code, @connectionID;
	END CATCH
END
































GO
/****** Object:  StoredProcedure [dbo].[provisionAccount]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[provisionAccount] 
	@accountRegistrationID INT,
	@permissions INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;
	----------------------------------------------------------------------------------------------------------------------------------------------------------

	declare @checkRecord INT
	declare @accountID INT
	declare @accountGUID varchar(40)
	declare @accountName varchar(150)
	declare @connectionID INT
	declare @connectionGUID varchar(40)
	declare @connectionGroupID INT
	declare @routeID INT

--##Dynamic Parameter Values:
--##X = accountRegistrationID (put this value in every query where X is stated)
--##Y = accountID (get this after step 3 is run and put it in every query where Y is stated)
--##Z = connectionID
--##W = routeID

--#STEP 1: manually create an accountRegistration record or have the customer complete the form.
--#STEP 2: registration must be verified and approved before provisioning can start

--STEP 3A - verify reg record is ready or exit out of procedure
    set @checkRecord = (
		select count(*) from accountRegistration where verified is not null and approved is not null and provisioned is null and accountRegistrationID = @accountRegistrationID
		)

	if @checkRecord = 0
    begin
    raiserror('AERIALINK Message - Registration Record does not exist, is not approved, or is already provisioned!', 18, 1)
    return -1
    end


--#STEP 3: insert 'account' record from the 'accountRegistration' record - A REGISTRATION RECORD MUST EXIST PRIOR TO THIS PROCESS
--## required parameters are: accountRegistrationID, accountParentID (defaults to 0), billingType (defaults to 2)
insert account (accountParentID,accountRegistrationID,name,billingType,email,phone1,phone1isMobile,address1,address2,city,state,zip,country,active,created,lastUpdated)
select 0 as accountParentID, @accountRegistrationID, accountName as name, 1 as billingType, email, phone as phone1, phoneIsMobile as phone1isMobile,
	address1, address2, city, state, zip, country, 1 as active, getUTCDate() as created, getUTCDate() as lastUpdated
from accountRegistration where verified is not null and approved is not null and provisioned is null
and accountRegistrationID = @accountRegistrationID

--#NOTES:
--#billingType:
--#1 = Post Paid, not subject to rating blocks
--#2 = Pre-paid, allow to queue, but do not send
--#3 = Pre-paid, do not allow queueing, full block

--#get newly created accountID which should be the last autoincrementID for the new account record and the accountname
set @accountID = SCOPE_IDENTITY()
set @accountName = (select name from account where accountID = @accountID)
set @accountGUID = (select accountGUID from account where accountID = @accountID)

--#STEP 4: insert accountContact : we will always create the default primary contact for them
--# provide accountID where you see Y and accountRegistrationID where you see X
insert accountContact (accountID,accountContactPrimary,firstName,lastName,email,phone1,phone1isMobile,address1,address2,city,state,zip,country,active,created,lastUpdated)
select @accountID as accountID,1 as accountContactPrimary,firstName,lastName,
email,phone as phone1,phoneIsMobile as phone1isMobile,
address1,address2,city,state,zip,country,
1 as active,getUTCDate() as created, getUTCDate() as lastUpdated
from accountRegistration where verified is not null and approved is not null and provisioned is null
and accountRegistrationID = @accountRegistrationID;    
-- #!PROVIDE accountRegistrationID!#
--#NOTES:accountContactTypeID: 1-Administrator/Primary, 2-Technical, 3-Billing, 4-Other - we always set this default accountContact as admin/primary

--#STEP 5: insert accountUser : we will always create the default user account for them
insert accountUser (accountID, firstName, lastName, email, phone1, phone1isMobile, active, created, lastUpdated)
select @accountID as accountID, firstName, lastName, email, phone as phone1, phoneIsMobile as phone1isMobile, 1 as active, getUTCDate() as created, getUTCDate() as lastUpdated
from accountRegistration 

where verified is not null and approved is not null and provisioned is null and accountRegistrationID = @accountRegistrationID
--#NOTES: #it defaults to timezone = 13 and daylightSavingTime = 1, in the provisioning tool, allow us to set these - the new umi handles timezones differently

--#STEP 6: insert connection : we will always create one default connection for them
insert connection (accountID,name,codeDistributionMethodID
	,enforceOptOut,messageExpirationHours,
	active,created,lastUpdated)
values (@accountID,@accountName,0,
	0,24,
	1,getUTCDate(),getUTCDate())

--#get newly created connectionID
set @connectionID = SCOPE_IDENTITY()
set @connectionGUID = (select connectionGUID from connection where connectionID = @connectionID)

--#STEP 7: insert connectionGroup : we will always create one default connectionGroup for them
insert connectionGroup (accountID, name, created, lastUpdated)
values (@accountID, @accountName, getUTCDate(), getUTCDate())

--#get newly created connectionID
set @connectionGroupID = SCOPE_IDENTITY()

--#STEP 8: insert connectionGroupAssign : we will always create one default record tying the connection and connectionGroup together
insert connectionGroupAssign (connectionGroupID, connectionID)
values (@connectionGroupID,@connectionID)


--#STEP 9: insert route : create default route
insert route (accountID,connectionID,acceptDeny,sourceCodeCompare,destinationCodeCompare,messageDataCompare,numberOperatorID,
			validityDateStart,validityDateEnd,validityTimeStart,validityTimeEnd,routeSequence,
			created,lastUpdated)
values (@accountID, @connectionID, 1, 0, 0, 0, 0, 
			'1900-01-01 00:00:00', '2900-01-01 00:00:00', '00:00:00', '23:59:59', 1,
			getUTCDate(), getUTCDate())

--#get newly created routeID
set @routeID = SCOPE_IDENTITY()

--#STEP 10: SET DEFAULT MT ROUTE, the MO WILL HAVE TO BE DEFINED IN THEIR UMI
insert routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
values (@routeID, 1, 0, 1, getUTCDate(), getUTCDate())

insert routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
values (@routeID, 10, 0, 1, getUTCDate(), getUTCDate())

--Add access to codes lookup, leased code provisioning and reporting by default
insert routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
values (@routeID, 17, 0, 1, getUTCDate(), getUTCDate())

insert routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
values (@routeID, 18, 0, 1, getUTCDate(), getUTCDate())

insert routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
values (@routeID, 19, 0, 1, getUTCDate(), getUTCDate())

/*
PROCEDURE [dbo].[provisionAccount] 
	@accountRegistrationID INT,
	@permissions INT = 0

@permissions values
Connection API Access		1	/* 001 */
Account API Access			2	/* 010 */
Internal Codes API Access	4	/* 100 */
*/

IF (@permissions & 1) = 1 
BEGIN
	insert routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	values (@routeID, 16, 0, 1, getUTCDate(), getUTCDate());
END;

IF (@permissions & 2) = 2
BEGIN
	insert routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	values (@routeID, 20, 0, 1, getUTCDate(), getUTCDate());
END;

IF (@permissions & 4) = 4 
BEGIN
	insert routeAction (routeID,routeActionTypeID,routeActionValue, active, created,lastUpdated)
	values (@routeID, 21, 0, 1, getUTCDate(), getUTCDate());
END;



--#update the accountregistration record to mark it now as provisioned
update accountRegistration set provisioned = getUTCDate(), lastUpdated = getUTCDate() where accountRegistrationID = @accountRegistrationID;

select @accountName AS [accountName], @accountGUID AS [accountGUID], @connectionGUID AS [connectionGUID]

END
GO
/****** Object:  StoredProcedure [dbo].[provisionCode]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--ADD THE CODE ONLY IF IT IS A NEW ONE (code, name, espid, codeTypeID, codeRegistrationID, providerGroupID, publishStatus, publishUpdate, emailAddress, emailDomain)

CREATE PROCEDURE [dbo].[provisionCode] 
	-- Add the parameters for the stored procedure here
	@code varchar(15),
	@name varchar(100),
	@itemCode INT, 
	@espid varchar(10), 
	@codeTypeID INT,
	@codeRegistrationID INT,
	@providerID smallint,
	@publishStatus BIT,
	@publishUpdate TINYINT,
	@emailAddress varchar(100),
	@emailDomain varchar(100),
	@surcharge BIT = 0,
	@note varchar(255) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	BEGIN TRY
	SET NOCOUNT ON;

	--Check to see if data has already been added to activity for this customer, and if so, kill the process
	declare @checkRecord INT

    set @checkRecord = (
			select count(*) from gateway.dbo.code c 
			where c.code = @code
		)

	if @checkRecord > 0
    begin
		raiserror('AERIALINK Message - This CODE already EXISTS! Process has been halted!', 18, 1)
		return -1
    end
	BEGIN TRANSACTION
		insert into code (codeGUID,codeTypeID,code,name,itemCode,espid,codeRegistrationID,providerID,publishStatus,publishUpdate,active,emailAddress,emailDomain,created, surcharge, notePrivate) 
		values (newid(),@codeTypeID,@code,@name,@itemCode,@espid,@codeRegistrationID,@providerID,@publishStatus,@publishUpdate,0,@emailAddress,@emailDomain,getutcdate(), @surcharge, @note)
		select 'provisionCode Completed', @@identity
	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[provisionConnection]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[provisionConnection] 
	@connectionName varchar(100),
	@accountID INT

AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	declare @connectionID INT;
	declare @connectionGUID CHAR(36);
	declare @routeID INT;

	BEGIN TRANSACTION

	--#STEP 1: INSERT connection : we will always create one default connection
	INSERT connection ( accountID, name, codeDistributionMethodID,
		 messageExpirationHours, active)
	VALUES (@accountID, @connectionName, 0, 24, 1);
	
	-- get newly created connectionID
	SET @connectionID = SCOPE_IDENTITY();
	SET @connectionGUID = (SELECT connectionGUID FROM connection WHERE connectionID = @connectionID);
	
	--#STEP 2: INSERT route : create default route
	INSERT route (accountID, connectionID, acceptDeny, numberOperatorID,
				validityDateStart, validityDateEnd, validityTimeStart, validityTimeEnd, routeSequence)
	VALUES (@accountID, @connectionID, 1, 0, '1900-01-01 00:00:00', '2900-01-01 00:00:00', '00:00:00', '23:59:59', 1);
	
	-- get newly created routeID
	SET @routeID = SCOPE_IDENTITY();
	
	--#STEP 3: Provide access to SMS MT, reports and query/publish leased codes.

	-- route action type SMS Outbound (MT)
	INSERT routeAction (routeID, routeActionTypeID, routeActionValue, active) VALUES (@routeID, 1, 0, 1);
	
	-- route action type MMS Outbound (MT) HTTP
	INSERT routeAction (routeID, routeActionTypeID, routeActionValue, active) VALUES (@routeID, 10, 0, 1);
	
	-- route action type Code Publish API Access
	INSERT routeAction (routeID, routeActionTypeID, routeActionValue, active) VALUES (@routeID, 17, 0, 1);
	
	-- route action type Code Query API Access
	INSERT routeAction (routeID, routeActionTypeID, routeActionValue, active) VALUES (@routeID, 18, 0, 1);
	
	-- route action type Reporting API Access
	INSERT routeAction (routeID,routeActionTypeID,routeActionValue, active) VALUES (@routeID, 19, 0, 1);
	
	SELECT @connectionID AS [connectionID], @connectionGUID AS [connectionGUID];

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[provisionConnectionCodeAssign]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[provisionConnectionCodeAssign]
	@code varchar(15), 
	@connectionID INT,
	@campaignID VARCHAR(10) = NULL,
	@mnoIsPool BIT = 0,
	@ignoreBlock BIT = 0
AS
BEGIN
	declare @@codeID int;
	declare @@publishStatus int;
	declare @@acountName	AS VARCHAR(255);
	declare @errorMessage	AS VARCHAR(255);
	declare @@espid AS VARCHAR(10);
	declare @@priority AS INT;
	declare @@deactivated AS INT;
	declare @@voice AS INT;
	declare @@assignedCnt AS INT;
	declare @@publishUpdate AS INT;
	declare @@isShared AS TINYINT;
	declare @@accountID INT;
	declare @@providerID INT;
	declare @@blocked INT;
	declare @@mnoStatus VARCHAR(50);

	SET @@priority=1;

	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN

		set @@codeID = (select codeID from code where code = @code);
		set @@deactivated = (select deactivated from code where codeID = @@codeID);
		set @@assignedCnt = (SELECT COUNT(*) FROM connectionCodeAssign WHERE codeID = @@codeID); -- 0 means not already assign (available)
		set @@isShared = (SELECT shared from code where codeID = @@codeID);
		set @@accountID = (SELECT accountID FROM connection WHERE connectionID = @connectionID);
		set @@providerID = (SELECT providerID FROM code WHERE codeID = @@codeID);
		set @@blocked = 0 -- Default to allow

		IF (@@accountID IN (284,360,711,712)) -- Block EBO from taking codes from inventory
		BEGIN
			set @@blocked = 1
		END

		IF (@campaignID IS NOT NULL) 
		BEGIN
			set @@mnoStatus = (
				SELECT	'{"att": ' + CASE WHEN [attRecordStatus] = 'REGISTERED' THEN '1' ELSE '0' END + ', "tmobile": ' + CASE WHEN [tmobileRecordStatus] = 'REGISTERED' THEN '1' ELSE '0' END + '}'
				FROM	[gateway].[dbo].[partnerCampaign]
				WHERE	campaignID = @campaignID
			)

			set @mnoIsPool = (
				SELECT	mnoIsPool
				FROM	[gateway].[dbo].[partnerCampaign]
				WHERE	campaignID = @campaignID
			)
		END

		-- Don't allow publishing of deactivated codes
		-- Only publish a code that is already assigned if it is marked as shared
		IF (@@accountID NOT IN (0) OR @ignoreBlock = 1) AND @@deactivated=0 AND (@@blocked = 0 OR @ignoreBlock = 1) AND (@@assignedCnt=0 OR @@isShared=1)
		BEGIN

			set @@publishUpdate = (select publishUpdate from code where codeID = @@codeID);
			set @@publishStatus = (select publishstatus from code where codeID = @@codeID);
			set @@providerID = (select providerID from code where codeID = @@codeID);
			set @@acountName = (SELECT a.name FROM account a, connection c WHERE a.accountID = c.accountID AND c.connectionID = @connectionID);
			set @@espid = (select espid from code where codeID = @@codeID);
			set @@voice = (select voice from code where codeID = @@codeID);

			BEGIN
				insert connectionCodeAssign (connectionID, codeID) values (@connectionID, @@codeID);
				update code set active=1, available=0, campaignID = @campaignID, mnoIsPool = @mnoIsPool, mnoStatus = @@mnoStatus where codeID = @@codeID;
				--update code set active=1, available=0, sms=1, campaignID = @campaignID, mnoIsPool = @mnoIsPool, mnoStatus = @@mnoStatus where codeID = @@codeID;
				insert connectionCodeAssignHistory (connectionID, codeID, action, created) values (@connectionID, @@codeID, 1, getutcdate());
				insert cacheConnectionCodeAssign (code, connectionID, cacheStatus) values (@code, @connectionID, 1);
			END

			IF (@@providerID = 8) -- Blocking TF until verified, blocked by default.
			BEGIN
				-- update code set providerID=999, notePrivate = 'Unverified' where codeID = @@codeID;
				update code set notePrivate = 'Unverified' where codeID = @@codeID;
			END
			

			IF @@publishUpdate > 0 
			BEGIN
				SET @@priority = @@publishUpdate
			END

			IF @connectionID = 15 
			BEGIN
				SET @@priority = 2
			END

			IF @connectionID IN (365,346,396)
			BEGIN
				SET @@priority = 3
			END

			IF @connectionID IN (309,325,294)
			BEGIN
				SET @@priority = 4
			END

			-- State Farm default configuration for 10DLC 
			IF @@accountID IN (3,124,125,658,659,660) AND @@providerID = 1
			BEGIN
			   update code set mnoIsPool = 1, mnoStatus = '{"att": 1, "tmobile": 1}', campaignID = 'CUE3GTO' where codeID = @@codeID;
			END

			-- Call-Em-All default configuration
			IF @connectionID IN (396,365,346) AND @@voice = 1
			BEGIN
				update code set voiceForwardTypeID=3, voiceForwardDestination='message.wav' where codeID = @@codeID;	
			END

			-- SAS2 default voice configuration
			IF @connectionID IN (1310) AND @@voice = 1
			BEGIN
				update code set voiceForwardTypeID=1, voiceForwardDestination='smssip7560217519402816365@phone.plivo.com' where codeID = @@codeID;	
			END

			-- Openity default voice configuration
			IF @@accountID = 60 AND @@voice = 1
			BEGIN
				update code set voiceForwardTypeID=1, voiceForwardDestination='proxy1.openity.us' where codeID = @@codeID;	
			END

			-- Bartel default ESPID configuration
			IF @@accountID = 359 
			BEGIN
				update code set espid = 'E784' where codeID = @@codeID;	
			END

			-- Plivo MMS connection
			IF @connectionID = 1846 AND @@providerID = 1
			BEGIN
					UPDATE code SET espid='E136' WHERE codeID = @@codeID;
				--UPDATE code SET espid='E136', mms=1 WHERE codeID = @@codeID;	
			END

			IF len(@code) = 11 and LEFT(@@espid,1) = 'E' 
			BEGIN
				update code set publishstatus=1, publishupdate=@@priority where codeID = @@codeID;	
			END

			select 'Completed', @code, @connectionID;

		END

		/* Allow for updating just the campaign and isPool for already active code */
		ELSE IF (@campaignID IS NOT NULL) 
		BEGIN
			update code set publishStatus=1, publishUpdate=1, campaignID = @campaignID, mnoIsPool = @mnoIsPool, mnoStatus = @@mnoStatus where codeID = @@codeID;
			select 'Updated', @code, @connectionID;
		END
		
		ELSE
		BEGIN
			select 'Failed', @code, @connectionID, @@deactivated, @@assignedCnt, @@isShared;
		END

		COMMIT TRAN;

	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0)
			ROLLBACK TRAN;

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed', @code, @connectionID;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[provisionConnectionCodeAssignByCodeID]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[provisionConnectionCodeAssignByCodeID]
	@connectionID INT, 
	@codeID INT,
	@ignoreBlock BIT = 0
AS
BEGIN

	declare @@code			AS VARCHAR(15);
	declare @@publishStatus AS INT;
	declare @@acountName	AS VARCHAR(255);
	declare @errorMessage	AS VARCHAR(255);
	declare @@espid			AS VARCHAR(10);
	declare @@priority		AS INT;
	declare @@deactivated	AS INT;

	SET @@priority=1;

	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN

		set @@deactivated = (select deactivated from code where code = @codeID);

		IF (@connectionID NOT IN (488) OR @ignoreBlock = 1) AND @@deactivated=0
		BEGIN

			set @@code = (select code from code where code = @codeID and deactivated = 0);
			set @@publishStatus = (select publishstatus from code where code = @@code and deactivated = 0);
			set @@acountName = (SELECT a.name FROM account a, connection c WHERE a.accountID = c.accountID AND c.connectionID = @connectionID);
			set @@espid = (select espid from code where code = @@code);

			BEGIN
				insert connectionCodeAssign (connectionID, codeID) values (@connectionID, @codeID);
				--update code set active=1, available=0, sms=1 where codeID = @codeID;
				update code set active=1, available=0 where codeID = @codeID;
				insert connectionCodeAssignHistory (connectionID, codeID, action, created) values (@connectionID, @codeID, 1, getutcdate());
				insert cacheConnectionCodeAssign (code, connectionID, cacheStatus) values (@@code, @connectionID, 1);
			END

			IF @connectionID = 15 
			BEGIN
				SET @@priority = 2
			END

			IF len(@@code) = 11 and LEFT(@@espid,1) = 'E' 
			BEGIN
				update code set publishstatus=1, publishupdate=@@priority where codeID = @codeID;	
			END

			SELECT 'Completed', @@code, @connectionID;

		END
		ELSE
		BEGIN
			SELECT 'Failed', @@code, @connectionID;
		END

		COMMIT TRAN;

	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0)
			ROLLBACK TRAN;

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed', @@code, @connectionID;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[recordCountByAccountID]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[recordCountByAccountID]
	@accountList VARCHAR(255)	-- comma seperated list of accountIDs
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @count INT; 

		SET @count = (SELECT COUNT (accountID) FROM account WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'account:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (accountUserID) FROM accountUser WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'accountUser:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT(blockCodeNumberID) FROM blockCodeNumber WHERE code IN ( SELECT code FROM code WHERE codeID IN ( SELECT codeID FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))))));
		PRINT 'blockCodeNumber:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (cacheConnectionCodeAssignID) FROM cacheConnectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'cacheConnectionCodeAssign:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (codeRegistrationID) FROM codeRegistration WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'codeRegistration:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (connectionID) FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'connection:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (connectionID) FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'connectionCodeAssign:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (credentialID) FROM credential WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'credential:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (firewallID) FROM firewall WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'firewall:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (keywordID) FROM keyword WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'keyword:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (routeID) FROM route WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'route:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT(routeActionID) FROM routeAction WHERE routeID IN (SELECT routeID FROM route WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'routeAction:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (routeConnectionID) FROM routeConnection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList)));
		PRINT 'routeConnection:' + CAST(@count AS VARCHAR(10));

		SET @count = (SELECT COUNT (connectionID) FROM xTempBulkAction WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT * FROM CSVToTable(@accountList))));
		PRINT 'xTempBulkAction:' + CAST(@count AS VARCHAR(10));

END


GO
/****** Object:  StoredProcedure [dbo].[refreshNumberCountryNPAExtended]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[refreshNumberCountryNPAExtended]
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

	BEGIN TRANSACTION

	DELETE numberCountryNPAExtended;

	INSERT numberCountryNPAExtended (countryCode, countryName, countryCodeNormalized) 
	--SELECT '1' AS countryCode, 'United States of America' AS countryName, '1USA' AS countryCodeNormalized
	--UNION - CANT HAVE BOTH +1 and ALL OF THE +1xxx, it will create duplicate counts
	SELECT countryCode, countryName, convert(varchar(4),countryCode) AS countryCodeNormalized FROM numberCountry WHERE countryCode != '1'
	UNION
	SELECT DISTINCT CONCAT('1',npa) AS countryCode, 'United States of America' AS countryName, '1USA' AS countryCodeNormalized 
		FROM numberAreaPrefix a LEFT JOIN numberState b ON a.stateCodeAlpha2 = b.stateCodeAlpha2
		WHERE countrycodealpha3 = 'USA'
	UNION
	SELECT DISTINCT CONCAT('1',npa) AS countryCode, 'Canada' AS countryName, '1CAN' AS countryCodeNormalized 
		FROM numberAreaPrefix a LEFT JOIN numberState b ON a.stateCodeAlpha2 = b.stateCodeAlpha2
		WHERE countrycodealpha3 = 'CAN'
	UNION
	SELECT countryCode, 'Location Neutral 8XX' AS countryName, '18XX' AS countryCodeNormalized 
	FROM (VALUES ('1800'),('1833'),('1844'),('1855'),('1866'),('1877'),('1888')) x(countryCode)
	UNION
	SELECT countryCode, 'Location Neutral 5XX' AS countryName, '15XX' AS countryCodeNormalized 
	FROM (VALUES ('1500'),('1522'),('1533'),('1544'),('1566'),('1577'),('1588')) x(countryCode)
	--add Trinidad and Tobago AS it is not in the code US/CAN great data file - it is its own COUNTRY, so not grouped with 1USA, 1CAN, or 18XX/15XX
	UNION
	SELECT countryCode, 'Trinidad and Tobago' AS countryName, '1868' AS countryCodeNormalized 
	FROM (VALUES ('1868')) x(countryCode)

	COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        	ROLLBACK TRANSACTION;
		THROW;
	END CATCH

END


GO
/****** Object:  StoredProcedure [dbo].[releaseCode]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[releaseCode]
	@code VARCHAR(50) = '',
	@connectionID INT = 1
AS	 
BEGIN 

	SET NOCOUNT ON 

	DECLARE @status VARCHAR(20);
	DECLARE @accountName VARCHAR(100);
	DECLARE @connectionName VARCHAR(50);
	DECLARE @publishStatus INT;
	DECLARE @itemCode INT;

	DECLARE @SP_Results TABLE
	(
	  result VARCHAR(20)
	)

	SET @accountName = (SELECT name FROM account WHERE accountID = (SELECT accountID FROM connection WHERE connectionID=@connectionID));
	SET @connectionName = (SELECT name FROM connection WHERE connectionID=@connectionID);
	SET @publishStatus = (SELECT publishStatus FROM code WHERE code = @code);
	SET @itemCode = (SELECT itemCode FROM code WHERE code = @code);

	INSERT INTO @SP_Results (result)
	EXEC dbo.deProvisionConnectionCodeAssign @code, @connectionID

	SET @status = (SELECT TOP 1 result FROM @SP_Results)

	IF (@status = 'true' AND @publishStatus = 1 AND @itemCode = 101)
		UPDATE code SET publishStatus=0, publishUpdate=1 WHERE code = @code;
	
	SELECT @accountName [accountName], @connectionName [connectionName], @code [code], @status [result]

END 






GO
/****** Object:  StoredProcedure [dbo].[reportAccountMO]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[reportAccountMO]
AS
BEGIN

DECLARE @cols AS NVARCHAR(MAX),
		@query AS NVARCHAR(MAX)

SELECT @cols = STUFF((
	SELECT ',' + QUOTENAME(CONVERT(VARCHAR(10),RetVal,120)) FROM dbo.CreateDateRange(DATEADD(DAY,-31,dbo.fnStartOfDay(0)), dbo.fnStartOfDay(1), 'DD', 1)
	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,''
)

SET @query =   'SELECT	*
FROM (
	SELECT	MAX(ac.name) AS [account],
			MAX(CONVERT(VARCHAR(11),mo.created,120)) AS [Date],
			COUNT(*) AS [MO] 
	FROM	txnSMSDeliver mo WITH (NOLOCK), account ac WITH (NOLOCK)
	WHERE	(mo.created >= DATEADD(DAY,-31,dbo.fnStartOfDay(0)) AND mo.created < dbo.fnStartOfDay(0))
	AND		esmClass NOT IN (4,8)
	AND		ac.accountID = mo.accountID
	GROUP	BY mo.accountID, CONVERT(VARCHAR(11),mo.created,120)
) AS SourceTable PIVOT (
	AVG([MO]) FOR [Date] IN (
		' + @cols + '
	)
) AS PivotTable
ORDER BY [account]'

execute(@query)

END





GO
/****** Object:  StoredProcedure [dbo].[reportAccountMT]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[reportAccountMT]
AS
BEGIN

DECLARE @cols AS NVARCHAR(MAX),
		@query AS NVARCHAR(MAX)

SELECT @cols = STUFF((
	SELECT ',' + QUOTENAME(CONVERT(VARCHAR(10),RetVal,120)) FROM dbo.CreateDateRange(DATEADD(DAY,-31,dbo.fnStartOfDay(0)), dbo.fnStartOfDay(1), 'DD', 1)
	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,''
)

SET @query =   'SELECT	*
FROM (
	SELECT	MAX([account]) AS [account],
			MAX([date]) AS [date],
			SUM([MT]) AS [mt]
	FROM (
		SELECT	MAX(ac.name) AS [account],
				MAX(CONVERT(VARCHAR(11),mt.created,120)) AS [date],
				COUNT(*) AS [MT] 
		FROM	txnSMSSubmit mt WITH (NOLOCK), account ac WITH (NOLOCK)
		WHERE	(mt.created >= DATEADD(DAY,-31,dbo.fnStartOfDay(0)) AND mt.created < dbo.fnStartOfDay(0))
		AND		ac.accountID = mt.accountID
		GROUP	BY mt.accountID, CONVERT(VARCHAR(11),mt.created,120)
		UNION ALL
		SELECT	MAX(ac.name) AS [account],
				MAX(CONVERT(VARCHAR(11),mt.auditSubmit,120)) AS [date],
				COUNT(*) AS [MT] 
		FROM	SMSMTsubmit mt WITH (NOLOCK), account ac WITH (NOLOCK)
		WHERE	(mt.auditSubmit >= DATEADD(DAY,-31,dbo.fnStartOfDay(0)) AND mt.auditSubmit < dbo.fnStartOfDay(0))
		AND		ac.accountID = mt.accountID
		GROUP	BY mt.accountID, CONVERT(VARCHAR(11),mt.auditSubmit,120)
	) mt
	GROUP BY [account],[date]
) AS SourceTable PIVOT (
	AVG([MT]) FOR [Date] IN (
		' + @cols + '
	)
) AS PivotTable
ORDER BY [account]'

execute(@query)

END




GO
/****** Object:  StoredProcedure [dbo].[republishCode]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[republishCode]
	@code varchar(15)
WITH EXECUTE AS 'dbo' 
AS
BEGIN

	DECLARE @codeID INT;
	DECLARE @inConnection INT = 0;
	DECLARE @publishStatus INT = 0;
	DECLARE @errorMessage VARCHAR(255);

	SET NOCOUNT ON;

	BEGIN TRY

		SET @codeID = (SELECT codeID FROM code WHERE code = @code);
		SET @inConnection = (SELECT COUNT(*) FROM connectionCodeAssign WHERE codeID = @codeID);
		SET @publishStatus = (SELECT publishStatus FROM code WHERE codeID = @codeID);

		PRINT 'In Connection: ' + CAST(@inConnection AS VARCHAR(5));
		PRINT 'Published Status: ' + CAST(@publishStatus AS VARCHAR(5));

		IF (@inConnection > 0) AND (@publishStatus = 1) 
		BEGIN
			UPDATE code SET publishUpdate=3 WHERE codeID = @codeID;
			SELECT 'Success' AS [result], @code AS [code];
		END
		ELSE
		BEGIN
			SELECT 'Failed' AS [result], @code AS [code];
		END

	END TRY
	BEGIN CATCH

		SET @errorMessage = (SELECT LEFT(ERROR_MESSAGE(), 255) AS ErrorMessage);
		PRINT @errorMessage;

		SELECT 'Failed' AS [result], @code AS [code];
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[testprocedure]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[testprocedure] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @checkRecord INT

    set @checkRecord = (select count(*) from accountRegistration where accountRegistrationID = 500)

	if @checkRecord = 0
    begin
    raiserror('Registration Record does not exist, is not approved, or is already provisioned!', 18, 1)
    return -1
    end

END





GO
/****** Object:  StoredProcedure [dbo].[txnPurgeStateFarm]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[txnPurgeStateFarm]
AS
BEGIN

	DECLARE @crlf varchar(2) = Char(13) + Char(10);
	DECLARE @SMSDeliver INT = 0, @SMSSubmit INT = 0, @MMSDeliver INT = 0, @MMSSubmit INT = 0;
	DECLARE @PurgeResult VARCHAR(MAX) = '';
	DECLARE @PurgeStart DATETIME = DATEADD (DAY,-31,GETUTCDATE());
	DECLARE @PurgeEnd DATETIME = DATEADD (DAY,-30,GETUTCDATE());

	UPDATE txnSMSDeliver SET 
		sourceNumber = REPLACE(sourceNumber,SUBSTRING(sourceNumber, 5, 7),'9999999'), sourceNumberNXX = '999',
		messageText = 'PURGED',
		messageData = 0,
		messagePDU = 'PURGED'
	WHERE accountID IN (3,124,125)
	AND created BETWEEN @PurgeStart AND @PurgeEnd;

	SET @SMSDeliver = @SMSDeliver + @@ROWCOUNT;

	UPDATE txnSMSSubmit SET 
		destinationNumber = REPLACE(destinationNumber,SUBSTRING(destinationNumber, 5, 7),'9999999'), destinationNumberNXX = '999',
		messageText = 'PURGED',
		messageData = 0,
		messagePDU = 'PURGED'
	WHERE accountID IN (3,124,125)
	AND created BETWEEN @PurgeStart AND @PurgeEnd;

	SET @SMSSubmit = @SMSSubmit + @@ROWCOUNT;

	UPDATE txnMMSDeliver SET 
		sourceNumber = REPLACE(sourceNumber,SUBSTRING(sourceNumber, 5, 7),'9999999'), sourceNumberNXX = '999',
		messageText = 'PURGED',
		messageData = 0,
		messagePDU = 'PURGED',
		attachments = '[{"status":"PURGED"}]'
	WHERE accountID IN (3,124,125)
	AND created BETWEEN @PurgeStart AND @PurgeEnd;

	SET @MMSDeliver = @MMSDeliver + @@ROWCOUNT;

	UPDATE txnMMSSubmit SET 
		destinationNumber = REPLACE(destinationNumber,SUBSTRING(destinationNumber, 5, 7),'9999999'), destinationNumberNXX = '999',
		messageText = 'PURGED',
		messageData = 0,
		messagePDU = 'PURGED',
		mmsURL = 'PURGED'
	WHERE accountID IN (3,124,125)
	AND created BETWEEN @PurgeStart AND @PurgeEnd;

	SET @MMSSubmit = @MMSSubmit + @@ROWCOUNT;

	UPDATE SMSMTsubmit SET 
		destinationNumber = REPLACE(destinationNumber,SUBSTRING(destinationNumber, 5, 7),'9999999'), 
		messageText = 'PURGED',
		messageData = 0
	WHERE accountID IN (3,124,125)
	AND auditSubmit BETWEEN @PurgeStart AND @PurgeEnd;

	SET @SMSSubmit = @SMSSubmit + @@ROWCOUNT;

	SET @PurgeResult = 'Purge process completed ' + CAST(GETUTCDATE() AS VARCHAR) + @crlf + 'Range: ' + @PurgeStart + ' through ' + @PurgeEnd + @crlf + '    SMSDeliver: ' + @SMSDeliver + '    SMSSubmit: ' + @SMSSubmit + '    MMSDeliver: ' + @MMSDeliver + '    MMSSubmit: ' + @MMSSubmit
	PRINT @PurgeResult

END
GO
/****** Object:  StoredProcedure [dbo].[txnVoiceOrigInsert]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[txnVoiceOrigInsert]
	@providerID					INT,
	@sipServer					VARCHAR(50),
	@cdrGUID					VARCHAR(36),
	@sourceNumber				VARCHAR(15),
	@sourceIPAddress			VARCHAR(20),
	@destinationCode			VARCHAR(15),
	@providerName				VARCHAR(50),
	@created					DATETIME,
	@completed					DATETIME,
	@duration					INT,
	@terminationCauseID			INT,
	@terminationCauseMessage	VARCHAR(250),
	@forwardType				VARCHAR(15)
AS	 
BEGIN 

-- Using NOCOUNT to reduce traffic and load on the system.
SET NOCOUNT ON 

INSERT	INTO dbo.txnVoiceOrig (
		[accountID],
		[connectionID],
		[providerID],
		[sipServer],
		[cdrGUID],
		[sourceNumber],
		[sourceNumberCountryCode],
		[sourceNumberNPA],
		[sourceNumberNXX],
		[sourceIPAddress],
		[destinationCode],
		[destinationCountryCode],
		[destinationCodeNPA],
		[destinationCodeNXX],
		[providerName],
		[created],
		[completed],
		[duration],
		[terminationCauseID],
		[terminationCauseMessage],
		[forwardType],
		[archived]
) 
SELECT	ISNULL(cn.accountID, 0) AS [accountID],
		ISNULL(cn.connectionID, 0) AS [connectionID],
		@providerID AS [providerID],
		@sipServer AS [sipServer],
		@cdrGUID AS [cdrGUID],
		@sourceNumber AS [sourceNumber],
		(SELECT TOP 1 countryCode FROM numberCountry WHERE LEFT(@sourceNumber, LEN(countryCode)) = CAST(countryCode AS VARCHAR(5))) AS [sourceNumberCountryCode],
		CASE 
			WHEN LEFT(@sourceNumber,1) = '1' THEN SUBSTRING(@sourceNumber,2,3) 
			ELSE NULL
		END AS [sourceNumberNPA],
		CASE 
			WHEN LEFT(@sourceNumber,1) = '1' THEN SUBSTRING(@sourceNumber,5,3) 
			ELSE NULL
		END AS [sourceNumberNXX],
		@sourceIPAddress AS [sourceIPAddress],
		@destinationCode AS [destinationCode],
		(SELECT countryCode FROM numberCountry WHERE LEFT(@destinationCode, LEN(countryCode)) = countryCode) AS [destinationCountryCode],
		CASE 
			WHEN LEFT(@destinationCode,1) = '1' THEN SUBSTRING(@destinationCode,2,3) 
			ELSE NULL
		END AS [destinationCodeNPA],
		CASE 
			WHEN LEFT(@destinationCode,1) = '1' THEN SUBSTRING(@destinationCode,5,3) 
			ELSE NULL
		END AS [destinationCodeNXX],
		@providerName AS [providerName],
		@created AS [created],
		@completed AS [completed],
		@duration AS [duration],
		@terminationCauseID AS [terminationCauseID],
		@terminationCauseMessage AS [terminationCauseMessage],
		@forwardType AS [forwardType],
		0 AS [archived]
FROM	dbo.code cd WITH (NOLOCK)
		LEFT JOIN dbo.connectionCodeAssign cna WITH (NOLOCK)
			ON cd.codeID = cna.codeID
		LEFT JOIN dbo.connection cn WITH (NOLOCK)
			ON cna.connectionID = cn.connectionID
WHERE	cd.code = @destinationCode

END 












GO
/****** Object:  StoredProcedure [dbo].[txnVoiceTermInsert]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[txnVoiceTermInsert]
	@providerID					INT,
	@sipServer					VARCHAR(50),
	@cdrGUID					VARCHAR(36),
	@sourceCode					VARCHAR(15),
	@sourceIPAddress			VARCHAR(20),
	@destinationIPAddress		VARCHAR(20),
	@destinationNumber			VARCHAR(15),
	@providerName				VARCHAR(50),
	@created					DATETIME,
	@completed					DATETIME,
	@duration					INT,
	@terminationCauseID			INT,
	@terminationCauseMessage	VARCHAR(250),
	@forwardType				VARCHAR(15)
AS	 
BEGIN 

-- Using NOCOUNT to reduce traffic and load on the system.
SET NOCOUNT ON 

INSERT	INTO dbo.txnVoiceTerm (
		[accountID],
		[connectionID],
		[providerID],
		[sipServer],
		[cdrGUID],
		[sourceCode],
		[sourceCountryCode],
		[sourceCodeNPA],
		[sourceCodeNXX],
		[sourceIPAddress],
		[destinationIPAddress],
		[destinationNumber],
		[destinationCountryCode],
		[destinationNumberNPA],
		[destinationNumberNXX],
		[providerName],
		[created],
		[completed],
		[duration],
		[terminationCauseID],
		[terminationCauseMessage],
		[forwardType],
		[archived]
) 
SELECT	ISNULL(cn.accountID, 0) AS [accountID],
		ISNULL(cn.connectionID, 0) AS [connectionID],
		@providerID AS [providerID],
		@sipServer AS [sipServer],
		@cdrGUID AS [cdrGUID],
		@sourceCode AS [sourceCode],
		(SELECT TOP 1 countryCode FROM numberCountry WHERE LEFT(@sourceCode, LEN(countryCode)) = CAST(countryCode AS VARCHAR(5))) AS [sourceNumberCountryCode],
		CASE 
			WHEN LEFT(@sourceCode,1) = '1' THEN SUBSTRING(@sourceCode,2,3) 
			ELSE NULL
		END AS [sourceNumberNPA],
		CASE 
			WHEN LEFT(@sourceCode,1) = '1' THEN SUBSTRING(@sourceCode,5,3) 
			ELSE NULL
		END AS [sourceNumberNXX],
		@sourceIPAddress AS [sourceIPAddress],
		@destinationIPAddress AS [destinationIPAddress],
		@destinationNumber AS [destinationCode],
		(SELECT countryCode FROM numberCountry WHERE LEFT(@destinationNumber, LEN(countryCode)) = countryCode) AS [destinationCountryCode],
		CASE 
			WHEN LEFT(@destinationNumber,1) = '1' THEN SUBSTRING(@destinationNumber,2,3) 
			ELSE NULL
		END AS [destinationCodeNPA],
		CASE 
			WHEN LEFT(@destinationNumber,1) = '1' THEN SUBSTRING(@destinationNumber,5,3) 
			ELSE NULL
		END AS [destinationCodeNXX],
		@providerName AS [providerName],
		@created AS [created],
		@completed AS [completed],
		@duration AS [duration],
		@terminationCauseID AS [terminationCauseID],
		@terminationCauseMessage AS [terminationCauseMessage],
		@forwardType AS [forwardType],
		0 AS [archived]
FROM	dbo.code cd WITH (NOLOCK)
		LEFT JOIN dbo.connectionCodeAssign cna WITH (NOLOCK)
			ON cd.codeID = cna.codeID
		LEFT JOIN dbo.connection cn WITH (NOLOCK)
			ON cna.connectionID = cn.connectionID
WHERE	cd.code = @sourceCode

END 














GO
/****** Object:  StoredProcedure [dbo].[unPublishInactiveCodes]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[unPublishInactiveCodes]
AS	 
BEGIN 
	-- Using NOCOUNT to reduce traffic and load on the system.
	SET NOCOUNT ON 

	DECLARE @codeList AS CURSOR;
	DECLARE @code AS VARCHAR(50);
	DECLARE @codeID AS INT;
	DECLARE	@espid AS VARCHAR(10);
	DECLARE @count AS INT;

	SET @count = 0;
	
	SET @codeList = CURSOR FOR
		SELECT	c.codeID, 
				c.code, 
				c.espid
		FROM	connectionCodeAssignHistory ch1 
		JOIN	code c
			ON	c.codeID = ch1.codeID
		LEFT JOIN	connectionCodeAssignHistory ch2 
			ON	ch2.codeID = ch1.codeID
				AND ch2.created > ch1.created
		LEFT JOIN	connectionCodeAssign ca
			ON	c.codeID = ca.codeID
		LEFT JOIN	connection cn
			ON ca.connectionID = cn.connectionID
		WHERE	ch2.codeID IS NULL
		AND		c.publishStatus = 1
		AND		c.espid NOT IN ('E0B2','E0B3')
		AND		cn.connectionID IS NULL
		AND		ch1.created <= DATEADD(HOUR,-12,GETUTCDATE())


	FETCH NEXT FROM @codeList INTO @codeID, @code, @espid

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @count = @count + 1;

		PRINT 'codeID: '+CAST(@codeID AS CHAR(5)) + ', code: ' + @code + ', espid: ' + @espid;

		FETCH NEXT FROM @codeList INTO @codeID, @code, @espid
	END

	PRINT CAST(@count AS CHAR(5)) + ' records affected';

	CLOSE @codeList;

END 



GO
/****** Object:  StoredProcedure [dbo].[usp_AccountMigration]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AccountMigration]
(
	@AccountId VARCHAR(200)
)
AS
BEGIN
	SET NOCOUNT ON;
	DROP TABLE IF EXISTS #tbl_AccountId, #tbl_ConnectionId;

	-- Get AccountId
	SELECT AccountId INTO #tbl_AccountId
	FROM [DBv4].[gateway].[dbo].[account] 
	WHERE (AccountId IN (SELECT ID FROM CSVToTable(@AccountId)) OR AccountParentId IN (SELECT ID FROM CSVToTable(@AccountId)));

	-- Get ConnectionId
	SELECT ac.AccountId,co.connectionId INTO #tbl_ConnectionId
	FROM [DBv4].[gateway].[dbo].[connection] co (NOLOCK) 
	INNER JOIN #tbl_AccountId ac (NOLOCK) ON ac.accountID=co.accountID;
	
	
	-- Account
	BEGIN TRY
		DROP TABLE IF EXISTS #tbl_AccountData;
		SELECT [accountID], [accountGUID], [accountParentID], [accountRegistrationID], [name], [billingType], [email], [phone1], [phone1isMobile], [phone2], [phone2isMobile], [address1], [address2], [city], [state], [zip], [country], [website], [replyAbout], [replyHelp], [replyStop], [active], [created], [lastUpdated], NULL AS [defaultConnectionID], [isReseller], [brandRelationship], [cspID], [cspEmail], 10 AS [maxConnectionsOverride], NULL AS [deactivatedDate] 
		INTO #tbl_AccountData FROM [DBv4].[gateway].[dbo].[account] WITH(NOLOCK) WHERE [accountID] IN (SELECT AccountId FROM #tbl_AccountId);

		SET IDENTITY_INSERT [account] ON
			INSERT INTO [account]([accountID], [accountGUID], [accountParentID], [accountRegistrationID],  [name], [billingType], [email], [phone1], [phone1isMobile], [phone2], [phone2isMobile], [address1], [address2], [city], [state], [zip], [country], [website], [replyAbout], [replyHelp], [replyStop],  [active], [created], [lastUpdated], [defaultConnectionID], [IsReseller], [brandRelationship], [cspID], [cspEmail], [maxConnectionsOverride], [deactivatedDate] )
			SELECT [accountID], [accountGUID], 1 AS [accountParentID], [accountRegistrationID], [name], [billingType], [email], [phone1], [phone1isMobile], [phone2], [phone2isMobile], [address1], [address2], [city], [state], [zip], [country], [website], [replyAbout], [replyHelp], [replyStop], [active], [created], [lastUpdated], NULL AS [defaultConnectionID], [isReseller], [brandRelationship], [cspID], [cspEmail], 10 AS [maxConnectionsOverride], NULL AS [deactivatedDate] 
			FROM [#tbl_AccountData] WHERE AccountParentId=0
			UNION 
			SELECT [accountID], [accountGUID], [accountParentID], [accountRegistrationID], RTRIM(LTRIM(REPLACE(SUBSTRING([name], CHARINDEX('-', [name]), LEN([name])+1), '-', ''))) AS [name], [billingType], [email], [phone1], [phone1isMobile], [phone2], [phone2isMobile], [address1], [address2], [city], [state], [zip], [country], [website], [replyAbout], [replyHelp], [replyStop], [active], [created], [lastUpdated], NULL AS [defaultConnectionID], [isReseller], [brandRelationship], [cspID], [cspEmail], 10 AS [maxConnectionsOverride], NULL AS [deactivatedDate] 
			FROM [#tbl_AccountData] WHERE AccountParentId!=0
		SET IDENTITY_INSERT [account] OFF;
		
		PRINT 'Account Done';

		--AccountUser
		SET IDENTITY_INSERT [accountUser] ON
			INSERT INTO [accountUser]([accountUserID], [accountUserGUID], [accountID], [firstName], [lastName], [email], [phone1], [phone2], [phone1isMobile], [phone2isMobile], [active], [created], [lastUpdated], [tosAccepted], [address1], [address2], [city], [state], [zip], [country], [portalSettings])
			SELECT [accountUserID], [accountUserGUID], [accountID], [firstName], [lastName], [email], [phone1], [phone2], [phone1isMobile], [phone2isMobile], [active], [created], [lastUpdated], NULL AS [tosAccepted], NULL AS [address1], NULL AS [address2], NULL AS [city], NULL AS [state], NULL AS [zip], NULL AS [country], NULL AS [portalSettings]
			FROM [DBv4].[gateway].[dbo].[accountUser] WITH(NOLOCK) WHERE [accountID] IN (SELECT AccountId FROM #tbl_AccountId)
		SET IDENTITY_INSERT [accountUser] OFF;

		PRINT 'AccountUser Done';
		
		--Code
		SET IDENTITY_INSERT [code] ON					   
			INSERT INTO [code]([codeID], [codeGUID], [codeTypeID], [itemCode], [shared], [code], [ton], [npi], [name], [emailAddress], [emailDomain], [emailTemplateID], [number], [codeRegistrationID], [espid], [netNumberID], [providerID], [voice], [voiceForwardTypeID], [voiceForwardDestination], [publishStatus], [publishUpdate], [notePrivate], [replyHelp], [replyStop], [available], [surcharge], [active], [deactivated], [created], [lastUpdated], [audit], [campaignID], [mnoStatus], [mnoIsPool])
			SELECT [codeID], [codeGUID], [codeTypeID], [itemCode], [shared], [code], [ton], [npi], [name], [emailAddress], [emailDomain], [emailTemplateID], [number], [codeRegistrationID], [espid], [netNumberID], [providerID], [voice], [voiceForwardTypeID], [voiceForwardDestination], [publishStatus], [publishUpdate], [notePrivate], [replyHelp], [replyStop], [available], [surcharge], [active], [deactivated], [created], [lastUpdated], [audit], [campaignID], [mnoStatus], [mnoIsPool]
			FROM [DBv4].[gateway].[dbo].[code] WITH(NOLOCK) WHERE codeID IN ( SELECT codeID FROM [DBv4].[gateway].[dbo].[connectionCodeAssign] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId WITH(NOLOCK) ) )
			OPTION (MAXDOP 3)
		SET IDENTITY_INSERT [code] OFF;

		PRINT 'Code Done';
		
		--blockCodeNumber
		SET IDENTITY_INSERT [blockCodeNumber] ON
			INSERT INTO [blockCodeNumber] ([blockCodeNumberID], [blockCodeNumberGUID], [blockCodeNumberType], [code], [number], [action], [actionOrigin], [note], [created], [lastUpdated], [messageGUID] )
			SELECT [blockCodeNumberID], [blockCodeNumberGUID], [blockCodeNumberType], [code], [number], [action], [actionOrigin], [note], [created], [lastUpdated], [transactionGUID] 
			FROM [DBv4].[gateway].[dbo].[blockCodeNumber] WITH(NOLOCK) WHERE code IN ( SELECT code FROM [DBv4].[gateway].[dbo].[code] WITH(NOLOCK) WHERE codeID IN ( SELECT codeID FROM [DBv4].[gateway].[dbo].[connectionCodeAssign] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId WITH(NOLOCK)) ) ) 
			--ORDER BY [blockCodeNumberID]
			OPTION (MAXDOP 3)
		SET IDENTITY_INSERT [blockCodeNumber] OFF;
		
		PRINT 'BlockCodeNumber Done';

		--cacheConnectionCodeAssign
		SET IDENTITY_INSERT [cacheConnectionCodeAssign] ON
			INSERT INTO [cacheConnectionCodeAssign]([cacheConnectionCodeAssignID], [code], [connectionID], [cacheStatus], [created])
			SELECT [cacheConnectionCodeAssignID], [code], [connectionID], [cacheStatus], [created] 
			FROM [DBv4].[gateway].[dbo].[cacheConnectionCodeAssign] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId) 
		SET IDENTITY_INSERT [cacheConnectionCodeAssign] OFF;
		
		PRINT 'CacheConnectionCodeAssign Done'
		
		--CodeRegistration
		SET IDENTITY_INSERT [codeRegistration] ON
			INSERT INTO [codeRegistration]([codeRegistrationID], [codeRegistrationGUID], [codeTypeID], [code], [ton], [npi], [connectionID], [name], [codeSourceID], [assigneeName], [assigneeAddress1], [assigneeAddress2], [assigneeCity], [assigneeState], [assigneeZip], [documentURL], [notePublic], [notePrivate], [status], [created], [verified], [completed], [lastUpdated], [termsAccept])
			SELECT [codeRegistrationID], [codeRegistrationGUID], [codeTypeID], [code], [ton], [npi], [connectionID], [name], [codeSourceID], [assigneeName], [assigneeAddress1], [assigneeAddress2], [assigneeCity], [assigneeState], [assigneeZip], [documentURL], [notePublic], [notePrivate], [status], [created], [verified], [completed], [lastUpdated], [termsAccept] 
			FROM [DBv4].[gateway].[dbo].[codeRegistration] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId)  
		SET IDENTITY_INSERT [codeRegistration] OFF;
		
		PRINT 'CodeRegistration Done'

		--Connection
		SET IDENTITY_INSERT [connection] ON
			INSERT INTO [connection]([connectionID], [connectionGUID], [accountID], [name], [codeDistributionMethodID], [defaultCodeID], [destinationNumberFormat], [enforceOptOut], [disableInNetworkRouting], [messageExpirationHours], [segmentedMessageOption], [replyHelp], [replyStop], [registeredDeliveryDisable], [active], [created], [lastUpdated], [enableInboundSC],[utf16HttpStrip], [spamFilterMO], [spamFilterMT], [s3Bucket], [s3ApiKey], [s3ApiSecret], [s3Params], [spamOfflineMO], [spamOfflineMT], [moHttpTlvs] )
			SELECT [connectionID], [connectionGUID], [accountID], [name], [codeDistributionMethodID], [defaultCodeID], [destinationNumberFormat], [enforceOptOut], [disableInNetworkRouting], [messageExpirationHours], [segmentedMessageOption], [replyHelp], [replyStop], [registeredDeliveryDisable], [active], [created], [lastUpdated], [enableInboundSC],0 AS [utf16HttpStrip], [spamFilterMO], [spamFilterMT], [s3Bucket], [s3ApiKey], [s3ApiSecret], [s3Params], [spamOfflineMO], [spamOfflineMT], [moHttpTlvs] 
			FROM [DBv4].[gateway].[dbo].[connection] WITH(NOLOCK) WHERE [accountID] IN (SELECT AccountID FROM #tbl_AccountId)
		SET IDENTITY_INSERT [connection] OFF;
		
		PRINT 'Connection Done'

		--connectionCodeAssign
		INSERT INTO [connectionCodeAssign]([connectionID], [codeID], [default], [created], [created2], [lastUpdated] )
		SELECT [connectionID], [codeID], [default], [created], [created2], [lastUpdated] 
		FROM [DBv4].[gateway].[dbo].[connectionCodeAssign] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId);

		PRINT 'ConnectionCodeAssign Done'

		--credential
		SET IDENTITY_INSERT [credential] ON
			INSERT INTO [credential]([credentialID], [credentialGUID], [connectionID], [name], [apiKey], [apiSecret], [systemID], [password], [firewallRequired], [active], [created], [lastUpdated] )
			SELECT [credentialID], [credentialGUID], [connectionID], [name], [apiKey], [apiSecret], [systemID], [password], [firewallRequired], [active], [created], [lastUpdated] 
			FROM [DBv4].[gateway].[dbo].[credential] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId) 
		SET IDENTITY_INSERT [credential] OFF;
		
		PRINT 'Credential Done'

		--firewall
		SET IDENTITY_INSERT [firewall] ON
			INSERT INTO [firewall]([firewallID], [firewallGUID], [accountID], [connectionID], [name], [ipAddress], [ipSubnet], [active], [created], [lastUpdated] )
			SELECT [firewallID], [firewallGUID], [accountID], [connectionID], [name], [ipAddress], [ipSubnet], [active], [created], [lastUpdated] 
			FROM [DBv4].[gateway].[dbo].[firewall] WITH(NOLOCK) WHERE [accountID] IN (SELECT AccountID FROM #tbl_AccountId) 
		SET IDENTITY_INSERT [firewall] OFF;
		
		PRINT 'Firewall Done'

		--keyword
		SET IDENTITY_INSERT [keyword] ON
			INSERT INTO [keyword]([keywordID], [keywordGUID], [connectionID], [codeID], [keyword], [keywordReply], [created], [lastUpdated], [active])
			SELECT [keywordID], [keywordGUID], [connectionID], [codeID], [keyword], [keywordReply], [created], [lastUpdated], 0 AS [active] 
			FROM [DBv4].[gateway].[dbo].[keyword] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId) 
		SET IDENTITY_INSERT [keyword] OFF;
		
		PRINT 'Keyword Done'
		
		-- route 
		SET IDENTITY_INSERT [route] ON						
			INSERT INTO [route]([routeID], [routeGUID], [accountID], [connectionID], [acceptDeny], [sourceCodeCompare], [destinationCodeCompare], [messageDataCompare], [numberOperatorID], [routeSequence], [created], [lastUpdated] )
			SELECT [routeID], [routeGUID], [accountID], [connectionID], [acceptDeny], [sourceCodeCompare], [destinationCodeCompare], [messageDataCompare], [numberOperatorID], [routeSequence], [created], [lastUpdated] 
			FROM [DBv4].[gateway].[dbo].[route] WITH(NOLOCK) WHERE [accountID] IN (SELECT AccountID FROM #tbl_AccountId) 
		SET IDENTITY_INSERT [route] OFF;
		
		PRINT 'Route Done'

		-- routeAction 
		SET IDENTITY_INSERT [routeAction] ON						  
			INSERT INTO [routeAction]([routeActionID], [routeActionGUID], [routeID], [routeActionTypeID], [routeActionValue], [active], [created], [lastUpdated], [routeActionSequence] )
			SELECT [routeActionID], [routeActionGUID], [routeID], [routeActionTypeID], [routeActionValue], [active], [created], [lastUpdated], [routeActionSequence] 
			FROM [DBv4].[gateway].[dbo].[routeAction] WITH(NOLOCK) WHERE routeID IN (SELECT routeID FROM [DBv4].[gateway].[dbo].[route] WITH(NOLOCK) WHERE [accountID] IN (SELECT AccountID FROM #tbl_AccountId) ) 
		SET IDENTITY_INSERT [routeAction] OFF;
		
		PRINT 'RouteAction Done'

		-- routeConnection 
		SET IDENTITY_INSERT [routeConnection] ON								  
			INSERT INTO [routeConnection]([routeConnectionID], [routeConnectionGUID], [accountID], [name], [protocol], [method], [host], [port], [path], [queryString], [userName], [password], [created],  [lastUpdated], [active] )
			SELECT [routeConnectionID], [routeConnectionGUID], [accountID], [name], [protocol], [method], [host], [port], [path], [queryString], [userName], [password], [created],  [lastUpdated], [active] 
			FROM [DBv4].[gateway].[dbo].[routeConnection] WITH(NOLOCK) WHERE [accountID] IN (SELECT AccountID FROM #tbl_AccountId)
		SET IDENTITY_INSERT [routeConnection] OFF;
		
		PRINT 'RouteConnection Done'

		-- xTempBulkAction
		INSERT INTO [xTempBulkAction]([code], [codeRegistrationID], [connectionID])
		SELECT [code], [codeRegistrationID], [connectionID] 
		FROM [DBv4].[gateway].[dbo].[xTempBulkAction] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId) ;
		
		PRINT 'xTempBulkAction Done'
		
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[usp_codeMigration]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_codeMigration]
(
	@AccountId VARCHAR(200)
)
AS
BEGIN
	SET NOCOUNT ON;
	DROP TABLE IF EXISTS #tbl_AccountId, #tbl_ConnectionId;

	-- Get AccountId
	SELECT AccountId INTO #tbl_AccountId
	FROM [DBv4].[gateway].[dbo].[account] 
	WHERE (AccountId IN (SELECT ID FROM CSVToTable(@AccountId)) OR AccountParentId IN (SELECT ID FROM CSVToTable(@AccountId)));

	-- Get ConnectionId
	SELECT ac.AccountId,co.connectionId INTO #tbl_ConnectionId
	FROM [DBv4].[gateway].[dbo].[connection] co (NOLOCK) 
	INNER JOIN #tbl_AccountId ac (NOLOCK) ON ac.accountID=co.accountID;
	
	BEGIN
		--Code
		SET IDENTITY_INSERT [code] ON					   
			INSERT INTO [code]([codeID], [codeGUID], [codeTypeID], [itemCode], [shared], [code], [ton], [npi], [name], [emailAddress], [emailDomain], [emailTemplateID], [number], [codeRegistrationID], [espid], [netNumberID], [providerID], [voice], [voiceForwardTypeID], [voiceForwardDestination], [publishStatus], [publishUpdate], [notePrivate], [replyHelp], [replyStop], [available], [surcharge], [active], [deactivated], [created], [lastUpdated], [audit], [campaignID], [mnoStatus], [mnoIsPool])
			SELECT [codeID], [codeGUID], [codeTypeID], [itemCode], [shared], [code], [ton], [npi], [name], [emailAddress], [emailDomain], [emailTemplateID], [number], [codeRegistrationID], [espid], [netNumberID], [providerID], [voice], [voiceForwardTypeID], [voiceForwardDestination], [publishStatus], [publishUpdate], [notePrivate], [replyHelp], [replyStop], [available], [surcharge], [active], [deactivated], [created], [lastUpdated], [audit], [campaignID], [mnoStatus], [mnoIsPool]
			FROM [DBv4].[gateway].[dbo].[code] WITH(NOLOCK) WHERE codeID IN ( SELECT codeID FROM [DBv4].[gateway].[dbo].[connectionCodeAssign] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId WITH(NOLOCK) ) )
			OPTION (MAXDOP 3)
		SET IDENTITY_INSERT [code] OFF;

		PRINT 'Code Table Done';
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_recordCountByAccountId]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_recordCountByAccountId]
(
	@AccountId VARCHAR(200)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @output NVARCHAR(MAX); 

	-- Get AccountId
	DROP TABLE IF EXISTS #tbl_AccountId, #tbl_ConnectionId;

	SELECT AccountId INTO #tbl_AccountId
	FROM [DBv4].[gateway].[dbo].[account] WITH(NOLOCK)
	WHERE (AccountId IN (SELECT ID FROM CSVToTable(@AccountId)) OR AccountParentId IN (SELECT ID FROM CSVToTable(@AccountId)));

	-- Get ConnectionId
	SELECT ac.AccountId,co.connectionId INTO #tbl_ConnectionId
	FROM [DBv4].[gateway].[dbo].[connection] co WITH(NOLOCK) 
	INNER JOIN #tbl_AccountId ac WITH(NOLOCK) ON ac.accountID=co.accountID;
	
	-- Get Record Count For V4 and V5 
	DECLARE @count_v4 INT, @count_v5 INT;

	SET @count_v5 = (SELECT COUNT(accountID) FROM account WITH(NOLOCK) WHERE accountID IN (SELECT accountID FROM #tbl_accountID));
	SET @count_v4 = (SELECT COUNT(AccountID) FROM [DBv4].[gateway].[dbo].[account] WITH(NOLOCK) WHERE AccountId IN (SELECT accountID FROM #tbl_accountID));

	PRINT 'account: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(accountUserID) FROM accountUser WITH(NOLOCK) WHERE accountID IN (SELECT accountID FROM #tbl_accountID));
	SET @count_v4 = (SELECT COUNT(accountUserID) FROM [DBv4].[gateway].[dbo].[accountUser] WITH(NOLOCK) WHERE AccountId IN (SELECT accountID FROM #tbl_accountID));

	PRINT 'accountUser: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(blockCodeNumberID) FROM [blockCodeNumber] WHERE code IN ( SELECT code FROM code WHERE codeID IN ( SELECT codeID FROM connectionCodeAssign WHERE connectionID IN (SELECT connectionID FROM connection WHERE accountID IN (SELECT accountID FROM #tbl_accountID)))));
	SET @count_v4 = (SELECT COUNT(blockCodeNumberID) FROM [DBv4].[gateway].[dbo].[blockCodeNumber] WHERE code IN ( SELECT code FROM [DBv4].[gateway].[dbo].[code] WITH(NOLOCK) WHERE codeID IN ( SELECT codeID FROM [DBv4].[gateway].[dbo].[connectionCodeAssign] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM [DBv4].[gateway].[dbo].[connection] WITH(NOLOCK) WHERE accountID IN (SELECT accountID FROM #tbl_accountID)))));

	PRINT 'blockCodeNumber:' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(CacheConnectionCodeAssignID) FROM CacheConnectionCodeAssign WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));
	SET @count_v4 = (SELECT COUNT(CacheConnectionCodeAssignID) FROM [DBv4].[gateway].[dbo].[CacheConnectionCodeAssign] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));

	PRINT 'CacheConnectionCodeAssign: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(CodeRegistrationID) FROM CodeRegistration WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));
	SET @count_v4 = (SELECT COUNT(CodeRegistrationID) FROM [DBv4].[gateway].[dbo].[CodeRegistration] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));

	PRINT 'CodeRegistration: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(ConnectionID) FROM Connection WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));
	SET @count_v4 = (SELECT COUNT(ConnectionID) FROM [DBv4].[gateway].[dbo].[Connection] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));

	PRINT 'Connection: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(ConnectionID) FROM ConnectionCodeAssign WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));
	SET @count_v4 = (SELECT COUNT(ConnectionID) FROM [DBv4].[gateway].[dbo].[ConnectionCodeAssign] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));

	PRINT 'ConnectionCodeAssign: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(CredentialID) FROM Credential WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));
	SET @count_v4 = (SELECT COUNT(CredentialID) FROM [DBv4].[gateway].[dbo].[Credential] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));

	PRINT 'Credential: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(FirewallID) FROM Firewall WITH(NOLOCK) WHERE AccountId IN (SELECT accountID FROM #tbl_accountID));
	SET @count_v4 = (SELECT COUNT(FirewallID) FROM [DBv4].[gateway].[dbo].[Firewall] WITH(NOLOCK) WHERE AccountId IN (SELECT accountID FROM #tbl_accountID));

	PRINT 'Firewall: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(KeywordID) FROM Keyword WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));
	SET @count_v4 = (SELECT COUNT(KeywordID) FROM [DBv4].[gateway].[dbo].[Keyword] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));

	PRINT 'Keyword: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(RouteID) FROM Route WITH(NOLOCK) WHERE AccountId IN (SELECT accountID FROM #tbl_accountID));
	SET @count_v4 = (SELECT COUNT(RouteID) FROM [DBv4].[gateway].[dbo].[Route] WITH(NOLOCK) WHERE AccountId IN (SELECT accountID FROM #tbl_accountID));

	PRINT 'Route: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(routeActionID) FROM [routeAction] WITH(NOLOCK) WHERE routeID IN (SELECT routeID FROM [route] WITH(NOLOCK) WHERE accountID IN (SELECT accountID FROM #tbl_accountID)));
	SET @count_v4 = (SELECT COUNT(routeActionID) FROM [DBv4].[gateway].[dbo].[routeAction] WITH(NOLOCK) WHERE routeID IN (SELECT routeID FROM [DBv4].[gateway].[dbo].[route] WITH(NOLOCK) WHERE accountID IN (SELECT accountID FROM #tbl_accountID)));
	PRINT 'routeAction: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(RouteConnectionID) FROM RouteConnection WITH(NOLOCK) WHERE AccountId IN (SELECT accountID FROM #tbl_accountID));
	SET @count_v4 = (SELECT COUNT(RouteConnectionID) FROM [DBv4].[gateway].[dbo].[RouteConnection] WITH(NOLOCK) WHERE AccountId IN (SELECT accountID FROM #tbl_accountID));

	PRINT 'RouteConnection: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

	SET @count_v5 = (SELECT COUNT(connectionID) FROM xTempBulkAction WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));
	SET @count_v4 = (SELECT COUNT(connectionID) FROM [DBv4].[gateway].[dbo].[xTempBulkAction] WITH(NOLOCK) WHERE connectionID IN (SELECT connectionID FROM #tbl_ConnectionId));

	PRINT 'xTempBulkAction: ' + CAST(@count_v4 AS VARCHAR(10))+' , '+CAST(@count_v5 AS VARCHAR(10));

END
GO
/****** Object:  Trigger [dbo].[TR_account_LastUpdated]    Script Date: 22/02/2024 00:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_account_LastUpdated]
ON [dbo].[account]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE Account
	SET lastUpdated = GETUTCDATE()
	FROM Account a
	INNER JOIN inserted i ON a.accountID = i.accountID;
END;

GO
ALTER TABLE [dbo].[account] DISABLE TRIGGER [TR_account_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_accountRegistration_LastUpdated]    Script Date: 22/02/2024 00:40:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_accountRegistration_LastUpdated]
ON [dbo].[accountRegistration]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE accountRegistration
	SET lastUpdated = GETUTCDATE()
	FROM accountRegistration a
	INNER JOIN inserted i ON a.accountRegistrationID = i.accountRegistrationID;
END;

GO
ALTER TABLE [dbo].[accountRegistration] DISABLE TRIGGER [TR_accountRegistration_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_accountUser_LastUpdated]    Script Date: 22/02/2024 00:40:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_accountUser_LastUpdated]
ON [dbo].[accountUser]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE accountUser
	SET lastUpdated = GETUTCDATE()
	FROM accountUser a
	INNER JOIN inserted i ON a.accountUserID = i.accountUserID;
END;

GO
ALTER TABLE [dbo].[accountUser] DISABLE TRIGGER [TR_accountUser_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_api_LastUpdated]    Script Date: 22/02/2024 00:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_api_LastUpdated]
ON [dbo].[api]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE api
	SET lastUpdated = GETUTCDATE()
	FROM api a
	INNER JOIN inserted i ON a.apiID = i.apiID;
END;

GO
ALTER TABLE [dbo].[api] DISABLE TRIGGER [TR_api_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_apiResource_LastUpdated]    Script Date: 22/02/2024 00:40:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_apiResource_LastUpdated]
ON [dbo].[apiResource]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE apiResource
	SET lastUpdated = GETUTCDATE()
	FROM apiResource a
	INNER JOIN inserted i ON a.apiResourceID = i.apiResourceID;
END;

ALTER TABLE [dbo].[apiResource] DISABLE TRIGGER [TR_apiResource_LastUpdated]

GO
ALTER TABLE [dbo].[apiResource] DISABLE TRIGGER [TR_apiResource_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_apiResourceParameter_LastUpdated]    Script Date: 22/02/2024 00:40:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_apiResourceParameter_LastUpdated]
ON [dbo].[apiResourceParameter]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE apiResourceParameter
	SET lastUpdated = GETUTCDATE()
	FROM apiResourceParameter a
	INNER JOIN inserted i ON a.apiResourceParameterID = i.apiResourceParameterID;
END;

ALTER TABLE [dbo].[apiResourceParameter] DISABLE TRIGGER [TR_apiResourceParameter_LastUpdated]
GO
ALTER TABLE [dbo].[apiResourceParameter] DISABLE TRIGGER [TR_apiResourceParameter_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_auditTrail_LastUpdated]    Script Date: 22/02/2024 00:40:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_auditTrail_LastUpdated]
ON [dbo].[auditTrail]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE auditTrail
	SET lastUpdated = GETUTCDATE()
	FROM auditTrail a
	INNER JOIN inserted i ON a.ID = i.ID;
END;

ALTER TABLE [dbo].[auditTrail] DISABLE TRIGGER [TR_auditTrail_LastUpdated]
GO
ALTER TABLE [dbo].[auditTrail] DISABLE TRIGGER [TR_auditTrail_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_authenticationFailure_LastUpdated]    Script Date: 22/02/2024 00:40:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_authenticationFailure_LastUpdated]
ON [dbo].[authenticationFailure]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE authenticationFailure
	SET lastUpdated = GETUTCDATE()
	FROM authenticationFailure a
	INNER JOIN inserted i ON a.authenticationFailureID = i.authenticationFailureID;
END;

ALTER TABLE [dbo].[authenticationFailure] DISABLE TRIGGER [TR_authenticationFailure_LastUpdated]
GO
ALTER TABLE [dbo].[authenticationFailure] DISABLE TRIGGER [TR_authenticationFailure_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_blockCodeNumber_LastUpdated]    Script Date: 22/02/2024 00:40:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_blockCodeNumber_LastUpdated]
ON [dbo].[blockCodeNumber]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE blockCodeNumber
	SET lastUpdated = GETUTCDATE()
	FROM blockCodeNumber a
	INNER JOIN inserted i ON a.blockCodeNumberID = i.blockCodeNumberID;
END;

ALTER TABLE [dbo].[blockCodeNumber] DISABLE TRIGGER [TR_blockCodeNumber_LastUpdated]
GO
ALTER TABLE [dbo].[blockCodeNumber] DISABLE TRIGGER [TR_blockCodeNumber_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_code_LastUpdated]    Script Date: 22/02/2024 00:40:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_code_LastUpdated]
ON [dbo].[code]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE Code
	SET lastUpdated = GETUTCDATE()
	FROM Code a
	INNER JOIN inserted i ON a.CodeID = i.CodeID;
END;

ALTER TABLE [dbo].[Code] DISABLE TRIGGER [TR_code_LastUpdated]
GO
ALTER TABLE [dbo].[code] DISABLE TRIGGER [TR_code_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_codeParameter_LastUpdated]    Script Date: 22/02/2024 00:40:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_codeParameter_LastUpdated]
ON [dbo].[codeParameter]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE codeParameter
	SET lastUpdated = GETUTCDATE()
	FROM codeParameter a
	INNER JOIN inserted i ON a.codeParameterID = i.codeParameterID;
END;

ALTER TABLE [dbo].[codeParameter] DISABLE TRIGGER [TR_codeParameter_LastUpdated]
GO
ALTER TABLE [dbo].[codeParameter] DISABLE TRIGGER [TR_codeParameter_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_codeRegistration_LastUpdated]    Script Date: 22/02/2024 00:40:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_codeRegistration_LastUpdated]
ON [dbo].[codeRegistration]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE codeRegistration
	SET lastUpdated = GETUTCDATE()
	FROM codeRegistration a
	INNER JOIN inserted i ON a.codeRegistrationID = i.codeRegistrationID;
END;

ALTER TABLE [dbo].[codeRegistration] DISABLE TRIGGER [TR_codeRegistration_LastUpdated]
GO
ALTER TABLE [dbo].[codeRegistration] DISABLE TRIGGER [TR_codeRegistration_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_codeRegistryParameterTSS_LastUpdated]    Script Date: 22/02/2024 00:40:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_codeRegistryParameterTSS_LastUpdated]
ON [dbo].[codeRegistryParameterTSS]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE codeRegistryParameterTSS
	SET lastUpdated = GETUTCDATE()
	FROM codeRegistryParameterTSS a
	INNER JOIN inserted i ON a.codeRegistryParameterTSSID = i.codeRegistryParameterTSSID;
END;

ALTER TABLE [dbo].[codeRegistryParameterTSS] DISABLE TRIGGER [TR_codeRegistryParameterTSS_LastUpdated]
GO
ALTER TABLE [dbo].[codeRegistryParameterTSS] DISABLE TRIGGER [TR_codeRegistryParameterTSS_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_connection_LastUpdated]    Script Date: 22/02/2024 00:40:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_connection_LastUpdated]
ON [dbo].[connection]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE connection
	SET lastUpdated = GETUTCDATE()
	FROM connection a
	INNER JOIN inserted i ON a.connectionID = i.connectionID;
END;

ALTER TABLE [dbo].[connection] DISABLE TRIGGER [TR_connection_LastUpdated]
GO
ALTER TABLE [dbo].[connection] DISABLE TRIGGER [TR_connection_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_connectionAuthorization_LastUpdated]    Script Date: 22/02/2024 00:40:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_connectionAuthorization_LastUpdated]
ON [dbo].[connectionAuthorization]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE connectionAuthorization
	SET lastUpdated = GETUTCDATE()
	FROM connectionAuthorization a
	INNER JOIN inserted i ON a.connectionAuthorizationID = i.connectionAuthorizationID;
END;

ALTER TABLE [dbo].[connectionAuthorization] DISABLE TRIGGER [TR_connectionAuthorization_LastUpdated]
GO
ALTER TABLE [dbo].[connectionAuthorization] DISABLE TRIGGER [TR_connectionAuthorization_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_connectionCodeAssign_LastUpdated]    Script Date: 22/02/2024 00:40:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_connectionCodeAssign_LastUpdated]
ON [dbo].[connectionCodeAssign]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE connectionCodeAssign
	SET lastUpdated = GETUTCDATE()
	FROM connectionCodeAssign a
	INNER JOIN inserted i ON a.connectionID = i.connectionID AND a.codeID=i.codeID;
END;

ALTER TABLE [dbo].[connectionCodeAssign] DISABLE TRIGGER [TR_connectionCodeAssign_LastUpdated]
GO
ALTER TABLE [dbo].[connectionCodeAssign] DISABLE TRIGGER [TR_connectionCodeAssign_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_connectionRole_LastUpdated]    Script Date: 22/02/2024 00:40:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_connectionRole_LastUpdated]
ON [dbo].[connectionRole]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE connectionRole
	SET lastUpdated = GETUTCDATE()
	FROM connectionRole a
	INNER JOIN inserted i ON a.connectionRoleID = i.connectionRoleID;
END;

ALTER TABLE [dbo].[connectionRole] DISABLE TRIGGER [TR_connectionRole_LastUpdated]
GO
ALTER TABLE [dbo].[connectionRole] DISABLE TRIGGER [TR_connectionRole_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_credential_LastUpdated]    Script Date: 22/02/2024 00:40:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_credential_LastUpdated]
ON [dbo].[credential]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE credential
	SET lastUpdated = GETUTCDATE()
	FROM credential a
	INNER JOIN inserted i ON a.credentialID = i.credentialID;
END;

ALTER TABLE [dbo].[credential] DISABLE TRIGGER [TR_credential_LastUpdated]
GO
ALTER TABLE [dbo].[credential] DISABLE TRIGGER [TR_credential_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_firewall_LastUpdated]    Script Date: 22/02/2024 00:40:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_firewall_LastUpdated]
ON [dbo].[firewall]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE firewall
	SET lastUpdated = GETUTCDATE()
	FROM firewall a
	INNER JOIN inserted i ON a.firewallID = i.firewallID;
END;

ALTER TABLE [dbo].[firewall] DISABLE TRIGGER [TR_firewall_LastUpdated]
GO
ALTER TABLE [dbo].[firewall] DISABLE TRIGGER [TR_firewall_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_item_LastUpdated]    Script Date: 22/02/2024 00:40:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_item_LastUpdated]
ON [dbo].[item]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE item
	SET lastUpdated = GETUTCDATE()
	FROM item a
	INNER JOIN inserted i ON a.itemCode = i.itemCode ;
END;

ALTER TABLE [dbo].[item] DISABLE TRIGGER [TR_item_LastUpdated]
GO
ALTER TABLE [dbo].[item] DISABLE TRIGGER [TR_item_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_keyword_LastUpdated]    Script Date: 22/02/2024 00:40:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_keyword_LastUpdated]
ON [dbo].[keyword]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE keyword
	SET lastUpdated = GETUTCDATE()
	FROM keyword a
	INNER JOIN inserted i ON a.keywordID = i.keywordID;
END;

ALTER TABLE [dbo].[keyword] DISABLE TRIGGER [TR_keyword_LastUpdated]
GO
ALTER TABLE [dbo].[keyword] DISABLE TRIGGER [TR_keyword_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_maintenanceSchedule_LastUpdated]    Script Date: 22/02/2024 00:40:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_maintenanceSchedule_LastUpdated]
ON [dbo].[maintenanceSchedule]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE maintenanceSchedule
	SET lastUpdated = GETUTCDATE()
	FROM maintenanceSchedule a
	INNER JOIN inserted i ON a.maintenanceScheduleID = i.maintenanceScheduleID;
END;

ALTER TABLE [dbo].[maintenanceSchedule] DISABLE TRIGGER [TR_maintenanceSchedule_LastUpdated]
GO
ALTER TABLE [dbo].[maintenanceSchedule] DISABLE TRIGGER [TR_maintenanceSchedule_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_message_LastUpdated]    Script Date: 22/02/2024 00:40:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_message_LastUpdated]
ON [dbo].[message]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE message
	SET lastUpdated = GETUTCDATE()
	FROM message a
	INNER JOIN inserted i ON a.messageID = i.messageID;
END;

ALTER TABLE [dbo].[message] DISABLE TRIGGER [TR_message_LastUpdated]
GO
ALTER TABLE [dbo].[message] DISABLE TRIGGER [TR_message_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_messageResult_LastUpdated]    Script Date: 22/02/2024 00:40:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_messageResult_LastUpdated]
ON [dbo].[messageResult]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE messageResult
	SET lastUpdated = GETUTCDATE()
	FROM messageResult a
	INNER JOIN inserted i ON a.messageResultID = i.messageResultID;
END;

ALTER TABLE [dbo].[messageResult] DISABLE TRIGGER [TR_messageResult_LastUpdated]
GO
ALTER TABLE [dbo].[messageResult] DISABLE TRIGGER [TR_messageResult_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_number_LastUpdated]    Script Date: 22/02/2024 00:40:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_number_LastUpdated]
ON [dbo].[number]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE number
	SET lastUpdated = GETUTCDATE()
	FROM number a
	INNER JOIN inserted i ON a.numberID = i.numberID;
END;

ALTER TABLE [dbo].[number] DISABLE TRIGGER [TR_number_LastUpdated]
GO
ALTER TABLE [dbo].[number] DISABLE TRIGGER [TR_number_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_numberCountryNPAOverride_LastUpdated]    Script Date: 22/02/2024 00:40:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_numberCountryNPAOverride_LastUpdated]
ON [dbo].[numberCountryNPAOverride]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE numberCountryNPAOverride
	SET lastUpdated = GETUTCDATE()
	FROM numberCountryNPAOverride a
	INNER JOIN inserted i ON a.numberCountryNPAOverrideID = i.numberCountryNPAOverrideID;
END;

ALTER TABLE [dbo].[numberCountryNPAOverride] DISABLE TRIGGER [TR_numberCountryNPAOverride_LastUpdated]
GO
ALTER TABLE [dbo].[numberCountryNPAOverride] DISABLE TRIGGER [TR_numberCountryNPAOverride_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_numberOperator_LastUpdated]    Script Date: 22/02/2024 00:40:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_numberOperator_LastUpdated]
ON [dbo].[numberOperator]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE numberOperator
	SET lastUpdated = GETUTCDATE()
	FROM numberOperator a
	INNER JOIN inserted i ON a.numberOperatorID = i.numberOperatorID;
END;

ALTER TABLE [dbo].[numberOperator] DISABLE TRIGGER [TR_numberOperator_LastUpdated]
GO
ALTER TABLE [dbo].[numberOperator] DISABLE TRIGGER [TR_numberOperator_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_numberOperatorNetNumber_LastUpdated]    Script Date: 22/02/2024 00:40:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_numberOperatorNetNumber_LastUpdated]
ON [dbo].[numberOperatorNetNumber]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE numberOperatorNetNumber
	SET lastUpdated = GETUTCDATE()
	FROM numberOperatorNetNumber a
	INNER JOIN inserted i ON a.numberOperatorID = i.numberOperatorID ;
END;

GO
ALTER TABLE [dbo].[numberOperatorNetNumber] DISABLE TRIGGER [TR_numberOperatorNetNumber_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_numberOperatorSyniverse_LastUpdated]    Script Date: 22/02/2024 00:40:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_numberOperatorSyniverse_LastUpdated]
ON [dbo].[numberOperatorSyniverse]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE numberOperatorSyniverse
	SET lastUpdated = GETUTCDATE()
	FROM numberOperatorSyniverse a
	INNER JOIN inserted i ON a.numberOperatorID = i.numberOperatorID ;
END;

GO
ALTER TABLE [dbo].[numberOperatorSyniverse] DISABLE TRIGGER [TR_numberOperatorSyniverse_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_partnerCampaign_LastUpdated]    Script Date: 22/02/2024 00:40:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_partnerCampaign_LastUpdated]
ON [dbo].[partnerCampaign]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE partnerCampaign
	SET lastUpdated = GETUTCDATE()
	FROM partnerCampaign a
	INNER JOIN inserted i ON a.partnerCampaignID = i.partnerCampaignID ;
END;

ALTER TABLE [dbo].[partnerCampaign] DISABLE TRIGGER [TR_partnerCampaign_LastUpdated]
GO
ALTER TABLE [dbo].[partnerCampaign] DISABLE TRIGGER [TR_partnerCampaign_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_partnerCampaignCode_LastUpdated]    Script Date: 22/02/2024 00:40:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_partnerCampaignCode_LastUpdated]
ON [dbo].[partnerCampaignCode]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE partnerCampaignCode
	SET lastUpdated = GETUTCDATE()
	FROM partnerCampaignCode a
	INNER JOIN inserted i ON a.partnerCampaignCodeID = i.partnerCampaignCodeID ;
END;

ALTER TABLE [dbo].[partnerCampaignCode] DISABLE TRIGGER [TR_partnerCampaignCode_LastUpdated]
GO
ALTER TABLE [dbo].[partnerCampaignCode] DISABLE TRIGGER [TR_partnerCampaignCode_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_partnerCampaignLog_LastUpdated]    Script Date: 22/02/2024 00:40:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_partnerCampaignLog_LastUpdated]
ON [dbo].[partnerCampaignLog]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE partnerCampaignLog
	SET lastUpdated = GETUTCDATE()
	FROM partnerCampaignLog a
	INNER JOIN inserted i ON a.partnerCampaignLogID = i.partnerCampaignLogID ;
END;

ALTER TABLE [dbo].[partnerCampaignLog] DISABLE TRIGGER [TR_partnerCampaignLog_LastUpdated]
GO
ALTER TABLE [dbo].[partnerCampaignLog] DISABLE TRIGGER [TR_partnerCampaignLog_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_provider_LastUpdated]    Script Date: 22/02/2024 00:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_provider_LastUpdated]
ON [dbo].[provider]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE provider
	SET lastUpdated = GETUTCDATE()
	FROM provider a
	INNER JOIN inserted i ON a.providerID = i.providerID;
END;

ALTER TABLE [dbo].[provider] DISABLE TRIGGER [TR_provider_LastUpdated]
GO
ALTER TABLE [dbo].[provider] DISABLE TRIGGER [TR_provider_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_route_LastUpdated]    Script Date: 22/02/2024 00:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_route_LastUpdated]
ON [dbo].[route]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE route
	SET lastUpdated = GETUTCDATE()
	FROM route a
	INNER JOIN inserted i ON a.routeID = i.routeID;
END;

ALTER TABLE [dbo].[route] DISABLE TRIGGER [TR_route_LastUpdated]
GO
ALTER TABLE [dbo].[route] DISABLE TRIGGER [TR_route_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_routeAction_LastUpdated]    Script Date: 22/02/2024 00:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_routeAction_LastUpdated]
ON [dbo].[routeAction]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE routeAction
	SET lastUpdated = GETUTCDATE()
	FROM routeAction a
	INNER JOIN inserted i ON a.routeActionID = i.routeActionID;
END;

ALTER TABLE [dbo].[routeAction] DISABLE TRIGGER [TR_routeAction_LastUpdated]
GO
ALTER TABLE [dbo].[routeAction] DISABLE TRIGGER [TR_routeAction_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_routeActionType_LastUpdated]    Script Date: 22/02/2024 00:40:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_routeActionType_LastUpdated]
ON [dbo].[routeActionType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE routeActionType
	SET lastUpdated = GETUTCDATE()
	FROM routeActionType a
	INNER JOIN inserted i ON a.routeActionTypeID = i.routeActionTypeID;
END;

ALTER TABLE [dbo].[routeActionType] DISABLE TRIGGER [TR_routeActionType_LastUpdated]
GO
ALTER TABLE [dbo].[routeActionType] DISABLE TRIGGER [TR_routeActionType_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_routeConnection_LastUpdated]    Script Date: 22/02/2024 00:40:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_routeConnection_LastUpdated]
ON [dbo].[routeConnection]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE routeConnection
	SET lastUpdated = GETUTCDATE()
	FROM routeConnection a
	INNER JOIN inserted i ON a.routeConnectionID = i.routeConnectionID;
END;

ALTER TABLE [dbo].[routeConnection] DISABLE TRIGGER [TR_routeConnection_LastUpdated]
GO
ALTER TABLE [dbo].[routeConnection] DISABLE TRIGGER [TR_routeConnection_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_txnNumber_LastUpdated]    Script Date: 22/02/2024 00:40:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_txnNumber_LastUpdated]
ON [dbo].[txnNumber]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE txnNumber
	SET lastUpdated = GETUTCDATE()
	FROM txnNumber a
	INNER JOIN inserted i ON a.txnNumberID = i.txnNumberID;
END;

ALTER TABLE [dbo].[txnNumber] DISABLE TRIGGER [TR_txnNumber_LastUpdated]
GO
ALTER TABLE [dbo].[txnNumber] DISABLE TRIGGER [TR_txnNumber_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_txnVoiceOrig_LastUpdated]    Script Date: 22/02/2024 00:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_txnVoiceOrig_LastUpdated]
ON [dbo].[txnVoiceOrig]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE txnVoiceOrig
	SET lastUpdated = GETUTCDATE()
	FROM txnVoiceOrig a
	INNER JOIN inserted i ON a.txnVoiceID = i.txnVoiceID ;
END;

ALTER TABLE [dbo].[txnVoiceOrig] DISABLE TRIGGER [TR_txnVoiceOrig_LastUpdated]
GO
ALTER TABLE [dbo].[txnVoiceOrig] DISABLE TRIGGER [TR_txnVoiceOrig_LastUpdated]
GO
/****** Object:  Trigger [dbo].[TR_txnVoiceTerm_LastUpdated]    Script Date: 22/02/2024 00:40:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_txnVoiceTerm_LastUpdated]
ON [dbo].[txnVoiceTerm]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Update the LastUpdated column with the current timestamp
	UPDATE txnVoiceTerm
	SET lastUpdated = GETUTCDATE()
	FROM txnVoiceTerm a
	INNER JOIN inserted i ON a.txnVoiceID = i.txnVoiceID ;
END;

ALTER TABLE [dbo].[txnVoiceTerm] DISABLE TRIGGER [TR_txnVoiceTerm_LastUpdated]
GO
ALTER TABLE [dbo].[txnVoiceTerm] DISABLE TRIGGER [TR_txnVoiceTerm_LastUpdated]
GO
/****** Object:  DdlTrigger [tr_database_Log]    Script Date: 22/02/2024 00:40:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [tr_database_Log]
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
	SET NOCOUNT ON

	DECLARE @ObjectName nvarchar(MAX)
	SELECT @ObjectName= EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)')

	DECLARE @data XML,@ipaddres varchar(15)
	SELECT  @ipaddres = convert(varchar(15) ,CONNECTIONPROPERTY('client_net_address')) ;
	SET @data = EVENTDATA()

	IF(@ObjectName not like '%TempData%') 
	BEGIN
		INSERT INTO [dbo].[tbl_SchemaLog](DatabaseName, loginName,IPAddress, HostName, eventType, objectName, objectType, sqlQuery, EventData)
		VALUES(
		@data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'nvarchar(50)'),
		@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'nvarchar(100)'),
		@ipaddres,
		HOST_NAME(),
		@data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(50)'),  -- value is case-sensitive
		@data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)'), 
		@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'nvarchar(50)'), 
		@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)'),
		@data)
	END
GO
ENABLE TRIGGER [tr_database_Log] ON DATABASE
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - friendly format mode, 1 = international format of number expected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'connection', @level2type=N'COLUMN',@level2name=N'destinationNumberFormat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ITU CC' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'numberOperatorNetNumber', @level2type=N'COLUMN',@level2name=N'countryCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'numberOperatorNetNumber', @level2type=N'COLUMN',@level2name=N'countryAbbreviation'
GO
