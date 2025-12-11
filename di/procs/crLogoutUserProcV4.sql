USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [di].[BHPUserLogoutV4]    Script Date: 02/09/2011 10:23:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[BHPUserLogoutV4]') AND type in (N'P', N'PC'))
begin
	print 'proc:[di].BHPUserLogoutV4 dropped...';
	DROP PROCEDURE [di].[BHPUserLogoutV4];
end
GO


create proc [di].BHPUserLogoutV4 (
	@sessid uniqueidentifier,
	@cc int output,
	@mesg nvarchar(2000) output
)
with encryption, execute as 'sticky'
as
begin
	--Set nocount on;
	
	Declare @lang nvarchar(20);
	Declare @deployMsg xml;
	Declare @sessMsg xml;
	Declare @out table([Lang] nvarchar(20) null);
	Declare @DID varchar(256); -- deployment id value
	Declare @name varchar(256); -- bhp user name

	Set @mesg = N'<Messages>user logged out!!!</Messages>';
	
	Update [di].SessionMstr 
		Set ClosedOn = getdate()
	Output Inserted.Lang Into @out (Lang)
	Where (SessID = @sessid);
	
	Set @cc = 66005;
	select Top (1) @lang = ISNULL(lang,N'en_us') from @out;

	select @DID = D.DeploymentID, @name = C.Name
	from [di].SessionMstr S
	Inner Join [di].Deployments D On (S.SessID = @sessid And S.fk_DeployInfo = D.RowID)
	Inner Join [di].CustMstr C On (S.fk_CustID = C.RowID And S.fk_DeployInfo = C.fk_DeployInfo);

	Exec [di].getI18NMsg @Nbr=@cc, @lang=@lang, @msg=@mesg output;

	Select @Mesg = FORMATMESSAGE(@Mesg, @name);

	-- post a ssb msg that a session has logged out!!!
	--exec [di].GenDeployRootNodeMesg @evnttype='logout',@deployID=@DID,@mesg=@deployMsg output;
	--exec [di].GenSessSrcMesg @sessID=@sessid, @mesg=@sessMsg output;
	--	-- stuff in session source node
	--set @deployMsg.modify('
	--	declare namespace b="http://burp.net/deployment/evnts";
	--	insert sql:variable("@sessMsg") as first into (/b:Burp_Deployment/b:Payload)[1]
	--');
	--exec [di].SendDeploymentMesg @msg=@deployMsg;
	
	Return 0;
end
go

revoke execute on [di].BHPUserLogoutV4 to [public];
go
/*
declare @cc int;
declare @msg nvarchar(4000);
declare @rc int;
exec @rc = [di].BHPUserLogoutV4 @sessid='6498DFCD-AC63-4CF6-97D4-896BEDCF4D16',@cc=@cc output, @mesg=@msg output;
select @rc [@rc], convert(xml,@msg) [message];
*/
checkpoint
go