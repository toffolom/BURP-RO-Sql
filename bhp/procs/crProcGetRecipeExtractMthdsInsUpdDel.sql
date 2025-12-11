use [BHP1-RO]
go

begin try
	drop proc [bhp].GetRecipeExtracts;
	print 'proc: [bhp].GetRecipeExtracts dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].GetRecipeExtracts doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].AddRecipeExtract;
	print 'proc: [bhp].AddRecipeExtract dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].AddRecipeExtract doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].DelRecipeExtract;
	print 'proc: [bhp].DelRecipeExtract dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].DelRecipeExtract doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].ChgRecipeExtract;
	print 'proc: [bhp].ChgRecipeExtract dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].ChgRecipeExtract doesn''t exist...no prob!!!',0,1);
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeExtracts (
	@SessID varchar(256),
	@RecipeID int
)
with encryption
as
begin
	--set nocount on;

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
		RowID, 
		fk_RecipeJrnlMstrID, 
		fk_ExtractMstrID, 
		fk_QtyOrAmtUOM, 
		Convert(numeric(10,2),ISNULL(QtyOrAmt, 0.00)) As QtyOrAmount, 
		ISNULL(fk_Stage, 0) As fk_Stage,
		ISNULL(Comment, 'no comment given...') As Comment
	FROM [bhp].RecipeExtracts
	WHERE (fk_RecipeJrnlMstrID = @RecipeID);

	return @rc;
end
go

create proc [bhp].AddRecipeExtract (
	@SessID varchar(256),
	@fk_RecipeJrnlMstrID int,
	@fk_ExtractMstrID int,
	@fk_StageID int,
	@fk_UOM int,
	@QtyOrAmt numeric(10,4),
	@Comment nvarchar(4000),
	@RowID int output,
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	
	Set @rc = 0;

	--Raiserror(N'proc:: [bhp].AddRecipeExtract -> @fk_RecipeJrnlMstrID:[%d] @fk_ExtractMstrID:[%d]...',0,1,@fk_RecipeJrnlMstrID, @fk_ExtractMstrID);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if (@QtyOrAmt is null or @QtyOrAmt < 0)
	begin
		-- should write and audit record here...
		Set @rc = 66071; -- qty/amt values must be positive
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where RowID = @fk_RecipeJrnlMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- represents an unknown recipe
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].ExtractMstr Where RowID = @fk_ExtractMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66045; -- represents an unknown Extract
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].StageTypes Where RowID = @fk_StageID and AllowedInHopSched=1)
	Begin
		-- should write and audit record here...
		Set @rc = 66081; -- represents stage value is not setup for Extract
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_UOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	insert into [bhp].RecipeExtracts (fk_RecipeJrnlMstrID, fk_ExtractMstrID, fk_QtyOrAmtUOM, QtyOrAmt, fk_Stage, OpCost, fk_OpCostUOM, Comment)
	select @fk_RecipeJrnlMstrID, @fk_ExtractMstrID, @fk_UOM, @QtyOrAmt, @fk_StageID, 0,0, ISNULL(@Comment,'not set');

	Set @RowID = SCOPE_IDENTITY();

	--if (@BCastMode = 1)
	--begin
	--	exec @rc = [bhp].GenRecipeExtractMesg @rid=@fk_RecipeJrnlMstrID, @eid=@fk_ExtractMstrID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
	--	exec [bhp].SendBurpRecipeMesg @msg = @xml;
	--end

	return @@ERROR;
end
go

create proc [bhp].DelRecipeExtract (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1
)
with encryption
as
begin

	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @xml xml;
	--Declare @rid int;
	--Declare @eid int;
	
	Set @rc = 0;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Select @rid = fk_RecipeJrnlMstrID, @eid = fk_ExtractMstrID
	--From [bhp].RecipeExtracts
	--Where (RowID = @RowID);

	--if (@BCastMode = 1)
	--	exec @rc = [bhp].GenRecipeExtractMesg @rid=@rid, @eid=@eid, @evnttype='del', @SessID=@SessID, @mesg = @xml output;

	Delete Top (1) [bhp].RecipeExtracts Where (RowID = @RowID);
	
	--if (@BCastMode = 1)
	--	exec [bhp].SendBurpRecipeMesg @msg = @xml;

	return @@ERROR;
