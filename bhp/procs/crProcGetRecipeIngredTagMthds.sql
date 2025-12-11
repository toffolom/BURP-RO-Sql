use [BHP1-RO]
go

begin try
	drop proc [bhp].GetRecipeIngredientTags;
	print 'proc: [bhp].GetRecipeIngredientTags dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].GetRecipeIngredientTags doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].AddRecipeIngredientTag;
	print 'proc: [bhp].AddRecipeIngredientTag dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].AddRecipeIngredientTag doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].DelRecipeIngredientTag;
	print 'proc: [bhp].DelRecipeIngredientTag dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].DelRecipeIngredientTag doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].ChgRecipeIngredientTag;
	print 'proc: [bhp].ChgRecipeIngredientTag dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].ChgRecipeIngredientTag doesn''t exist...no prob!!!',0,1);
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeIngredientTags (
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
		T.RowID,
		T.fk_RecipeIngredient,
		T.fk_TagID,
		W.Name,
		RI.Phrase
	FROM [bhp].RecipeJrnlMstr M
	Inner join [bhp].RecipeIngredients RI ON (M.RowID = RI.fk_RecipeJrnlMstrID And M.RowID = @RecipeID)
	Inner Join [bhp].RecipeIngredient_Tags T On (RI.RowID = T.fk_RecipeIngredient)
	Inner Join [bhp].BHPTagWords W On (T.fk_TagID = W.RowID)
	Full Outer Join [bhp].GCTagWords GC On (W.Name = GC.Tag)
	Where GC.Tag is null;

	return @@ERROR;
end
go

create proc [bhp].AddRecipeIngredientTag (
	@SessID varchar(256),
	@fk_RecipeIngredient bigint,
	@fk_TagID bigint,
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

	--Raiserror(N'proc:: [bhp].AddRecipeIngredientTag -> @fk_RecipeIngredient:[%I64d] @fk_IngredientItemID:[%I64d] @pos:[%d]...',0,1,@fk_RecipeIngredient, @fk_IngredientItemID, @pos);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].BHPTagWords Where RowID = @fk_TagID)
	Begin
		-- should write and audit record here...
		Set @rc = 66085; -- unkn bhp tag word id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].RecipeIngredients Where (RowID = @fk_RecipeIngredient))
	Begin
		-- should write and audit record here...
		Set @rc = 66092; -- can't find reference up to the parent here...so i can avoid a nasty sql ref integrity error!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	insert into [bhp].RecipeIngredient_Tags(fk_RecipeIngredient, fk_TagID)
	values (@fk_RecipeIngredient, @fk_TagID);

	Set @RowID = SCOPE_IDENTITY();

	--if (@BCastMode = 1)
	--begin
	--	Exec @rc = [bhp].GenRecipeIngredientTagMesg @rowid=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;
	--end

	return @@ERROR;
end
go

create proc [bhp].DelRecipeIngredientTag (
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
	
	Set @rc = 0;

	--Raiserror(N'proc:: [bhp].DelRecipeIngredientTag -> @RowID:[%I64d]...',0,1,@RowID);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--if (@BCastMode = 1)
	--	Exec @rc = [bhp].GenRecipeIngredientTagMesg @rowid=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].RecipeIngredient_Tags Where (RowID = @RowID);
	
	--if (@BCastMode = 1)
	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;

	return @@ERROR;
end
go

create proc [bhp].ChgRecipeIngredientTag (
	@SessID varchar(256),
	@RowID bigint,
	@fk_RecipeIngredient bigint,
	@fk_TagID bigint,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @xml xml;
	--Declare @info Table (tagID bigint); -- grab the old ingredient tag word id.
	--Declare @oldWord nvarchar(100);
	--Declare @oldphrase varchar(1000);
	
	Set @rc = 0;

	--Raiserror(N'proc:: [bhp].ChgRecipeIngredientTag -> @RowID:[%I64d] @fk_RecipeIngredient:[%I64d] @fk_IngredientItemID:[%I64d] @pos:[%d]...',0,1,@RowID,@fk_RecipeIngredient, @fk_IngredientItemID, @pos);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].BHPTagWords Where RowID = @fk_TagID)
	Begin
		-- should write and audit record here...
		Set @rc = 66085; -- unkn bhp tag word id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--if (@BCastMode = 1)
	--begin
	--	select @oldphrase = ISNULL(Phrase,'')
	--	from [bhp].RecipeIngredients RI
	--	Inner Join [bhp].RecipeIngredient_Tags T 
	--	On (RI.RowID = T.fk_RecipeIngredient)
	--	Where (T.RowID = @RowID);
	--end

	Update [bhp].RecipeIngredient_Tags
		Set
			fk_RecipeIngredient = @fk_RecipeIngredient,
			fk_TagID = @fk_TagID
	--Output Deleted.fk_TagID into @info(tagID)
	Where (RowID = @RowID);

	--if (@BCastMode = 1)
	--begin
	--	select @oldWord=I.Name
	--	from @info O
	--	Inner Join [bhp].BHPTagWords I On (I.RowID = O.tagID);

	--	Exec @rc = [bhp].GenRecipeIngredientTagMesg @rowid=@RowID, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;
		
	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldWord")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredient/b:Tag/b:Value)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldphrase")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredient/b:Phrase)[1]
	--	');

	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;
	--end

	return @@ERROR;
end
go

checkpoint
go