use [BHP1-RO]
go

begin try
	drop proc [bhp].GetExtractMasterRecs;
	print 'proc: [bhp].GetExtractMasterRecs dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].GetExtractMasterRecs doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].AddExtractMasterRec;
	print 'proc: [bhp].AddExtractMasterRec dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].AddExtractMasterRec doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].DelExtractMasterRec;
	print 'proc: [bhp].DelExtractMasterRec dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].DelExtractMasterRec doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].ChgExtractMasterRec;
	print 'proc: [bhp].ChgExtractMasterRec dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].ChgExtractMasterRec doesn''t exist...no prob!!!',0,1);
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetExtractMasterRecs (
	@SessID varchar(256)
)
with encryption
as
begin

	declare @rc int;
	declare @mesg nvarchar(2000);

	Set @rc = 0;

	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
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
		,[KnownAs1]
		,[KnownAs2]
		,[KnownAs3]
		,ISNULL([fk_ExtractMfrID],0) As [fk_ExtractMfrID]
		--,[ExtractMfrNm]
		,ISNULL([NbrOfRecipesUsedIn],0) As [NbrOfRecipesUsedIn]
		,ISNULL([fk_SolidUOM],0) As [fk_SolidUOM]
		--,[SolidUOM]
		,ISNULL([BegSolidsAmt],0.00) As [BegSolidsAmt]
		,ISNULL([EndSolidsAmt],0.00) As [EndSolidsAmt]
		,ISNULL([fk_ColorUOM],0) As [fk_ColorUOM]
		--,[ColorUOM]
		,ISNULL([BegColorAmt],0.00) As [BegColorAmt]
		,ISNULL([EndColorAmt],0.00) As [EndColorAmt]
		,ISNULL([fk_BitternessUOM],0) As [fk_BitternessUOM]
		--,[BitternessUOM]
		,ISNULL([BegBitternessAmt],0.00) As [BegBitternessAmt]
		,ISNULL([EndBitternessAmt],0.00) As [EndBitternessAmt]
		,ISNULL([IsHopped],0) As IsHopped
		,ISNULL([fk_HopUOM],0) As [fk_HopUOM]
		--,[HopUOM]
		,ISNULL([HopAmt],0.00) As [HopAmt]
		,ISNULL([IsDiastatic],0) As [IsDiastatic]
		--,[EnteredOn]
		--,[EnteredBy]
		,ISNULL(Comment, 'no comment given...') As Comment
	FROM [bhp].ExtractMstr
	WHere (RowID > 0)
	Order By [Name];

	return @rc;
end
go

