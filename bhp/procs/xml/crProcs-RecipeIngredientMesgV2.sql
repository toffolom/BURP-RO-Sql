use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeIngredientMesgV2',N'P') is not null
begin
	drop proc [bhp].GenRecipeIngredientMesgV2;
	print 'proc:: [bhp].GenRecipeIngredientMesgV2 dropped!!!';
end
go

create proc [bhp].GenRecipeIngredientMesgV2 (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@iid bigint, -- a ingredient rowid value (from [bhp].RecipeIngredients tbl)
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @StageID int;
	Declare @StageNm nvarchar(200);
	Declare @StyleNm nvarchar(100);
	Declare @fk_IngredientUOMID int;
	Declare @fk_IngredientUOM varchar(50);
	Declare @phrase nvarchar(1000); -- the actual user entered ingredient phrase
	Declare @name varchar(256);
	Declare @Qty numeric(10,4);
	Declare @isDraft bit;
	Declare @Lang varchar(20);
	Declare @SessSrc xml;
	Declare @notes xml;
	--Declare @itemDoc xml;
	--Declare @fragDoc xml;
	Declare @currow bigint;
	Declare @tagval nvarchar(100);
	Declare @tagid bigint;
	Declare @ts varchar(50);
	Declare @seq int; -- sequence of word order
	Declare @custID bigint;
	Declare @custUID nvarchar(256);
	Declare @custNm nvarchar(200);
	Declare @totTags int;

	-- create our stub root node.
	Begin Try
		Exec [bhp].GenBurpBelchRootNode @SessID=@SessID, @Mesg=@Mesg output, @ver='2.0';
	End Try
	Begin Catch
		Return -1;
	End Catch

	-- prime up the rest...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert 
		<b:Recipe_Evnt type=''{sql:variable("@evnttype")}'' recipe_id=''{sql:variable("@rid")}''>
		<b:Info/>
		<b:Ingredients/>
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''ingredient''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get the ingredient from [bhp].RecipeIngredients table
	Select 
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@StageID = RI.fk_Stage,
		@StageNm = S.[Name],
		@phrase = ISNULL(RI.Phrase,N'not given...'),
		@fk_IngredientUOMID = RI.fk_IngredientUOM,
		@fk_IngredientUOM = U.[UOM],
		@Lang = ISNULL(U.Lang,'en_us'),
		@Qty = ISNULL(RI.QtyOrAmount, 0.0),
		@notes = di.fn_ToXMLNote(RI.Comment),
		@ts = [di].fn_Timestamp(M.EnteredOn),
		@custID = C.RowID,
		@custUID = C.BHPUid,
		@custNm = C.[Name],
		@totTags = ISNULL((select count(*) from [bhp].RecipeIngredient_Tags Where fk_RecipeIngredient=@iid),0)
	From [bhp].RecipeJrnlMstr M 
	Inner Join [di].vw_CustomerMstr C On (M.fk_CreatedBy = C.RowID)
	Inner Join [bhp].RecipeIngredients RI On (M.RowID = RI.fk_RecipeJrnlMstrID)
	Inner Join [bhp].UOMTypes U On (RI.fk_IngredientUOM = U.RowID)
	Inner Join [bhp].StageTypes S On (RI.fk_Stage = S.RowID)
	Where (RI.fk_RecipeJrnlMstrID = @rid And RI.RowID = @iid);

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Creator custid=''{sql:variable("@custID")}'' uid=''{sql:variable("@custUID")}''>
				{sql:variable("@custNm")}
			</b:Creator>,
			<b:Name>{sql:variable("@name")}</b:Name>,
			<b:IsDraft>{sql:variable("@isDraft")}</b:IsDraft>,
			<b:CreatedOn>{sql:variable("@ts")}</b:CreatedOn>
		) into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info)[1]
	');

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Ingredient id=''{sql:variable("@iid")}'' lang=''{sql:variable("@Lang")}''>
				<b:Phrase>{sql:variable("@phrase")}</b:Phrase>
				<b:Qty>
					<b:Amt>{sql:variable("@Qty")}</b:Amt>
					<b:UOM id=''{sql:variable("@fk_IngredientUOMID")}''>{sql:variable("@fk_IngredientUOM")}</b:UOM>
				</b:Qty>
				<b:Stage id=''{sql:variable("@StageID")}''>{sql:variable("@StageNm")}</b:Stage>
				<b:Tags tot=''{sql:variable("@totTags")}''/>
			</b:Ingredient>
		)
		as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredients)[1]
	');

	-- add any notes to the ingredient node...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") 
		as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredients/b:Ingredient)[1]
	');

	/*
	** now walk thru the recipeingredientitem table.  this acts as a binder table between all the words in a recipe ingredient
	** and the ingredienttypes table.  Every word in a ingredient is from the ingredienttypes tbl...RecipeIngredientItem is 
	** nothing more than a binder/association into that tbl for ea. recipe ingredient...so one ingredient(eg: apple juice) is
	** really made up of two entries...one for ea. word...'apple' & 'juice'.  that is the binder tables job...to
	** make recipes ingredients.
	*/
	Set @currow = 0;
	Set @seq = 0;
	While Exists (Select * from [bhp].RecipeIngredients RI
		Inner Join [bhp].RecipeIngredient_Tags RT On (RT.fk_RecipeIngredient = RI.[RowID])
		Inner Join [bhp].BHPTagWords ST On (RT.fk_TagID= ST.[RowID])
		WHere (RI.fk_RecipeJrnlMstrID = @rid And RI.RowID = @iid And RT.RowID > @currow))
	Begin
		Select Top (1)
			@tagval = ST.Name,
			@tagid = ST.RowID,
			@currow = RT.RowID,
			@seq = (@seq + 1),
			@Lang = ISNULL(ST.Lang,'en_us')
		from [bhp].RecipeIngredients RI
		Inner Join [bhp].RecipeIngredient_Tags RT On (RI.[RowID] = RT.fk_RecipeIngredient)
		Inner Join [bhp].BHPTagWords ST On (RT.fk_TagID = ST.[RowID])
		WHere (RI.fk_RecipeJrnlMstrID = @rid And RI.RowID = @iid And RT.[ROwID] > @currow)
		Order By RT.RowID;

		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				<b:Tag id=''{sql:variable("@tagid")}'' lang=''{sql:variable("@Lang")}'' nbr=''{sql:variable("@seq")}''>
					<b:Value>{sql:variable("@tagval")}</b:Value>
				</b:Tag>
			)
			as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredients/b:Ingredient/b:Tags)[1]
		');

	End

	Return 0;
end
go


/*
execute as user = 'BhpApp';
declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeIngredientMesgV2 @rid=9, @iid=14, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];
revert;
*/