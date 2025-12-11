use [BHP1-RO]
go

begin try
	drop proc [bhp].GetRecipeYeasts;
	print 'proc: [bhp].GetRecipeYeasts dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].GetRecipeYeasts doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].AddRecipeYeast;
	print 'proc: [bhp].AddRecipeYeast dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].AddRecipeYeast doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].DelRecipeYeast;
	print 'proc: [bhp].DelRecipeYeast dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].DelRecipeYeast doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].ChgRecipeYeast;
	print 'proc: [bhp].ChgRecipeYeast dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].ChgRecipeYeast doesn''t exist...no prob!!!',0,1);
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeYeasts (
	@SessID varchar(256),
	@RecipeID int
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
		RowID, 
		fk_RecipeJrnlMstrID, 
		fk_YeastMstrID, 
		fk_YeastUOM, 
		Convert(numeric(10,2),ISNULL(QtyOrAmount, 0.00)) As QtyOrAmount, 
		ISNULL(fk_Stage, 0) As fk_Stage,
		ISNULL(Comment, 'no comment given...') As Comment
	FROM [bhp].RecipeYeasts
	WHERE (fk_RecipeJrnlMstrID = @RecipeID);

	return @rc;
end
go

create proc [bhp].AddRecipeYeast (
	@SessID varchar(256),
	@fk_RecipeJrnlMstrID int,
	@fk_YeastMstrID int,
	@fk_YeastUOM int,
	@fk_StageID int,
	@QtyOrAmt numeric(10,4),
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
	Declare @isCloud varchar(40);
	
	Set @rc = 0;

	--Raiserror(N'proc:: [bhp].AddRecipeYeast -> @fk_RecipeJrnlMstrID:[%d] @fk_YeastMstrID:[%d]...',0,1,@fk_RecipeJrnlMstrID, @fk_YeastMstrID);
	
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

	If Not Exists (Select * from [bhp].YeastMstr Where RowID = @fk_YeastMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66045; -- represents an unknown Yeast
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].StageTypes Where RowID = @fk_StageID and AllowedInYeastSched=1)
	Begin
		-- should write and audit record here...
		Set @rc = 66081; -- represents stage value is not setup for yeast
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_YeastUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	insert into [bhp].RecipeYeasts (
		fk_RecipeJrnlMstrID, 
		fk_YeastMstrID, 
		fk_YeastUOM, 
		QtyOrAmount, 
		fk_Stage, 
		OpCost, 
		fk_OpCostUOM, 
		Comment
	)
	select 
		@fk_RecipeJrnlMstrID, 
		@fk_YeastMstrID, 
		@fk_YeastUOM, 
		@QtyOrAmt, 
		@fk_StageID, 
		0,
		0, 
		ISNULL(@Comment,'no comment given...');

	Set @RowID = SCOPE_IDENTITY();
	
	--exec [bhp].GetEnv @VarNm='cloud context mode',@VarVal=@isCloud output;
	--if ([bhp].fn_ISTRUE(@isCloud) = 1)
	--	set @BCastMode = 0;


	--if (@BCastMode = 1)
	--Begin
	--	Exec @rc = [bhp].GenRecipeYeastMesg @rid=@fk_RecipeJrnlMstrID, @yid=@fk_YeastMstrID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;
	--End

	return @@ERROR;
end
go

create proc [bhp].DelRecipeYeast (
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
	Declare @rid int;
	Declare @yid int;
	Declare @isCloud varchar(40);
	
	Set @rc = 0;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--exec [bhp].GetEnv @VarNm='cloud context mode',@VarVal=@isCloud output;
	--if ([bhp].fn_ISTRUE(@isCloud) = 1)
	--	set @BCastMode = 0;

	--if (@BCastMode = 1)
	--begin
	--	Select @rid=fk_RecipeJrnlMstrID, @yid=fk_YeastMstrID from [bhp].RecipeYeasts Where (RowID = @RowID);
	
	--	Exec @rc = [bhp].GenRecipeYeastMesg @rid=@rid, @yid=@yid, @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	--end
	
	Delete [bhp].RecipeYeasts Where (RowID = @RowID);
	
	--if (@BCastMode = 1)
	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;

	return @@ERROR;
end
go

create proc [bhp].ChgRecipeYeast (
	@SessID varchar(256),
	@RowID int,
	@fk_RecipeJrnlMstrID int,
	@fk_YeastMstrID int,
	@fk_YeastUOM int,
	@fk_StageID int,
	@QtyOrAmt numeric(10,4),
	@Comment nvarchar(4000),
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @xml xml;
	--Declare @oldinfo Table (oldyeastid int, oldstageid int, oldamt numeric(10,4), olduom int, rid int);
	--Declare @ystNm nvarchar(256);
	--Declare @stgNm varchar(50);
	--Declare @amt numeric(10,4);
	--Declare @mfrNm nvarchar(300);
	--Declare @uomNm varchar(50);
	--Declare @recipeNm nvarchar(256);
	--Declare @isCloud varchar(40);
	
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

	If Not Exists (Select * from [bhp].YeastMstr Where RowID = @fk_YeastMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66032; -- represents an unknown Yeast
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].StageTypes Where RowID = @fk_StageID and AllowedInYeastSched=1)
	Begin
		-- should write and audit record here...
		Set @rc = 66081; -- represents stage value is not setup for mashing
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_YeastUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Update [bhp].RecipeYeasts
		Set
		fk_RecipeJrnlMstrID = @fk_RecipeJrnlMstrID,
		fk_YeastMstrID = @fk_YeastMstrID,
		fk_YeastUOM = @fk_YeastUOM,
		fk_Stage = @fk_StageID,
		QtyOrAmount = ISNULL(@QtyOrAmt, 0),
		Comment = ISNULL([di].[fn_IsNull](@Comment), 'no comment given...')
	--Output Deleted.fk_YeastMstrID, Deleted.fk_Stage, Deleted.QtyOrAmount, Deleted.fk_YeastUOM, Deleted.fk_RecipeJrnlMstrID
	--Into @oldinfo(oldyeastid,oldstageid,oldamt,olduom,rid)
	Where (RowID = @RowID);

	--exec [bhp].GetEnv @VarNm='cloud context mode',@VarVal=@isCloud output;
	--if ([bhp].fn_ISTRUE(@isCloud) = 1)
	--	set @BCastMode = 0;

	-- grab our old value(s) and stuff into xml message before it gets sent out.
	--if (@BCastMode = 1)
	--Begin
	--	select 
	--		@ystNm=Y.[Name], @mfrNm=M.[Name], @stgNm=S.[Name], @amt=oldamt, @uomNm=U.[UOM],@recipeNm=R.[Name]
	--	from @oldinfo I
	--	Inner Join [bhp].YeastMstr Y On (I.oldyeastid = Y.RowID)
	--	Inner Join [bhp].StageTypes S On (I.oldstageid = S.RowID)
	--	Inner Join [bhp].YeastManufacturers M On (Y.fk_YeastMfr = M.RowID)
	--	Inner Join [bhp].UOMTypes U On (I.olduom = U.RowID)
	--	Inner Join [bhp].RecipeJrnlMstr R On (I.rid = R.RowID);
	
	--	Exec @rc = [bhp].GenRecipeYeastMesg @rid=@fk_RecipeJrnlMstrID, @yid=@fk_YeastMstrID, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@ystNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Yeasts/b:Yeast/b:Name)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@mfrNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Yeasts/b:Yeast/b:MfrInfo)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@stgNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Yeasts/b:Yeast/b:Stage)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@amt")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Yeasts/b:Yeast/b:Qty/b:Amt)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@uomNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Yeasts/b:Yeast/b:Qty/b:UOM)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@recipeNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info/b:Name)[1]
	--	');

	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;
	--End

	return @@ERROR;
end
go

checkpoint
go