use [BHP1-RO]
go

if object_id(N'[di].[GetDeploymentPublicationPrefs]',N'P') is not null
begin
	Drop Proc [di].[GetDeploymentPublicationPrefs];
	print 'Proc:: di.GetDeploymentPublicationPrefs dropped!!!';
end
go

create proc di.[GetDeploymentPublicationPrefs] (
	@SessID varchar(256)
)
with encryption
as
begin
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

	Select * from di.vw_DeploymentPublications Order By [Name];

	Return @@ERROR;
end
go