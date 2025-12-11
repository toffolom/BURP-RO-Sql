use [BHP1-RO]
go

if object_id(N'[di].[SetDeploymentPublicationPref]',N'P') is not null
begin
	Drop Proc [di].[SetDeploymentPublicationPref];
	print 'Proc:: di.SetDeploymentPublicationPref dropped!!!';
end
go

Create Proc di.SetDeploymentPublicationPref (
	@SessID varchar(256),
	@PrefName varchar(200),
	@Enabled bit,
	@ValidTill datetime = null,
	@Force bit = 0
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

	If (@Enabled = 0)
	Begin
		Delete [di].[DeploymentPublications] Where (PrefName = @PrefName);
	End
	Else
	Begin
		If (@Force = 1)
		Begin
			Delete [di].[DeploymentPublications] Where (PrefName = @PrefName);
		End

		If Not Exists (Select 1 from [di].[DeploymentPublications] Where PrefName=@PrefName)
		Begin
			Insert into [di].[DeploymentPublications] (Fk_PrefMstrID, ValidFrom, ValidTill)
			Select RowID, GETDATE(), ISNULL(@ValidTill,DATEADD(YEAR,1000,GETDATE()))
			From [di].[DeploymentPrefsMstr] Where Name=@PrefName;
		End
	End

	Return @@ERROR;
end
go

