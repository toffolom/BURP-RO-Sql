use [BHP1-RO]
go

if object_id(N'bwp.GetDeploymentSubscriptionSettings',N'P') is not null
begin
	Drop Proc bwp.GetDeploymentSubscriptionSettings;
	Print 'proc:: bwp.GetDeploymentSubscriptionSettings dropped!!!';
end
go


/*
** This proc is intended to be called from the HUB on a scheduled basis. The intent
** is the HUB is using this proc to collect the deployments subscription preferences.
** We need a session...
*/
Create Proc bwp.GetDeploymentSubscriptionSettings (
	@SessID varchar(256)
)
With Encryption
as
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;
	Declare @SessRowID bigint;

	If (1=0)
	Begin
		Select 
			Cast(Null As varchar(256)) As DeploymentID,
			Cast(Null As SmallInt) As PrefsMstrID,
			Cast(Null As varchar(200)) As PrefName,
			Cast(Null As Bit) As IsManditory,
			Cast(Null As nvarchar(2000)) As Notes,
			Cast(Null As Bit) As AllowChgOp
		Return 0;
	End

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=0;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Select @SessRowID=[RowID] From di.SessionMstr Where SessID=@SessID;

	Select 
		Convert(varchar(256), XX.DeploymentID) As DeploymentID, 
		SUBS.PrefRowID As PrefsMstrID, 
		SUBS.[Name] As PrefName, 
		SUBS.IsManditory, 
		ISNULL(SUBS.Notes,N'No Comments given...') As [Notes],
		ISNULL(SUBS.AllowChgOp,0) As AllowChgOp
	From di.vw_DeploymentSubscriptions As SUBS
	Cross Apply (
		Select DeploymentID From di.vw_DeploymentInfo Where RowID=0 -- retrieve our deploy rec (always rec zero).
	) As XX
	Order By SUBS.Name;

	Set @rc = @@ERROR;

	Return @rc;
End
go