USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[getStageTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[getStageTypes]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[getStageTypes];
	Print 'Proc:: [bhp].getStageTypes dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[AddStageType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[AddStageType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[AddStageType];
	Print 'Proc:: [bhp].AddStageType dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[DelStageType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DelStageType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[DelStageType];
	Print 'Proc:: [bhp].DelStageType dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[ChgStageType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ChgStageType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[ChgStageType];
	Print 'Proc:: [bhp].ChgStageType dropped!!!';
End
GO

create proc [bhp].getStageTypes (
	@SessID varchar(256),
	@OnlyHopTypes bit = 1,
	@OnlyMashTypes bit = 1,
	@OnlyYeastTypes bit = 1,
	@OnlyAgingTypes bit = 1,
	@Lang nvarchar(20) = N'en_us'
)
with encryption, execute as 'sticky'
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @sql nvarchar(max);
	Declare @SessStatus bit;

	if (1=0)
	Begin
		Select
			cast(null as int) as RowID
			,cast(null as nvarchar(100)) as [Name]
			,cast(null as bit) As AllowedInHopSched
			,cast(null as bit) As AllowedInYeastSched
			,cast(null as bit) As AllowedInMashSched
			,cast(null as bit) As AllowedInAgingSched
			,cast(null as nvarchar(100)) As AKA1
			,cast(null as nvarchar(100)) As AKA2
			,cast(null as nvarchar(100)) As AKA3
			,cast(null as nvarchar(1000)) As Comment
			,cast(null as datetime) as EnteredOn
			,cast(null as nvarchar(20)) As [Lang]
		Set FmtOnly Off;
		Return;
	End
	
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @Lang = ISNULL(@Lang, N'en_us');
	
	If (@Lang = 'en_us')
	Begin

		Set @sql = N'
Select 
	RowID
	,Name
	,ISNULL(AllowedInHopSched,0) As AllowedInHopSched
	,ISNULL(AllowedInYeastSched,0) As AllowedInYeastSched
	,ISNULL(AllowedInMashSched,0) As AllowedInMashSched
	,ISNULL(AllowedInAgingSched,0) As AllowedInAgingSched
	,ISNULL(AKA1,''not set'') As AKA1
	,ISNULL(AKA2,''not set'') As AKA2
	,ISNULL(AKA3,''not set'') As AKA3
	,ISNULL(Comment,''no comment given...'') As Comment
	,EnteredOn
	,ISNULL(Lang, @inLang) As [Lang]
From [bhp].StageTypes Where (RowID > 0)
Order By [Name];
';

		Exec [dbo].sp_executeSql @Stmt=@Sql, @Params = N'@inLang nvarchar(20)', @inLang=@Lang;

	End
	Else
		Begin
			Raiserror('multi language binding not implemented yet...only ''en_us''!!!',16,1);
			Return -1;
		End

	Return @@Error;
end
go

Create Proc [bhp].AddStageType (
	@SessID varchar(256),
	@Name nvarchar(100),
	@AllowedInHopSched bit = 0,
	@AllowedInYeastSched bit = 0,
	@AllowedInMashSched bit = 0,
	@AllowedInAgingSched bit = 0,
	@AKA1 nvarchar(100) = Null,
	@AKA2 nvarchar(100) = Null,
	@AKA3 nvarchar(100) = Null,
	@Comment nvarchar(1000) = null,
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
	Declare @EvntNm nvarchar(100) = N'Stage';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * from [bhp].StageTypes Where Name = @Name)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66050; -- this nbr represents attempting to add a duplicate stage name...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Insert Into [bhp].StageTypes (
		Name, AllowedInAgingSched, AllowedInHopSched, AllowedInMashSched, AllowedInYeastSched, AKA1, AKA2, AKA3, EnteredOn, Comment, Lang
	)
	Select
		RTRIM(LTRIM(@Name)),
		ISNULL(@AllowedInAgingSched,0),
		ISNULL(@AllowedInHopSched,0),
		ISNULL(@AllowedInMashSched,0),
		ISNULL(@AllowedInYeastSched,0),
		Case When @AKA1 = 'not set' Then Null Else [di].[fn_IsNull](@AKA1) End,
		Case When @AKA2 = 'not set' Then Null Else [di].[fn_IsNull](@AKA2) End,
		Case When @AKA3 = 'not set' Then Null Else [di].[fn_IsNull](@AKA3) End,
		GETDATE(),
		ISNULL(Case When @Comment = 'pls enter a comment...' Then Null Else RTRIM(LTRIM(@Comment)) End, 'no comment given...'),
		N'en_us';

	Set @RowID = SCOPE_IDENTITY();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpStageTypeMesg @id = @rowid, @evnttype='add', @SessID = @SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;
	End

	Return ISNULL(@rc, 0);
End
go

Create Proc [bhp].DelStageType (
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
	Declare @EvntNm nvarchar(100) = N'Stage';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
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
		where fkc.referenced_object_id = OBJECT_ID(N'[bhp].StageTypes',N'U') And (fkc.parent_object_id > @TblID) And (@Found = 0)
	)
	Begin

		Select Top (1) @TblID = fkc.parent_object_id, @TblNm = OBJECT_NAME(fkc.parent_object_id), @ColNm = c.[Name]
		From sys.foreign_key_columns fkc
		Inner join sys.columns c on (fkc.parent_object_id = c.object_id and c.column_id = fkc.parent_column_id)
		Where fkc.referenced_object_id = OBJECT_ID(N'[bhp].StageTypes',N'U') And (fkc.parent_object_id > @TblID)
		Order By fkc.parent_object_id;

		Set @Sql = N'
--set nocount on;
If Exists (Select * from [bhp].[' + @TblNm +  '] Where ([' + @ColNm + '] = @InRowID))
	Set @OutFound=1;
';

		Exec [dbo].sp_ExecuteSql @Stmt=@Sql, @Params=N'@InRowID int, @OutFound bit output', @InRowID=@RowID, @OutFound=@Found output;

	End

	/*
	** Big check here...can't remove a stage item if used anywhere within system design...
	*/

	--If Exists (
	--	Select 1 from [bhp].AgingSchedDetails Where (fk_Stage = @RowID)
	--) Or Exists (
	--	Select 1 from [bhp].RecipeYeasts Where (fk_Stage = @RowID)
	--) Or Exists (
	--	Select 1 from [bhp].RecipeGrains Where (fk_Stage = @RowID)
	--) Or Exists (
	--	Select 1 from [bhp].RecipeIngredients Where (fk_Stage = @RowID)
	--) Or Exists (
	--	Select 1 from [bhp].MashSchedDetails Where (fk_StageTypID = @RowID)
	--) Or Exists (
	--	Select 1 from [bhp].HopSchedDetails Where (fk_Stage = @RowID)
	--)

	If (@Found = 1) -- somewhere in system the stage is used...abort!!!
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66051; -- this nbr represents that user cannot remove stage because it is in use...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpStageTypeMesg @id = @rowid, @evnttype='del', @SessID = @SessID, @Mesg = @xml output;
	
	Delete Top (1) [bhp].StageTypes Where RowID = @RowID;
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;

	Return ISNULL(@rc, 0);
End
go

Create Proc [bhp].ChgStageType (
	@SessID varchar(256),
	@Name nvarchar(100) = null,
	@AllowedInHopSched bit = 0,
	@AllowedInYeastSched bit = 0,
	@AllowedInMashSched bit = 0,
	@AllowedInAgingSched bit = 0,
	@AKA1 nvarchar(100) = Null,
	@AKA2 nvarchar(100) = Null,
	@AKA3 nvarchar(100) = Null,
	@Comment nvarchar(1000) = null,
	@BCastMode bit = 1,
	@RowID int
)
with encryption
as
Begin

	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table([Name] nvarchar(100));
	Declare @old nvarchar(100);
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'Stage';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @rc = 0;

	Update Top (1) [bhp].StageTypes
		Set Name = ISNULL(RTRIM(LTRIM(@Name)), (select top (1) Name from [bhp].StageTypes Where RowID=@RowID)),
			AllowedInAgingSched = ISNULL(@AllowedInAgingSched,0),
			AllowedInHopSched = ISNULL(@AllowedInHopSched, 0),
			AllowedInMashSched = ISNULL(@AllowedInMashSched,0),
			AllowedInYeastSched = ISNULL(@AllowedInYeastSched, 0),
			AKA1 = Case When @AKA1 = 'not set' Then Null Else [di].[fn_IsNull](@AKA1) End,
			AKA2 = Case When @AKA2 = 'not set' Then Null Else [di].[fn_IsNull](@AKA2) End,
			AKA3 = Case When @AKA3 = 'not set' Then Null Else [di].[fn_IsNull](@AKA3) End,
			Comment = ISNULL(Case When @Comment = 'pls enter a comment...' Then Null Else RTRIM(LTRIM(@Comment)) End, 'no comment set...')
	Output deleted.[Name] into @oldinfo([Name])
	Where (RowID = @RowID) And (RowID > 0);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @old = [Name] from @oldinfo;

		exec @rc = [bhp].GenBurpStageTypeMesg @id = @rowid, @evnttype='chg', @SessID = @SessID, @mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:Stage_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;
	End

	return ISNULL(@Rc, @@ERROR);
End
go

/*
exec [bhp].getStageTypes @SessID = '00000000-0000-0000-0000-000000000000';
*/

checkpoint