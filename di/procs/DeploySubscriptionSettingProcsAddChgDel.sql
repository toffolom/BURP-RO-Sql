use [BHP1-RO]
go

if object_id(N'di.GetDeploymentSubscriptionSettings',N'P') is not null
begin
	Drop Proc di.GetDeploymentSubscriptionSettings;
	Print 'proc:: di.GetDeploymentSubscriptionSettings dropped!!!';
end
go

if object_id(N'di.AddDeploymentSubscriptionSetting',N'P') is not null
begin
	Drop Proc di.AddDeploymentSubscriptionSetting;
	Print 'proc:: di.AddDeploymentSubscriptionSetting dropped!!!';
end
go

if object_id(N'di.ChgDeploymentSubscriptionSetting',N'P') is not null
begin
	Drop Proc di.ChgDeploymentSubscriptionSetting;
	Print 'proc:: di.ChgDeploymentSubscriptionSetting dropped!!!';
end
go

if object_id(N'di.DelDeploymentSubscriptionSetting',N'P') is not null
begin
	Drop Proc di.DelDeploymentSubscriptionSetting;
	Print 'proc:: di.DelDeploymentSubscriptionSetting dropped!!!';
end
go

/*
** This proc is intended to be called from the HUB on a scheduled basis. The intent
** is the HUB is using this proc to collect the deployments subscription preferences.
** We need a session...
*/
Create Proc di.GetDeploymentSubscriptionSettings (
	@SessID varchar(256)
)
With Encryption
as
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;

	If (1=0)
	Begin
		Select 
			Cast(Null As varchar(256)) As DeploymentID,
			Cast(Null As Int) As RowID,
			Cast(Null As SmallInt) As PrefsMstrID,
			Cast(Null As varchar(200)) As PrefName,
			Cast(Null As Bit) As IsManditory,
			Cast(Null As nvarchar(2000)) As Notes,
			Cast(Null As Bit) As AllowChgOp,
			Cast(Null As Datetime) As ValidFrom,
			Cast(Null As Datetime) As ValidTill,
			Cast(Null As varchar(20)) As Domain
		Return 0;
	End

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select 
		Convert(varchar(256), XX.DeploymentID) As DeploymentID,
		SUBS.RowID,
		SUBS.RowID As PrefsMstrID, 
		SUBS.[Name] As PrefName, 
		SUBS.IsManditory, 
		ISNULL(SUBS.Notes,N'No Comments given...') As [Notes],
		ISNULL(SUBS.AllowChgOp,0) As AllowChgOp,
		SUBS.ValidFrom,
		SUBS.ValidTill,
		ISNULL(SUBS.Domain,'undef') As Domain
	From di.vw_DeploymentSubscriptions As SUBS 
	Cross Apply (
		Select DeploymentID From di.vw_DeploymentInfo Where RowID=0 -- retrieve our deploy rec (always rec zero).
	) As XX
	Order By SUBS.Name;

	Set @rc = @@ERROR;

	Return @rc;
End
go

print 'proc:: di.GetDeploymentSubscriptionSettings created...';
go

/*
** This proc will add a subscription record preference to the di.DeploymentSubscriptions table
*/
Create Proc di.AddDeploymentSubscriptionSetting (
	@SessID varchar(256),
	@PrefMstrID int,
	@ValidTill datetime,
	@AllowChgOp bit = 0,
	@Force bit = 0, -- set to (1) to remove if pref already there
	@RowID int output
)
With Encryption
as
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;
	Declare @Tbl Table ([ID] int);

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * from di.DeploymentSubscriptions Where Fk_PrefMstrID=@PrefMstrID)
	Begin
		Declare @pnm varchar(200);
		Select @pnm = [Name] From di.DeploymentPrefsMstr Where RowID=@PrefMstrID;
		If (@Force = 0)
		Begin
			Raiserror(N'Preference:[''%s''] already defined...aborting!!!',16,1,@pnm);
			Return -1;
		End

		Delete di.DeploymentSubscriptions Where Fk_PrefMstrID=@PrefMstrID;
		Set @rc = @@ROWCOUNT;
		Raiserror(N'Removed:[%d] subsription preference rec(s) w/Name:[''%s''].',0,1,@rc,@pnm);
	End

	Insert Into di.DeploymentSubscriptions(Fk_PrefMstrID,ValidFrom,ValidTill,AllowChgOp)
	Output Inserted.RowID Into @Tbl
	Values(@PrefMstrID,GETDATE(),ISNULL(@ValidTill,Dateadd(YY,100,GETDATE())),ISNULL(@AllowChgOp,0));

	Set @rc = @@ERROR;

	Select @RowID = [ID] From @Tbl;

	Return @rc;
End
go

Print 'Proc:: di.AddDeploymentSubscriptionSetting created...';
go

Create Proc di.ChgDeploymentSubscriptionSetting (
	@SessID varchar(256),
	@RowID int,
	@PrefMstrID int,
	@ValidTill datetime,
	@AllowChgOp bit = 0
)
With Encryption
as
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;
	Declare @Tbl Table ([ID] int);

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Update di.DeploymentSubscriptions
		Set Fk_PrefMstrID = @PrefMstrID,
			ValidTill = ISNULL(@ValidTill, DateAdd(YY,100,GETDATE())),
			AllowChgOp = ISNULL(@AllowChgOp,0)
	Where (RowID = @RowID);

	Set @rc = @@ERROR;

	REturn @Rc;
End
Go

Print 'Proc:: di.ChgDeploymentSubscriptionSetting created...';
go


Create Proc di.DelDeploymentSubscriptionSetting (
	@SessID varchar(256),
	@RowID int
)
With Encryption
as
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;
	Declare @Tbl Table ([ID] int);

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Delete di.DeploymentSubscriptions Where (RowID = @RowID);

	Set @rc = @@ERROR;

	REturn @Rc;
End
Go

Print 'Proc:: di.DelDeploymentSubscriptionSetting created...';
go