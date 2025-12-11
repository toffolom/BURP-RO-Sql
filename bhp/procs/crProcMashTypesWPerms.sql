USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetMashTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetMashTypes]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetMashTypes];
Print 'Proc:: [bhp].GetMashTypes dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddMashType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddMashType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddMashType];
Print 'Proc:: [bhp].AddMashType dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgMashType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgMashType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgMashType];
Print 'Proc:: [bhp].ChgMashType dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgMashType]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelMashType]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelMashType];
Print 'Proc:: [bhp].DelMashType dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetMashTypes (
	@SessID varchar(256)
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
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
	
	SELECT 
		[RowID]
		,[Name]
		,ISNULL([fk_TempUOM],0) As fk_TempUOM
		--,[TempUOM]
		,ISNULL([BegTempAmt],0.00) As BegTempAmt
		,ISNULL([EndTempAmt],0.00) As EndTempAmt
		,ISNULL([Comments],'no comment given...') As Comments
	FROM [bhp].[MashTypeMstr]
	WHERE (RowID > 0);
	
	Return 0;
end
go

print 'Proc:: [bhp].GetMashTypes created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddMashType (
	@SessID varchar(256),
	@Name nvarchar(200),
	@fk_TempUOMID int = 0,
	@BegTempAmt numeric(6,2),
	@EndTempAmt numeric(6,2),
	@Comment nvarchar(4000) = N'no comment given...',
	@BCastMode bit = 1,
	@RowID int output
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'MashType';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If ((@fk_TempUOMID Is Not Null) And (Not Exists (Select * from [bhp].vw_TemperatureUOM Where RowID = @fk_TempUOMID)))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66043; -- this nbr represents a non-temperature foreign key value...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	Insert Into [bhp].[MashTypeMstr] (	[Name], fk_TempUOM, BegTempAmt, EndTempAmt, Comments)
	Select
		[di].[fn_IsNull](@Name),
		ISNULL(@fk_TempUOMID,0),
		ISNULL(@BegTempAmt, 0.00),
		ISNULL(@EndTempAmt, 0.00),
		ISNULL(@Comment,N'not set');
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpMashTypeMesg @id=@RowID, @evnttype='add', @SessID = @SessID, @mesg=@xml output;
		exec [bhp].[PostToBWPRouter] @inMsg = @xml, @msgNm=@EvntNm;
	End
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddMashType created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelMashType (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'MashType';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].MashSchedMstr Where (fk_MashTypeID = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66052; -- this nbr represents a hop manuf has hops in the system and cannot be removed.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpMashTypeMesg @id=@RowID, @evnttype='del', @SessID = @SessID, @mesg=@xml output;
	
	Delete Top (1) [bhp].[MashTypeMstr] Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].PostToBWPRouter @inMsg=@xml, @msgNm=@EvntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelMashType created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgMashType (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(200),
	@fk_TempUOMID int = 0,
	@BegTempAmt numeric(6,2),
	@EndTempAmt numeric(6,2),
	@Comment nvarchar(4000) = N'no comment given...',
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @SessStatus bit;
	Declare @oldinfo Table ([Name] nvarchar(200));
	Declare @oldnm nvarchar(200);
	Declare @EvntNm nvarchar(100) = N'MashType';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If ((@fk_TempUOMID Is Not Null) And (Not Exists (Select * from [bhp].vw_TemperatureUOM Where RowID = @fk_TempUOMID)))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66043; -- this nbr represents a non-temperature foreign key value...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	update [bhp].[MashTypeMstr]
		set 
			[Name] = @Name,
			fk_TempUOM = ISNULL(@fk_TempUOMID, 0),
			BegTempAmt = ISNULL(@BegTempAmt, 0.00),
			EndTempAmt = ISNULL(@EndTempAmt, 0.00),
			Comments = ISNULL(@Comment, 'no comment given...')
	OutPut deleted.Name into @oldinfo([Name])
	Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @oldnm = [Name] from @oldinfo;

		exec @rc = [bhp].GenBurpMashTypeMesg @id=@RowID, @evnttype='chg', @SessID = @SessID, @mesg=@xml output;

		-- stuff the old name value into doc as attribute 'old'
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldnm")}
			)
			into (/b:Burp_Belch/b:Payload/b:Mash_Type_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg = @xml, @msgNm=@EvntNm;
	End

	Return @rc;
End
go

Print 'Proc:: [bhp].ChgMashType created...';
go

/*
** test of get proc...
exec [bhp].GetMashTypes @SessID = '00000000-0000-0000-0000-000000000000';
**
*/

checkpoint