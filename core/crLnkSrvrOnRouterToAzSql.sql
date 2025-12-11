USE [master]
GO

/****** Object:  LinkedServer [<SRVR,,sysname>]    Script Date: 2/20/2020 10:56:59 AM ******/
IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'<SRVR,,sysname>')
	EXEC master.dbo.sp_dropserver @server=N'<SRVR,,sysname>', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [<SRVR,,sysname>]    Script Date: 2/20/2020 10:56:59 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'<SRVR,,sysname>', @srvproduct=N'', @provider='SQLNCLI', @datasrc='<azhost,hostname,sysname>.database.windows.net,<Port,int,1433>', @catalog='BHP1-RO';
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'<SRVR,,sysname>',@useself=N'False',@locallogin=NULL,@rmtuser=N'<USR,,burpAdmin>',@rmtpassword='<PSWD,,2Admin4U!!00>';
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'connect timeout', @optvalue=N'5'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'query timeout', @optvalue=N'20'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'<SRVR,,sysname>', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

--select * from <SRVR,,sysname>.[BHP1-RO].di.rolemstr;
--go
