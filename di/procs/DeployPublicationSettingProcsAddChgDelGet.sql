use [BHP1-RO]
go

if object_id(N'[di].[GetDeploymentPublicationSettings]',N'P') is not null
begin
	Drop Proc [di].[GetDeploymentPublicationSettings];
	print 'Proc:: di.GetDeploymentPublicationSettings dropped!!!';
end
go

Create proc di.[GetDeploymentPublicationSettings] (
	@SessID varchar(256)
)
With Encryption
as
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xdoc xml;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (1=0)
	Begin
		Select 
			Cast(Null As varchar(256)) As DeploymentID,
			Cast(Null As Int) As RowID,
			Cast(Null As SmallInt) As PrefsMstrID,
			Cast(Null As varchar(200)) As PrefName,
			Cast(Null As Bit) As IsManditory,
			Cast(Null As nvarchar(2000)) As Notes,
			Cast(Null As Bit) As SendChgOp,
			Cast(Null As Datetime) As ValidFrom,
			Cast(Null As Datetime) As ValidTill,
			Cast(Null As varchar(20)) As Domain
		Return 0;
	End

	Select 
		Convert(varchar(256), XX.DeploymentID) As DeploymentID,
		PUBS.RowID,
		PUBS.RowID As PrefsMstrID, 
		PUBS.[Name] As PrefName, 
		PUBS.IsManditory, 
		ISNULL(PUBS.Notes,N'No Comments given...') As [Notes],
		ISNULL(PUBS.SendChgOp,0) As SendChgOp,
		PUBS.ValidFrom,
		PUBS.ValidTill,
		ISNULL(PUBS.Domain,'undef') As Domain
	From di.vw_DeploymentPublications As PUBS 
	Cross Apply (
		Select DeploymentID From di.vw_DeploymentInfo Where RowID=0 -- retrieve our deploy rec (always rec zero).
	) As XX
	Order By PUBS.Name;

	Return @@ERROR;
end
go

/*

exec di.[GetDeploymentPublicationSettings] @SEssID='00000000-0000-0000-0000-000000000000'

*/