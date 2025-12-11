USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[getUOMTypes]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[getUOMTypes]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[getUOMTypes];
	Print 'Proc:: [bhp].getUOMTypes dropped!!!';
End
GO

IF (OBJECT_ID(N'[bhp].[getUOMTypeDefsForDD]') IS NOT NULL)
Begin
	DROP PROCEDURE [bhp].[getUOMTypeDefsForDD];
	Print 'Proc:: [bhp].getUOMTypeDefsForDD dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[AddUOMType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[AddUOMType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[AddUOMType];
	Print 'Proc:: [bhp].AddUOMType dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[DelUOMType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DelUOMType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[DelUOMType];
	Print 'Proc:: [bhp].DelUOMType dropped!!!';
End
GO

/****** Object:  StoredProcedure [bhp].[ChgUOMType]    Script Date: 03/15/2011 15:59:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ChgUOMType]') AND type in (N'P', N'PC'))
Begin
	DROP PROCEDURE [bhp].[ChgUOMType];
	Print 'Proc:: [bhp].ChgUOMType dropped!!!';
End
GO

create proc [bhp].getUOMTypes (
	@SessID varchar(256),
	@OnlyTimeTypes bit = 1,
	@OnlyVolumnTypes bit = 1,
	@OnlyTempTypes bit = 1,
	@OnlyContainerTypes bit = 1,
	@OnlyColorTypes bit = 1,
	@OnlyBitterTypes bit = 1,
	@OnlyWeightTypes bit = 1,
	@OnlyMonetaryTypes bit = 1,
	@Lang nvarchar(20) = N'en_us'
)
with encryption, execute as 'sticky'
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @sql nvarchar(max);
	Declare @status bit;

	if (1=0)
	begin
		Select 
			cast(null as int) As RowID
			,cast (null as nvarchar(50)) As UOM
			,cast(null as nvarchar(100)) As [Name]
			,cast(null as bit) As AllowedAsTimeMeasure
			,cast(null as bit) As AllowedAsVolumnMeasure
			,cast(null as bit) As AllowedAsTemperature
			,cast(null as bit) As AllowedAsContainer
			,cast(null as bit) As AllowedAsColorMeasure
			,cast(null as bit) As AllowedAsBitterMeasure
			,cast(null as bit) As AllowedAsWeightMeasure
			,cast(null as bit) As AllowedAsMonetary
			,cast(null as varchar(1000)) As Comment
			,cast(null as nvarchar(20)) As [Lang]
			,cast(null as varchar(50)) as MinVal
			,cast(null as varchar(50)) as MaxVal
		Set FmtOnly Off;
		Return;
	end
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
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
--set nocount on;
Select 
	RowID
	,UOM
	,[Name]
	,ISNULL(AllowedAsTimeMeasure,0) As AllowedAsTimeMeasure
	,ISNULL(AllowedAsVolumnMeasure,0) As AllowedAsVolumnMeasure
	,ISNULL(AllowedAsTemperature,0) As AllowedAsTemperature
	,ISNULL(AllowedAsContainer,0) As AllowedAsContainer
	,ISNULL(AllowedAsColorMeasure,0) As AllowedAsColorMeasure
	,ISNULL(AllowedAsBitterMeasure,0) As AllowedAsBitterMeasure
	,ISNULL(AllowedAsWeightMeasure,0) As AllowedAsWeightMeasure
	,ISNULL(AllowedAsMonetary,0) As AllowedAsMonetary
	,ISNULL(Comment,''no comment given...'') As Comment
	,ISNULL(Lang, @inLang) As [Lang]
	,ISNULL(MinVal, ''N/A'') As MinVal
	,ISNULL(MaxVal, ''N/A'') As MaxVal
From [bhp].UOMTypes Where (RowID > 0)
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

print 'Proc:: [bhp].getUOMTypes created...';
go

Create Proc [bhp].getUOMTypeDefsForDD (
	@SessID varchar(256),
	@Lang nvarchar(20) = N'en_us',
	@Type nvarchar(50) = 'all',
	@IncPlsSel bit = 1 -- if we should put  on the top of list'n...the 'pls select...' option!?
)
With Encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @sql nvarchar(max);
	Declare @status bit;
	Declare @tbl Table (
		RowID int not null,
		UOM nvarchar(50) not null,
		[Name] nvarchar(100) not null,
		[Type] nvarchar(50) not null,
		[Lang] nvarchar(20) not null,
		[Comment] varchar(1000) null,
		[FakeRowID] int identity(0,1) not null
	);


	if (1=0)
	begin
		Select 
			cast(null as int) As RowID
			,cast (null as nvarchar(50)) As UOM
			,cast(null as nvarchar(100)) As [Name]
			,cast(Null as nvarchar(50)) As [Type]
			,cast(null as nvarchar(20)) As [Lang]
			,cast(null as varchar(1000)) As Comment
		Set FmtOnly Off;
		Return;
	end

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66061; -- non-existant session...or it's expired!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (LEFT(@Type,3) Not In ('all','tim','vol','tem','con','col','bit','wei','mon'))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66145; -- non-existant session...or it's expired!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@Type);
		Return @rc;
	End

	Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment)
	Select RowID, UOM, Name, 'all', 'en_us','make a selection...'
	From [bhp].UOMTypes Where RowID = 0;

	if (@Type = 'all')
	Begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 Order By UOM;
	End
	else if (Left(@Type,3) = 'tim') -- time values only
	begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 And AllowedAsTimeMeasure=1 Order By UOM;
	end
	else if (Left(@Type,3) = 'vol') -- volume values only
	begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 And AllowedAsVolumnMeasure=1 Order By UOM;
	end
	else if (Left(@Type,3) = 'tem') -- temperature values only
	begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 And AllowedAsTemperature=1 Order By UOM;
	end
	else if (Left(@Type,3) = 'con') -- container values only
	begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 And AllowedAsContainer=1 Order By UOM;
	end
	else if (Left(@Type,3) = 'col') -- color values only
	begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 And AllowedAsColorMeasure=1 Order By UOM;
	end
	else if (Left(@Type,3) = 'bit') -- bitterness values only
	begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 And AllowedAsBitterMeasure=1 Order By UOM;
	end
	else if (Left(@Type,3) = 'wei') -- weight values only
	begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 And AllowedAsWeightMeasure=1 Order By UOM;
	end
	else if (Left(@Type,3) = 'mon') -- weight values only
	begin
		Insert Into @tbl (RowID, UOM, Name, Type, Lang, Comment) 
		Select RowID, UOM, Name, @Type, [Lang], ISNULL(Comment,'no comment given...')
		From [bhp].UOMTypes Where RowID > 0 And AllowedAsMonetary=1 Order By UOM;
	end

	Select RowID, UOM, Name, Type, Lang, Comment
	From @tbl WHere FakeRowID > (case ISNULL(@IncPlsSel,1) When 1 Then -1 Else 0 End);

	Return @@Error;

end
go

Print 'Proc:: [bhp].getUOMTypeDefsForDD created...';
go

Create Proc [bhp].AddUOMType (
	@SessID varchar(256),
	@Name nvarchar(100),
	@UOM nvarchar(50),
	@AllowedAsTimeMeasure bit = 0,
	@AllowedAsVolumnMeasure bit = 0,
	@AllowedAsTemperature bit = 0,
	@AllowedAsContainer bit = 0,
	@AllowedAsColorMeasure bit = 0,
	@AllowedAsBitterMeasure bit = 0,
	@AllowedAsWeightMeasure bit = 0,
	@AllowedAsMonetary bit = 0,
	@MinVal varchar(50) null,
	@MaxVal varchar(50) null,
	@Comment varchar(1000) = null,
	@BCastMode bit = 1, -- if we should send xml msg to router!?
	@RowID int output
)
with encryption
as
Begin

	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @EvntNm nvarchar(100) = N'UOM';
	
	Set @BCastMode = ISNULL(@BCastMode,1);

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * from [bhp].UOMTypes Where Name = @Name Or UOM = @UOM)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66058; -- this nbr represents attempting to add a duplicate UOM name...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Insert Into [bhp].UOMTypes (
		[Name]
		,[UOM]
		,[AllowedAsTimeMeasure]
		,[AllowedAsVolumnMeasure]
		,[AllowedAsTemperature]
		,[AllowedAsContainer]
		,[AllowedAsColorMeasure]
		,[AllowedAsBitterMeasure]
		,[AllowedAsWeightMeasure]
		,[AllowedAsMonetary]
		,[MinVal],[MaxVal]
		,[Comment]
		,[EnteredOn]
		,[Lang]
	)
	Select
		RTRIM(LTRIM(@Name)),
		RTRIM(LTRIM(@UOM)),
		ISNULL(@AllowedAsTimeMeasure,0),
		ISNULL(@AllowedAsVolumnMeasure,0),
		ISNULL(@AllowedAsTemperature,0),
		ISNULL(@AllowedAsContainer,0),
		ISNULL(@AllowedAsColorMeasure,0),
		ISNULL(@AllowedAsBitterMeasure,0),
		ISNULL(@AllowedAsWeightMeasure,0),
		ISNULL(@AllowedAsMonetary,0),
		@MinVal, @MaxVal,
		ISNULL(@Comment, 'not set'),
		getdate(),
		N'en_us';

	Set @RowID = SCOPE_IDENTITY();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpUOMTypeMesg @id = @RowID, @evnttype='add', @SessID = @SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;
	End


	Return ISNULL(@rc, 0);
End
go

print 'Proc:: [bhp].AddUOMType created...';
go

Create Proc [bhp].DelUOMType (
	@SessID varchar(256),
	@RowID int, -- primary key value
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
	Declare @status bit;
	Declare @xml xml;
	Declare @EvntNm nvarchar(100) = N'UOM';

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
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
		where fkc.referenced_object_id = OBJECT_ID(N'[bhp].UOMTypes',N'U') And (fkc.parent_object_id > @TblID) And (@Found = 0)
	)
	Begin

		Select Top (1) @TblID = fkc.parent_object_id, @TblNm = OBJECT_NAME(fkc.parent_object_id), @ColNm = c.[Name]
		From sys.foreign_key_columns fkc
		Inner join sys.columns c on (fkc.parent_object_id = c.object_id and c.column_id = fkc.parent_column_id)
		Where fkc.referenced_object_id = OBJECT_ID(N'[bhp].UOMTypes',N'U') And (fkc.parent_object_id > @TblID)
		Order By fkc.parent_object_id;

		Set @Sql = N'
--set nocount on;
If Exists (Select * from [bhp].[' + @TblNm +  '] Where ([' + @ColNm + '] = @InRowID))
	Set @OutFound=1;
';

		Exec [dbo].sp_ExecuteSql @Stmt=@Sql, @Params=N'@InRowID int, @OutFound bit output', @InRowID=@RowID, @OutFound=@Found output;

	End

	If (@Found = 1) -- somewhere in system the UOM is used...abort!!!
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66059; -- this nbr represents that user cannot remove UOM because it is in use...
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpUOMTypeMesg @id = @RowID, @evnttype='del', @SessID = @SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].UOMTypes Where RowID = @RowID;
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;

	Return ISNULL(@rc, 0);
End
go

print 'Proc:: [bhp].DelUOMType created...';
go

Create Proc [bhp].ChgUOMType (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(100),
	@UOM nvarchar(50),
	@AllowedAsTimeMeasure bit = 0,
	@AllowedAsVolumnMeasure bit = 0,
	@AllowedAsTemperature bit = 0,
	@AllowedAsContainer bit = 0,
	@AllowedAsColorMeasure bit = 0,
	@AllowedAsBitterMeasure bit = 0,
	@AllowedAsWeightMeasure bit = 0,
	@AllowedAsMonetary bit = 0,
	@MinVal varchar(50) null,
	@MaxVal varchar(50) null,
	@Comment varchar(1000) = null,
	@BCastMode bit = 1 -- if we should send xml msg to router
)
with encryption
as
Begin

	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @oldinfo Table (UOM nvarchar(50));
	Declare @old nvarchar(50);
	Declare @EvntNm nvarchar(100) = N'UOM';
	
	Set @BCastMode = ISNULL(@BCastMode, 1)

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @rc = 0;

	Update Top (1) [bhp].UOMTypes
		Set [Name] = @Name,
			UOM = @UOM,
			AllowedAsTimeMeasure = ISNULL(@AllowedAsTimeMeasure,0),
			AllowedAsVolumnMeasure = ISNULL(@AllowedAsVolumnMeasure,0),
			AllowedAsTemperature = ISNULL(@AllowedAsTemperature,0),
			AllowedAsContainer = ISNULL(@AllowedAsContainer,0),
			AllowedAsColorMeasure = ISNULL(@AllowedAsColorMeasure,0),
			AllowedAsBitterMeasure = ISNULL(@AllowedAsBitterMeasure,0),
			AllowedAsWeightMeasure = ISNULL(@AllowedAsWeightMeasure,0),
			AllowedAsMonetary = ISNULL(@AllowedAsMonetary,0),
			MinVal = @MinVal,
			MaxVal = @MaxVal,
			Comment = ISNULL(@Comment, 'no comment given...')
		Output deleted.UOM into @oldinfo(UOM)
	Where (RowID = @RowID) And (RowID > 0);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @old = UOM from @oldinfo;

		exec @rc = [bhp].GenBurpUOMTypeMesg @id = @RowID, @evnttype='chg', @SessID = @SessID, @mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:UOM_Evnt/b:Info/b:Abbr)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@EvntNm;
	End

	return ISNULL(@Rc, @@ERROR);
End
go

print 'Proc:: [bhp].ChgUOMType created...';
go

/*
use bhp1
go

exec [bhp].getUOMTypes @SessID = '00000000-0000-0000-0000-000000000000';
go

exec [bhp].getUOMTypeDefsForDD @SessID = '00000000-0000-0000-0000-000000000000',@type='volume',@incplssel=0;
*/

checkpoint