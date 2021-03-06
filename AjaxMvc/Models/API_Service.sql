USE [API_SERVICE]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationLogin]    Script Date: 12/19/2018 3:52:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_applicationLogin]
	  @flag							VARCHAR(50)		= NULL
     ,@userName                     VARCHAR(30)		= NULL
     ,@pwd                          VARCHAR(255)	= NULL
     ,@ipAddress					VARCHAR(100)	= NULL
	 
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ## Admin Login
IF @flag = 'l' 
Declare
        @userId						    VARCHAR(10)		= NULL
        ,@loginUserName                 VARCHAR(30)		= NULL
        ,@loginPwd                      VARCHAR(255)	= NULL
        ,@UserInfoDetail				VARCHAR(MAX)	= NULL
		,@UserData						VARCHAR(MAX)	= NULL
		,@createdDate					DATETIME        = NULL

BEGIN

	SET @UserData ='User: ' + ISNULL(@userName,'') 
	
	SET @userId = NULL
	SET @createdDate=GETDATE()
	SELECT 
		 @userId				= userId
		,@loginUserName			= userName
		,@loginPwd				= pwd
	FROM applicationUsers au WITH(NOLOCK)
	WHERE userName = @userName 
	
	IF @userId IS NULL
	BEGIN
		SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect user name.-:::-' 

		EXEC proc_applicationLogs 
			@flag				= 'login',
			@logType			= 'Login fails', 
			@createdBy			= @userName, 
			@Reason				= 'Invalid Username',
			@UserData			= @UserData,
			@fieldValue			= @UserInfoDetail,
			@IP					= @ipAddress,
			@userId			    = @userId
					

		RETURN		
	END
	
	IF(@userId <> (SELECT userId FROM dbo.applicationUsers WHERE username=@userName))
	BEGIN
		SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' msg, @userName id
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect userId.-:::- '

		EXEC proc_applicationLogs 
			@flag				= 'login',
			@logType			= 'Login fails', 
			@createdBy			= @userName, 
			@Reason				= 'Incorrect username',
			@UserData			= @UserData,
			@fieldValue			= @UserInfoDetail,
			@IP					= @ipAddress,
			@userId				= @userId
			
		RETURN		
	END
	
	IF (@loginPwd <> ISNULL(dbo.encryptDb(@pwd), ''))
	BEGIN
		SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' msg, @userName id
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect password.-:::-'

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Incorrect password',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@IP				= @ipAddress,
			@userId			= @userId
			
		RETURN		
	END

    IF ((@loginPwd = dbo.encryptDb(@pwd)) and @userId =(SELECT userId FROM dbo.applicationUsers WHERE username=@userName))
	BEGIN
		SELECT 0 errorCode, 'Login Success, Correct user name and password.' msg, @userName id
		SET @UserInfoDetail = 'Reason = Login Success -:::-'

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login success', 
			@createdBy		= @userName, 
			@Reason			= 'Correct credentials',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@IP				= @ipAddress,
			@userId			=  @userId
			
		RETURN		
	END
END
	
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationLogs]    Script Date: 12/19/2018 3:52:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_applicationLogs]
	 @flag				VARCHAR(50)
	,@logType			VARCHAR(50)		= NULL
    ,@IP			    VARCHAR(50)		= NULL
    ,@Reason		    VARCHAR(2000)	= NULL
	,@UserData			VARCHAR(max)	= NULL
	,@fieldValue		VARCHAR(2000)	= NULL
	,@createdBy			VARCHAR(30)		= NULL
	,@createdDate		DATETIME        = NULL
	,@userId			VARCHAR(30)		= NULL
	
AS

SET NOCOUNT ON;


IF @flag = 'login'
BEGIN

	INSERT INTO LoginLogs 
     (	
		  [logType]
           ,[IP]
           ,[Reason]
		 ,[UserData]
           ,[fieldValue]
           ,[createdBy]
           ,[createdDate]
		   ,[userId]
		 
	)
	SELECT 
		 @logType
		,@IP
		,@Reason
		,@UserData
		,@fieldValue
		,@createdBy
		,GETDATE()
		,@userId
		
		