end
go

create proc [bhp].ChgRecipeExtract (
	@SessID varchar(256),
	@RowID int,
	@fk_RecipeJrnlMstrID int,
	@fk_ExtractMstrID int,
	@fk_UOM int,
	@fk_StageID int,
	@QtyOrAmt numeric(10,4),
	@Comment nvarchar(4000),
	@BCastMode bit = 1
)
with encryption
as
begin

	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @xml xml;
	--Declare @oldinfo Table (extractid int, uomid int, qty numeric(10,4), stageid int, recipeID int);
	--Declare @oldExtractNm nvarchar(256);
	--Declare @olduomnm varchar(50);
	--Declare @oldqty numeric(10,4);
	--Declare @oldstagenm nvarchar(100);
	--Declare @oldExtractMfrNm nvarchar(300);
	--Declare @OldRecipeNm nvarchar(256);
	
	Set @rc = 0;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if (@QtyOrAmt is null or @QtyOrAmt < 0)
	begin
		-- should write and audit record here...
		Set @rc = 66071; -- qty/amt values must be positive
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where RowID = @fk_RecipeJrnlMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- represents an unknown recipe
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].ExtractMstr Where RowID = @fk_ExtractMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66032; -- represents an unknown Extract
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].StageTypes Where RowID = @fk_StageID and AllowedInHopSched=1)
	Begin
		-- should write and audit record here...
		Set @rc = 66081; -- represents stage value is not setup for mashing
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_UOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Update Top (1) [bhp].RecipeExtracts
		Set
		fk_RecipeJrnlMstrID = @fk_RecipeJrnlMstrID,
		fk_ExtractMstrID = @fk_ExtractMstrID,
		fk_QtyOrAmtUOM = @fk_UOM,
		fk_Stage = @fk_StageID,
		QtyOrAmt = ISNULL(@QtyOrAmt, 0),
		Comment = ISNULL(@Comment, 'no comment given...')
	--Output Deleted.fk_ExtractMstrID, Deleted.fk_QtyOrAmtUOM, Deleted.fk_Stage, Deleted.QtyOrAmt, Deleted.fk_RecipeJrnlMstrID
	--Into @oldinfo(extractid, uomid, stageid, qty, recipeID)
	Where (RowID = @RowID);

	-- grab the old name(s) and stuff into the outbound xml doc as attribute(s) 'old' in ea. appropriate place
	--Select @oldExtractNm=E.[Name], @oldstagenm=S.[Name], @olduomnm=U.[UOM], @oldqty=I.qty, @oldExtractMfrNm=M.[Name], @OldrecipeNm=R.Name
	--From @oldinfo I
	--Inner Join [bhp].GrainMstr E On (I.extractid = E.RowID)
	--Inner Join [bhp].StageTypes S On (I.stageid = S.RowID)
	--Inner Join [bhp].UOMTypes U On (I.uomid = U.RowID)
	--Inner Join [bhp].ExtractManufacturers M On (E.fk_GrainMfr = M.RowID)
	--Inner Join [bhp].RecipeJrnlMstr R On (I.recipeID = R.RowID);

	--if (@BCastMode = 1)
	--begin
	--	exec @rc = [bhp].GenRecipeExtractMesg @rid=@fk_RecipeJrnlMstrID, @eid=@fk_ExtractMstrID, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;

	--	-- stuff in the 'old' attr's now...
	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldExtractNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Extracts/b:Extract/b:Name)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldExtractMfrNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Extracts/b:Extract/b:MfrInfo)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@olduomnm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Extracts/b:Extract/b:Qty/b:UOM)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldqty")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Extracts/b:Extract/b:Qty/b:Amt)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldstagenm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Extracts/b:Extract/b:Stage)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldrecipenm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info/b:Name)[1]
	--	');

	--	exec [bhp].SendBurpRecipeMesg @msg = @xml;
	--end

	return @@ERROR;
end
go

checkpoint
go