USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [di].[getEnv]    Script Date: 10/10/2018 12:45:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

if object_id(N'[di].GetEnv',N'P') is not null
begin
	drop proc [di].getEnv;
	print 'proc:: [di].getEnv dropped!!!';
end
go

if object_id(N'[di].SetAllowGlblDeployRecsMode',N'P') is not null
begin
	drop proc [di].SetAllowGlblDeployRecsMode;
	print 'proc:: [di].SetAllowGlblDeployRecsMode dropped!!!';
end
go

if object_id(N'[di].SetIgnoreAllGlblDeployRecsMode',N'P') is not null
begin
	drop proc [di].SetIgnoreAllGlblDeployRecsMode;
	print 'proc:: [di].SetIgnoreAllGlblDeployRecsMode dropped!!!';
end
go

create proc [di].[getEnv] (
	@VarNm nvarchar(200),
	@VarVal nvarchar(4000) output,
	@DfltVal nvarchar(4000) = null,
	@OvrVal nvarchar(4000) = null
)
with encryption
as
begin
	Set @VarVal = null;

	If (@OvrVal is not null)
	Begin
		Set @VarVal = @OvrVal;
	End
	Else
	Begin
		Select @VarVal = VarVal From [di].Environment Where (VarNm = @VarNm);

		If (isnull(@@ROWCOUNT,0) = 0)
			Set @VarVal = @DfltVal;
	End

	Return @@Error;
end
GO

Create Proc di.SetIgnoreAllGlblDeployRecsMode (
	@SessID varchar(256),
	@mode bit
)
with encryption
as
Begin
	Declare @varNm nvarchar(200) = N'Mark new Global Deployment recs ignore all mode';
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

	-- make sure enviro variable exists...
	If Not Exists (Select * from di.Environment Where VarNm=@varNm)
	Begin
		Insert Into di.Environment(VarNm,VarVal,Notes)
		Values(@varNm,'on',N'<Notes><Note nbr="1">when new global deployment info arrives mark ''ignore all'' mode</Note></Notes>');
	End

	Update Top (1) di.Environment
		Set VarVal = Case ISNULL(@mode,0) WHen 1 Then 'Yes' Else 'No' End
	Where VarNm = @varNm;

	Return @@ERROR;
End
go

Print 'Proc:: di.SetIgnoreAllGlblDeployRecsMode created...'
go

Create Proc di.SetAllowGlblDeployRecsMode (
	@SessID varchar(256),
	@mode bit
)
with encryption
as
Begin
	Declare @varNm nvarchar(200) = N'Auto add Global Deployment info';
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

	-- make sure enviro variable exists...
	If Not Exists (Select * from di.Environment Where VarNm=@varNm)
	Begin
		Insert Into di.Environment(VarNm,VarVal,Notes)
		Values(@varNm,'on',N'<Notes><Note nbr="1">when subscription events arrive from an unknown deployment...add it!!!</Note></Notes>');
	End

	Update Top (1) di.Environment
		Set VarVal = Case ISNULL(@mode,1) WHen 1 Then 'Yes' Else 'No' End
	Where VarNm = @varNm;

	Return @@ERROR;
End
go

Print 'Proc:: di.SetAllowGlblDeployRecsMode created...'
go


