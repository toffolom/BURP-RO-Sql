use [BHP1-RO]
go

begin try
	drop proc [bhp].GetRecipeIngredientsV2;
	print 'proc: [bhp].GetRecipeIngredientsV2 dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].GetRecipeIngredientsV2 doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].AddRecipeIngredientV2;
	print 'proc: [bhp].AddRecipeIngredientV2 dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].AddRecipeIngredientV2 doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].DelRecipeIngredientV2;
	print 'proc: [bhp].DelRecipeIngredientV2 dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].DelRecipeIngredientV2 doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].ChgRecipeIngredientV2;
	print 'proc: [bhp].ChgRecipeIngredientV2 dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].ChgRecipeIngredientV2 doesn''t exist...no prob!!!',0,1);
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeIngredientsV2 (
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
		fk_RecipeJrnlMstrID As [RecipeID],
		ISNULL(QtyOrAmount, 0) As QtyOrAmount,
		fk_IngredientUOM,
		fk_Stage,
		ISNULL(Comment, N'no comment given...') As Comment,
		ISNULL(Phrase,'not set...') As [Phrase],
		PhraseTags
	FROM [bhp].RecipeIngredients
	Where (fk_RecipeJrnlMstrID = @RecipeID);

	return @@ERROR;
end
go

create proc [bhp].AddRecipeIngredientV2 (
	@SessID varchar(256),
	@RecipeID int,
	@QtyOrAmt numeric(10,4),
	@fk_IngredientUOM int,
	@fk_StageID int,
	@Comment nvarchar(4000) = null,
	@Phrase nvarchar(1000),
	@RowID bigint output,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	
	Set @rc = 0;

	--Raiserror(N'proc:: [bhp].AddRecipeIngredientV2 -> @fk_RecipeJrnlMstrID:[%d] @fk_YeastMstrID:[%d]...',0,1,@fk_RecipeJrnlMstrID, @fk_YeastMstrID);
	
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

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where RowID = @RecipeID)
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- represents an unknown recipe
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].StageTypes Where RowID = @fk_StageID)
	Begin
		-- should write and audit record here...
		Set @rc = 66083; -- represents stage value is not setup for yeast
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_IngredientUOM)
	Begin
		-- should write and audit record here...
		Set @rc = 66084; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	insert into [bhp].RecipeIngredients (
		fk_RecipeJrnlMstrID, 
		QtyOrAmount, 
		fk_IngredientUOM, 
		fk_Stage, 
		Phrase, 
		Comment
	)
	values (
		@RecipeID, 
		@QtyOrAmt, 
		@fk_IngredientUOM, 
		@fk_StageID,
		ISNULL(@Phrase,'not set...'),
		ISNULL(@Comment,'no comment given...')
	);
	
	Set @RowID = SCOPE_IDENTITY();

	--if (@BCastMode = 1)
	--begin
	--	Exec @rc = [bhp].GenRecipeIngredientMesgV2 @rid=@RecipeID, @iid=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;
	--end

	return @@ERROR;
end
go

create proc [bhp].DelRecipeIngredientV2 (
	@SessID varchar(256),
	@RowID bigint,
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @rid int;
	
	Set @rc = 0;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--if (@BCastMode = 1)
	--begin
	--	Select @rid = fk_RecipeJrnlMstrID From [bhp].RecipeIngredients Where (RowID = @RowID);
	--	Exec @rc = [bhp].GenRecipeIngredientMesgV2 @rid=@rid, @iid=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	--end

	-- clear out any tag values assoc w/this ingredient entry
	Delete [bhp].RecipeIngredient_Tags
	From [bhp].RecipeIngredient_Tags RT 
	Inner Join [bhp].RecipeIngredients RI On (RT.fk_RecipeIngredient = RI.RowID)
	Where (RI.RowID = @RowID);

	Delete Top (1) [bhp].RecipeIngredients Where (RowID = @RowID);

	--if (@BCastMode = 1)
	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;

	return @@ERROR;
end
go

create proc [bhp].ChgRecipeIngredientV2 (
	@SessID varchar(256),
	@RowID bigint,
	@QtyOrAmt numeric(10,4),
	@fk_IngredientUOM int,
	@fk_StageID int,
	@Comment nvarchar(4000) = null,
	@Phrase nvarchar(1000),
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @rid int;
	Declare @xml xml;
	Declare @oldinfo Table (
		qty numeric(10,4),
		stageID int,
		uomID int,
		oldphrase nvarchar(1000)
	);
	Declare @oldqty numeric(10,4);
	Declare @oldstgnm nvarchar(100);
	Declare @olduomnm varchar(50);
	Declare @oldphrase nvarchar(1000);
	
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

	If Not Exists (Select * from [bhp].StageTypes Where RowID = @fk_StageID)
	Begin
		-- should write and audit record here...
		Set @rc = 66083; -- represents stage value is not setup for yeast
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_IngredientUOM)
	Begin
		-- should write and audit record here...
		Set @rc = 66084; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select 
		@rid = fk_RecipeJrnlMstrID
	From [bhp].RecipeIngredients Where (RowID = @RowID);

	Update [bhp].RecipeIngredients
		Set
			QtyOrAmount = @QtyOrAmt,
			fk_IngredientUOM = @fk_IngredientUOM,
			fk_Stage = @fk_StageID,
			Comment = ISNULL(@Comment,'no comment given...'),
			Phrase = ISNULL(@Phrase,'not set...')
	--Output Deleted.QtyOrAmount, Deleted.fk_Stage, Deleted.fk_IngredientUOM, Deleted.Phrase
	--Into @oldinfo(qty, stageID, uomID, oldphrase)
	Where (RowID = @RowID);

	--if (@BCastMode = 1)
	--begin

	--	select 
	--		@oldqty=I.[qty], 
	--		@oldstgnm=S.[Name], 
	--		@olduomnm=U.[UOM],
	--		@oldphrase = ISNULL([di].[fn_IsNull](I.oldphrase),SPACE(0))
	--	from @oldinfo I
	--	inner join [bhp].StageTypes S On (I.stageID = S.RowID)
	--	Inner Join [bhp].UOMTypes U On (I.uomID = U.RowID);

	--	Exec @rc = [bhp].GenRecipeIngredientMesgV2 @rid=@rid, @iid=@RowID, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldphrase")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredients/b:Ingredient/b:Phrase)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldqty")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredients/b:Ingredient/b:Qty/b:Amt)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@olduomnm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredients/b:Ingredient/b:Qty/b:UOM)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldstgnm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredients/b:Ingredient/b:Stage)[1]
	--	');

	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;
	--end

	return @@ERROR;
end
go

checkpoint
go