END
GO
/****** Object:  StoredProcedure [dbo].[proc_AppUsers]    Script Date: 12/19/2018 3:52:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_AppUsers](@flag varchar(5),@username VARCHAR(MAX)=NULL,@pwd VARCHAR(100)=NULL,@email VARCHAR(50)=NULL)
 AS 
 BEGIN
	IF @flag='i'
	BEGIN
		IF EXISTS (SELECT 'x' FROM dbo.applicationUsers WHERE username=@username)
		BEGIN
			SELECT errorCode='1',msg='User name already exists.',id=null
			return
        END

		 INSERT INTO applicationUsers(username,pwd,emailAddress)
		 SELECT @username,API_SERVICE.dbo.encryptdb(@pwd),@email

		 SELECT errorCode='0',msg='Data inserted successfully',id=SCOPE_IDENTITY()
		 RETURN
    END
    
 END
GO
/****** Object:  StoredProcedure [dbo].[proc_Feature]    Script Date: 12/19/2018 3:52:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROC [dbo].[proc_Feature](@flag varchar(5),@name varchar(100)=null)
  AS BEGIN
  IF @flag='i'
	BEGIN
		IF EXISTS (SELECT 'x' FROM dbo.Features WHERE name=@name)
		BEGIN
			SELECT errorCode='1',msg='Feature already exists.',id=null
			return
        END
        
		INSERT INTO [API_SERVICE].[dbo].[Features] (Name)
		SELECT @name

		SELECT errorCode='0',msg='Data inserted successfully',id=SCOPE_IDENTITY()
		RETURN
        
    END
  ELSE IF @flag='s'
	BEGIN
		SELECT Id,Name FROM dbo.Features(NOLOCK)		
	END
	  
  END
 
 EXEC proc_Feature @flag='s'
GO
/****** Object:  UserDefinedFunction [dbo].[decryptDb]    Script Date: 12/19/2018 3:52:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[decryptDb] (@str as Varchar(100))  
RETURNS varchar(100) AS  
BEGIN 
declare  @y varchar(100),@x as varchar(100)
set @x=''
declare  @i int
set @i=1
	while @i <= len(@str)
	begin
		set @y =  convert(varchar(10),Char(ASCII(SUBSTRING(@str, @i, 1)) - 25))
		set @x=@x+@y
		set @i=@i+1
	END
return (@x)
end
GO
/****** Object:  UserDefinedFunction [dbo].[encryptDb]    Script Date: 12/19/2018 3:52:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 create FUNCTION [dbo].[encryptDb] (@str as Varchar(100))  
RETURNS varchar(100) AS  
BEGIN 
declare  @y varchar(100),@x as varchar(100)
set @x=''
declare  @i int
set @i=1
	while @i <= len(@str)
	begin
		set @y =  convert(varchar(10),Char(ASCII(SUBSTRING(@str, @i, 1)) + 25))
		set @x=@x+@y
		set @i=@i+1
	END
return (@x)
end
GO
/****** Object:  Table [dbo].[applicationUsers]    Script Date: 12/19/2018 3:52:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[applicationUsers](
	[userId] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](150) NULL,
	[pwd] [varchar](100) NULL,
	[emailAddress] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Features]    Script Date: 12/19/2018 3:52:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Features](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Features] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LoginLogs]    Script Date: 12/19/2018 3:52:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoginLogs](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[logType] [varchar](50) NULL,
	[IP] [varchar](100) NULL,
	[Reason] [varchar](2000) NULL,
	[fieldValue] [varchar](2000) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[UserData] [varchar](max) NULL,
	[userId] [int] NULL,
 CONSTRAINT [pk_idx_LoginLogs_rowId] PRIMARY KEY NONCLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
