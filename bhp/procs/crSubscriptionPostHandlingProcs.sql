use [BHP1-RO]
go

if object_id(N'bhp.SetSubscriptionEventStatus',N'P') is not null
begin
	print 'proc:: [bhp].[SetSubscriptionEventStatus] dropped!!!';
	drop proc [bhp].[SetSubscriptionEventStatus];
end
go

if object_id(N'bhp.GetSubscriptionEvents',N'P') is not null
begin
	print 'proc:: [bhp].[GetSubscriptionEvents] dropped!!!';
	drop proc [bhp].[GetSubscriptionEvents];
end
go

if object_id(N'bhp.DelSubscriptionEvent',N'P') is not null
begin
	print 'proc:: [bhp].[DelSubscriptionEvent] dropped!!!';
	drop proc [bhp].[DelSubscriptionEvent];
end
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[fn_ChkPrefMstrByName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
begin
	DROP FUNCTION [di].fn_ChkPrefMstrByName;
	print 'function:: ''di.fn_ChkPrefMstrByName'' dropped!!!';
end
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_ChkSubscriptionStatusName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
begin
	DROP FUNCTION [bhp].fn_ChkSubscriptionStatusName;
	print 'function:: ''bhp.fn_ChkSubscriptionStatusName'' dropped!!!';
end
GO

--Create Function [di].[fn_ChkPrefMstrByName](@nm varchar(200))
--returns bit
--with encryption
--as
--begin

--	if not exists (Select 1 from [di].[DeploymentPrefsMstr] Where [Name]=@nm)
--		return 0;
--	return 1
--end
--go

Create Function bhp.fn_ChkSubscriptionStatusName(@nm varchar(50))
returns bit
with encryption
as
begin
	If (@nm in ('Pending','rejected','accepted','inprocess','processed','failed','undef','ignored'))
		return 1;
	return 0;
end
go




Create Proc bhp.DelSubscriptionEvent(
	@SessID varchar(256),
	@RowID bigint
)
with encryption
as
begin
	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @SessStatus bit;

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Delete bhp.SubscriptionEvntPostings Where (RowID=@RowID);

	Set @rc = @@ERROR

	return @rc;
end
go

Create Proc bhp.SetSubscriptionEventStatus (
	@SessID varchar(256),
	@RowID bigint,
	@Status varchar(50),
	@Comment nvarchar(1000) null = 'no comment given...'
)
with encryption
as
begin
	Declare @rc int;
	Declare @b bit;
	Declare @Mesg nvarchar(2000);
	Declare @SessStatus bit;

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @b = bhp.fn_ChkSubscriptionStatusName(@Status);

	If (@b != 1)
	Begin
		Raiserror(N'Param:[@Status] must be one of ''Rejected'',''Accepted'',''Pending'',''Validating'',''Processed'',''Failed'' or ''Ignored''', 16,1);
		Return -1;
	End

	Update bhp.SubscriptionEvntPostings
		Set CommitedOn = Case @Status When 'Pending' THen 0 When 'Ignored' THen 0 Else GETDATE() End,
			Comment = ISNULL(@Comment, N'no comment given...'),
			[Status] = @Status
	Where (RowID=@RowID);

	Set @rc = @@ERROR

	return @rc;
end
go

/*
** usually this proc is called without any params below...we just want to return
** rows that are 'Pending'...but you can taylor the results by setting param
** values below. If you want to see 'rejected'...set @IncludeRejects=1.
** Same for 'accepted'...set @includeaccepted=1.
** Furthermore, you can limit the size of the result set by setting @MaxRows!!!
*/
Create Proc bhp.[GetSubscriptionEvents] (
	@SessID varchar(256),
	@IncludeRejects bit = 0,
	@IncludeAccepted bit = 0,
	@AllRows bit = 0,
	@MaxRows int = 1000,
	@IncludeIgnored bit = 0, -- set to (1) to see events you've choosen to ignore!!!
	@Fk_GlblDeployRowID int = null
)
with encryption, execute as 'sticky'
as
begin
	Declare @Sql nvarchar(max);
	Declare @clause nvarchar(1000);
	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @SessStatus bit;


	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @Fk_GlblDeployRowID = ISNULL(@Fk_GlblDeployRowID,-1);

	If (1=0)
	Begin
		Select
			Cast(Null as bigint) As [RowID],
			Cast(Null as smallint) as [Fk_PrefsMstrID],
			Cast(Null as varchar(30)) as [Action],
			Cast(Null as varchar(50)) as [Status],
			GETDATE() As [RecvdOn],
			GETDATE() As [CommitedOn],
			Cast(Null as varchar(200)) as [DeploymentSource],
			Cast(Null as int) as [ProcessAttemptCount],
			Cast(Null as nvarchar(4000)) as [Doc],
			Cast(Null as nvarchar(1000)) as [Comment],
			Cast(Null As Int) As Fk_GlblDeployRowID;
		Return 0;
	End

	If (@Fk_GlblDeployRowID > 0)
		Set @clause = N'(G.[RowID]=' + Convert(varchar, @Fk_GlblDeployRowID) + N')';

	if (ISNULL(@AllRows,0) = 0)
	Begin
		If (@clause is not null)
			Set @clause = @clause + ' And ';
		else
			Set @clause = '';

		Set @clause = @clause + N'(E.[Status] = ''Pending'''; -- ALWAYS	return pending rec(s)...
		
		If (@IncludeAccepted = 1)
			Set @clause = @clause + N' Or E.[Status] = ''Accepted''';

		If (@IncludeRejects = 1)
			Set @clause = @clause + N' Or E.[Status] = ''Rejected''';

		If (@IncludeIgnored = 1)
			Set @clause = @clause + N' Or E.[Status] = ''Ignored''';

		Set @clause = @clause + N')';
	End

	If (@clause is null)
		Set @clause = '(1=1)';

	Set @MaxRows = ISNULL(@MaxRows,1000);
	Set @Sql = N'
Select Top (@InTop)
	E.[RowID], 
	E.Fk_PrefsMstrID, 
	E.[Action], 
	E.[Status], 
	ISNULL(E.RecvdOn, GETDATE()) As [RecvdOn], 
	ISNULL(E.CommitedOn, 0) As [CommitedOn], 
	Coalesce(G.Name, E.DeploymentSource) As DeploymentSource, 
	ISNULL(E.ProcessAttemptCount,0) As ProcessAttemptCount, 
	E.[Doc], 
	ISNULL(E.[Comment],N''no comment given...'') As [Comment],
	Coalesce(G.RowID, E.Fk_GlblDeployRowID) As Fk_GlblDeployRowID
From [bhp].[SubscriptionEvntPostings] As E
Inner Join [di].[vw_DeploymentPrefsMstr] As S On (E.Fk_PrefsMstrID = S.RowID)
Inner Join [bwp].[GlblDeploymentsInfo] As G On (E.Fk_GlblDeployRowID = G.RowID)
Where ' + @clause + '
Order by E.[RecvdOn];';

--Raiserror(N'RowID:[%d]',0,1,@fk_GlblDeployRowID);
--Raiserror(N'%s',0,1,@sql);

	Exec @rc = dbo.sp_ExecuteSql @Stmt=@Sql, @Params=N'@InTop int', @InTop=@MaxRows;

	Return @rc;

end
go

if not exists (Select * from di.Environment Where VarNm='Auto add global deployment info')
Begin
	Insert into di.Environment(VarNm,VarVal,Notes)
	Values('Auto add global deployment info','yes',N'<Notes><Note nbr="1">when subscription events arrive from an unknown deployment...add it!!!</Note></Notes>');
	Print 'Environment var:[''Auto add global deployment info''] created!!!';
End
go

/*
exec [BHP1-RO].bhp.GetSubscriptionEvents @SessID=N'00000000-0000-0000-0000-000000000000', @MaxRows=10, @IncludeRejects=1;



*/