USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[getSpargeTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[getSpargeTypes]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[getSpargeTypes];
	Print 'Proc:: [bhp].getSpargeTypes dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[AddSpargeType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[AddSpargeType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[AddSpargeType];
	Print 'Proc:: [bhp].AddSpargeType dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[DelSpargeType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DelSpargeType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[DelSpargeType];
	Print 'Proc:: [bhp].DelSpargeType dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[ChgSpargeType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ChgSpargeType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[ChgSpargeType];
	Print 'Proc:: [bhp].ChgSpargeType dropped!!!';
End
GO

create proc [bhp].getSpargeTypes (
	@SessID varchar(256)
)
with encryption
as
begin
	Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @sql nvarchar(max);
	Declare @SessStatus bit;

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End


	Select RowID, [Name], ISNULL(AKA,'n/a') As AKA, ISNULL(Comment, 'no comments...') As Comment
	From [bhp].SpargeTypes Where (RowID > 0);

	Return @@Error;
end
go

Create Proc [bhp].AddSpargeType (
	@SessID varchar(256),
	@Name nvarchar(20),
	@AKA nvarchar(20) = Null,
	@Comment nvarchar(2000) = null,
	@BCastMode bit = 1,
	@RowID int output
)
with encryption
as
Begin

	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @xml xml;
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = N'Sparge';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * from [bhp].SpargeTypes Where Name = @Name)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66050; -- this nbr represents attempting to add a duplicate Sparge name...
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Insert Into [bhp].SpargeTypes ([Name], AKA, Comment)
	Select
		RTRIM(LTRIM(@Name)),
		Case When @AKA = 'not set' Then Null Else RTRIM(LTRIM(@AKA)) End,
		ISNULL(Case When @Comment = 'pls enter a comment...' Then Null Else RTRIM(LTRIM(@Comment)) End, 'no comment given...');

	Set @RowID = SCOPE_IDENTITY();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpSpargeTypeMesg @id = @rowid, @evnttype='add', @SessID = @SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End

	Return ISNULL(@rc, 0);
End
go

Create Proc bhp.DelSpargeType (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1
)
with encryption, execute as 'sticky'
as
Begin
	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @Sql NVarchar(max);
	Declare @TblID int;
	Declare @ColNm sysname;
	Declare @TblNm sysname;
	Declare @Found bit;
	Declare @xml xml;
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'Sparge';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @TblID = 0;
	Set @Found = 0;

	/*
	** We'll walk thru the foreign key constraints...generate a little sql to test if the key value is in use!!!
	*/
	While Exists (
		Select 1 from sys.foreign_key_columns fkc
		inner join sys.columns c on (fkc.parent_object_id = c.object_id and c.column_id = fkc.parent_column_id)
		where fkc.referenced_object_id = OBJECT_ID(N'[bhp].SpargeTypes',N'U') And (fkc.parent_object_id > @TblID) And (@Found = 0)
	)
	Begin

		Select Top (1) @TblID = fkc.parent_object_id, @TblNm = OBJECT_NAME(fkc.parent_object_id), @ColNm = c.[Name]
		From sys.foreign_key_columns fkc
		Inner join sys.columns c on (fkc.parent_object_id = c.object_id and c.column_id = fkc.parent_column_id)
		Where fkc.referenced_object_id = OBJECT_ID(N'[bhp].SpargeTypes',N'U') And (fkc.parent_object_id > @TblID)
		Order By fkc.parent_object_id;

		Set @Sql = N'
Set NoCount On;
If Exists (Select * from [bhp].[' + @TblNm +  '] Where ([' + @ColNm + '] = @InRowID))
	Set @OutFound=1;
';

		Exec [dbo].sp_ExecuteSql @Stmt=@Sql, @Params=N'@InRowID int, @OutFound bit output', @InRowID=@RowID, @OutFound=@Found output;

	End

	/*
	** Big check here...can't remove a Sparge item if used anywhere within system design...
	*/

	If (@Found = 1) -- somewhere in system the Sparge is used...abort!!!
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66093; -- this nbr represents that user cannot remove Sparge because it is in use...
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpSpargeTypeMesg @id = @rowid, @evnttype='del', @SessID = @SessID, @Mesg = @xml output;
	
	Delete Top (1) [bhp].SpargeTypes Where RowID = @RowID;
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;

	Return ISNULL(@rc, 0);
End
go

Create Proc [bhp].ChgSpargeType (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(20),
	@AKA nvarchar(20),
	@Comment nvarchar(2000) = N'no comment given...',
	@BCastMode bit = 1
)
with encryption
as
Begin
	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @xml xml;
	Declare @SessStatus bit;
	Declare @oldinfo Table ([Name] varchar(20));
	Declare @oldnm varchar(20);
	Declare @EvntNm nvarchar(100) = N'Sparge';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @rc = 0;

	Update [bhp].SpargeTypes
		Set [Name] = @Name,
			AKA = Case When @AKA = 'not set' Then Null Else RTRIM(LTRIM(@AKA)) End,
			Comment = ISNULL(Case When @Comment = 'pls enter a comment...' Then Null Else RTRIM(LTRIM(@Comment)) End, 'no comment set...')
	Output deleted.[Name] into @oldinfo([Name])
	Where (RowID = @RowID) And (RowID > 0);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @oldnm = [Name] from @oldinfo;

		exec @rc = [bhp].GenBurpSpargeTypeMesg @id = @rowid, @evnttype='chg', @SessID = @SessID, @mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldnm")}
			into (/b:Burp_Belch/b:Payload/b:Sparge_Type_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;
	End

	return @@ERROR;
End
go

/*
exec [bhp].getSpargeTypes @SessID = '00000000-0000-0000-0000-000000000000';
*/

checkpoint