create proc [bhp].AddExtractMasterRec (
	@SessID varchar(256),
	@Name nvarchar(256),
	@AKA1 nvarchar(245) = null,
	@AKA2 nvarchar(245) = null,
	@AKA3 nvarchar(245) = null,
	@fk_MfrID int,
	@fk_SolidUOMID int,
	@begSolidAmt numeric(5,2),
	@endSolidAmt numeric(5,2),
	@fk_ColorUOMID int,
	@begColorAmt numeric(6,2),
	@endColorAmt numeric(6,2),
	@fk_BitternessUOMID int,
	@begBitterAmt numeric(6,2),
	@endBitterAmt numeric(6,2),
	@isHopped bit,
	@fk_HopUOMID int,
	@HopAmt numeric(6,2),
	@isDiastic bit,
	@Comment nvarchar(4000),
	@RowID int output,
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @EvntNm nvarchar(100) = N'Extract';
	
	Set @rc = 0;

	--Raiserror(N'proc:: [bhp].AddExtractMasterRec -> @fk_RecipeJrnlMstrID:[%d] @fk_ExtractMstrID:[%d]...',0,1,@fk_RecipeJrnlMstrID, @fk_ExtractMstrID);
	
	If Not Exists (Select 1 from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if (ISNULL(@HopAmt,0) < 0)
	begin
		-- should write and audit record here...
		Set @rc = 66071; -- qty/amt values must be positive
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	If Exists (Select 1 from [bhp].ExtractMstr Where Name = @Name)
	Begin
		-- should write and audit record here...
		Set @rc = 66100; -- represents duplicate extract name
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select 1 from [bhp].ExtractManufacturers Where RowID = @fk_MfrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66101; -- represents an unknown Extract mfr
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].UOMTypes 
		Where RowID = ISNULL(@fk_HopUOMID,0) and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1)
	)
	Begin
		-- should write and audit record here...
		Set @rc = 66015; -- uom key not setup to measure (volume or weight)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].UOMTypes 
		Where RowID = ISNULL(@fk_BitternessUOMID,0) and AllowedAsBitterMeasure=1
	)
	Begin
		-- should write and audit record here...
		Set @rc = 66074; -- uom key not setup to measure (bitterness)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].UOMTypes 
		Where RowID = ISNULL(@fk_ColorUOMID,0) and AllowedAsColorMeasure=1
	)
	Begin
		-- should write and audit record here...
		Set @rc = 66073; -- uom key not setup to measure (color)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].UOMTypes 
		Where RowID = ISNULL(@fk_SolidUOMID,0) and AllowedAsVolumnMeasure=1
	)
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volumn)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	insert into [bhp].ExtractMstr (
		[Name]
		,[KnownAs1]
		,[KnownAs2]
		,[KnownAs3]
		,[fk_ExtractMfrID]
		,[NbrOfRecipesUsedIn]
		,[fk_SolidUOM]
		,[BegSolidsAmt]
		,[EndSolidsAmt]
		,[fk_ColorUOM]
		,[BegColorAmt]
		,[EndColorAmt]
		,[fk_BitternessUOM]
		,[BegBitternessAmt]
		,[EndBitternessAmt]
		,[IsHopped]
		,[fk_HopUOM]
		,[HopAmt]
		,[IsDiastatic]
		,[EnteredOn]
		,[EnteredBy]
		,[Comment]
	)
	select 
		@Name
		,[di].[fn_IsNull](@AKA1)
		,[di].[fn_IsNull](@AKA2)
		,[di].[fn_IsNull](@AKA3)
		,ISNULL(@fk_MfrID,0)
		,0
		,ISNULL(@fk_SolidUOMID,0)
		,ISNULL(@begSolidAmt,0.00)
		,ISNULL(@endSolidAmt,0.00)
		,ISNULL(@fk_ColorUOMID,0)
		,ISNULL(@begColorAmt,0.00)
		,ISNULL(@endColorAmt,0.00)
		,ISNULL(@fk_BitternessUOMID,0)
		,ISNULL(@begBitterAmt,0.00)
		,ISNULL(@endBitterAmt,0.00)
		,ISNULL(@isHopped,0)
		,ISNULL(@fk_HopUOMID,0)
		,ISNULL(@HopAmt,0.00)
		,ISNULL(@isDiastic,0)
		,GetDate()
		,SUSER_NAME()
		,ISNULL(@Comment,'no comment given...');

	Set @RowID = SCOPE_IDENTITY();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Exec [bhp].GenBurpExtractMstrMesg @id=@RowID, @evnttype='add', @SessID=@SessID, @mesg=@xml output;
		Exec [bhp].PostToBWPRouter @inMsg=@xml, @msgNm=@EvntNm;
	end

	return @@ERROR;
end
go

