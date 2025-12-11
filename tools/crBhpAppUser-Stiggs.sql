Use [BHP1-RO]
go


/****** Object:  User [<Login,,BHPApp,BurpApp>]    Script Date: 3/2/2020 2:46:55 PM ******/
DROP USER IF EXISTS [<Login,,BHPApp,BurpApp>]
GO

use master
go

if exists (select * from sys.server_principals where name = '<Login,,BHPApp,BurpApp>')
begin
	drop login [<Login,,BHPApp,BurpApp>];
	print 'Login:[<Login,,BHPApp,BurpApp>] dropped!!!';
end
go

CREATE LOGIN [<Login,,BHPApp,BurpApp>] 
	WITH PASSWORD = '<pswd,,2BurpIt4U>', DEFAULT_DATABASE=[BHP1-RO], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
Print 'Login:[<Login,,BHPApp,BurpApp>] created!!!';
GO

use [BHP1-RO]
go

drop user if exists [<Login,,BHPApp,BurpApp>];
go

/****** Object:  User [<Login,,BHPApp,BurpApp>]    Script Date: 3/2/2020 2:46:55 PM ******/
CREATE USER [<Login,,BHPApp,BurpApp>] FOR LOGIN [<Login,,BHPApp,BurpApp>] WITH DEFAULT_SCHEMA=[bhp]
GO


