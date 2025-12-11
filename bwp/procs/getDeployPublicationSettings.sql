use [BHP1-RO]
go

if object_id(N'[bwp].[GetDeploymentPublicationSettings]',N'P') is not null
begin
	Drop Proc [bwp].[GetDeploymentPublicationSettings];
	print 'Proc:: bwp.GetDeploymentPublicationSettings dropped!!!';
end
go

create proc bwp.[GetDeploymentPublicationSettings] (
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

	Select 
		XX.DeploymentID, PUBS.RowID As PrefsMstrID, PUBS.[Name] As PrefName, PUBS.IsManditory, ISNULL(PUBS.Notes,N'No Comments given...') As [Notes]
	From di.vw_DeploymentPublications As PUBS
	Cross Apply (
		Select DeploymentID From di.vw_DeploymentInfo Where RowID=0 -- retrieve our deploy rec (always rec zero).
	) As XX
	Order By PUBS.[Name];

	Return @@ERROR;
end
go