create proc [bhp].DelExtractMasterRec (
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
	Declare @EvntNm nvarchar(100) = N'Extract';
	
	Set @rc = 0;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec [bhp].GenBurpExtractMstrMesg @id=@RowID, @evnttype='del', @SessID=@SessID, @mesg=@xml output;
		
	Delete Top (1) [bhp].ExtractMstr Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec [bhp].PostToBWPRouter @inMsg=@xml, @msgNm=@EvntNm;
	
	return @@ERROR;
end
go

create proc [bhp].ChgExtractMasterRec (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(256),
	@AKA1 nvarchar(245) = null,
	@AKA2 nvarchar(245) = null,
	@AKA3 nvarchar(245) = null,
	@fk_MfrID int,
	@fk_SolidUOMID int,
	@begSolidAmt numeric(5,2),
	@endSolidAmt numeric(5,2),
	@fk_ColorUOMID int,
	@begColorAmt numeric(6,2),
	@endColorAmt numeric(6,2),
	@fk_BitternessUOMID int,
	@begBitterAmt numeric(6,2),
	@endBitterAmt numeric(6,2),
	@isHopped bit,
	@fk_HopUOMID int,
	@HopAmt numeric(6,2),
	@isDiastic bit,
	@Comment nvarchar(4000),
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table ([Name] nvarchar(256));
	Declare @oldnm nvarchar(256);
	Declare @EvntNm nvarchar(100) = N'Extract';
	
	Set @rc = 0;
	
	If Not Exists (Select 1 from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if (ISNULL(@HopAmt,0) < 0)
	begin
		-- should write and audit record here...
		Set @rc = 66071; -- qty/amt values must be positive
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	If Exists (Select 1 from [bhp].ExtractMstr Where Name = @Name And RowID != @RowID)
	Begin
		-- should write and audit record here...
		Set @rc = 66100; -- represents duplicate extract name
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select 1 from [bhp].ExtractManufacturers Where RowID = @fk_MfrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66101; -- represents an unknown Extract mfr
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].UOMTypes 
		Where RowID = ISNULL(@fk_HopUOMID,0) and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1)
	)
	Begin
		-- should write and audit record here...
		Set @rc = 66015; -- uom key not setup to measure (volume or weight)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].UOMTypes 
		Where RowID = ISNULL(@fk_BitternessUOMID,0) and AllowedAsBitterMeasure=1
	)
	Begin
		-- should write and audit record here...
		Set @rc = 66074; -- uom key not setup to measure (bitterness)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].UOMTypes 
		Where RowID = ISNULL(@fk_ColorUOMID,0) and AllowedAsColorMeasure=1
	)
	Begin
		-- should write and audit record here...
		Set @rc = 66073; -- uom key not setup to measure (color)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].UOMTypes 
		Where RowID = ISNULL(@fk_SolidUOMID,0) and AllowedAsVolumnMeasure=1
	)
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volumn)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Update [bhp].ExtractMstr
		Set
			[Name]=@Name
			,KnownAs1=[di].[fn_IsNull](@AKA1)
			,KnownAs2=[di].[fn_IsNull](@AKA2)
			,KnownAs3=[di].[fn_IsNull](@AKA3)
			,fk_ExtractMfrID=ISNULL(@fk_MfrID,0)
			,fk_SolidUOM=ISNULL(@fk_SolidUOMID,0)
			,BegSolidsAmt=ISNULL(@begSolidAmt,0.00)
			,EndSolidsAmt=ISNULL(@endSolidAmt,0.00)
			,fk_ColorUOM=ISNULL(@fk_ColorUOMID,0)
			,BegColorAmt=ISNULL(@begColorAmt,0.00)
			,EndColorAmt=ISNULL(@endColorAmt,0.00)
			,fk_BitternessUOM=ISNULL(@fk_BitternessUOMID,0)
			,BegBitternessAmt=ISNULL(@begBitterAmt,0.00)
			,EndBitternessAmt=ISNULL(@endBitterAmt,0.00)
			,IsHopped=ISNULL(@isHopped,0)
			,fk_HopUOM=ISNULL(@fk_HopUOMID,0)
			,HopAmt=ISNULL(@HopAmt,0.00)
			,IsDiastatic=ISNULL(@isDiastic,0)
			,Comment=ISNULL(@Comment,'no comment given...')
	Output Deleted.Name into @oldinfo([Name])
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Exec [bhp].GenBurpExtractMstrMesg @id=@RowID, @evnttype='chg', @SessID=@SessID, @mesg=@xml output;

		Select @oldnm = [Name] from @oldinfo;

		Set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldnm")}
			into (/b:Burp_Belch/b:Payload/b:Extract_Evnt/b:Mstr_Info/b:Name)[1]
		');

		Exec [bhp].PostToBWPRouter @inMsg=@xml, @msgNm=@EvntNm;
	end

	return @@ERROR;
end
go

checkpoint
go