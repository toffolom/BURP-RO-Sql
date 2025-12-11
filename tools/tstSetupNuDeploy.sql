use [BHP1-RO]
go

Declare @g varchar(256);
set @g = NEWID()
exec tools.SetupDeployment @SessID='00000000-0000-0000-0000-000000000000',
	@DeployGUID=@g,
	@BusinessName='burp test brewery comp.',
	@Descr='this is a test brewery...',
	@SysAdminEMail='burptest_adm@burp.biz',
	@UsrAdminEmail='mike@fi.net',
	@UsrLOginPswd='foobar',
	@UsrAlias='mighty',
	@PrimaryContactName='mike toffolo',
	@PrimaryPh='(248)684-2910';
go

select * from di.Environment;
select * from bhp.Environment;
Select * from di.SessionMstr;
select * from di.CustMstr;
select * from di.Contacts
select * from di.CustTargetInfo;
select * from bhp.RecipeJrnlMstr;
Select * from di.Deployments