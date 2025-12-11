use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeIngredientTagMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeIngredientTagMesg;
	print 'proc:: [bhp].GenRecipeIngredientTagMesg dropped!!!';
end
go

create proc [bhp].GenRecipeIngredientTagMesg (
	@rowid bigint, -- rowid for the tag entry (eg: [bhp].RecipeIngredient_Tags table)
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
	Declare @IngredUOMID int;
	Declare @IngredUOM varchar(50);
	Declare @phrase nvarchar(1000); -- the whole ingredient name/phrase
	Declare @Qty numeric(10,4);
	Declare @name varchar(256); -- recipe name
	Declare @tag nvarchar(100); -- actual word from [bhp].BHPTagWords
	Declare @isDraft bit;
	Declare @Lang varchar(20); -- word lang type
	Declare @SessSrc xml;
	Declare @ts varchar(50);
	Declare @rid int; -- recipe id
	Declare @iid bigint; -- recipe ingredient tag event is happening on/for ([bhp].RecipeIngredients rowid value)
	Declare @tagID bigint; -- tag word id value ([bhp].BHPTagWords rowid value)
	Declare @custid bigint;
	Declare @custuid nvarchar(256);
	Declare @custnm nvarchar(200);

	-- create our stub root node.
	Begin Try
		Exec [bhp].GenBurpBelchRootNode @SessID=@SessID, @Mesg=@Mesg output;
	End Try
	Begin Catch
		Return -1;
	End Catch

	-- prime up the rest...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert 
		<b:Recipe_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		<b:Ingredient/>
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''ingredient tag''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get the ingredient (word) from [bhp].RecipeIngredientItem table
	Select 
		@rid = M.RowID,
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@tag = W.[Name],
		@phrase = ISNULL(RI.Phrase,''),
		@Qty = ISNULL(RI.QtyOrAmount, 0.0),
		@IngredUOMID = RI.fk_IngredientUOM,
		@IngredUOM = U.[UOM],
		@StageID = RI.fk_Stage,
		@StageNm = S.[Name],
		@Lang = ISNULL(W.Lang,'en_us'),
		@ts = [di].fn_Timestamp(M.EnteredOn),
		@rid=M.RowID,
		@iid=RI.RowID,
		@tagID=W.RowID,
		@custid = C.RowID,
		@custuid = C.BHPUid,
		@custnm = C.[Name]
	From [bhp].RecipeJrnlMstr M 
	Inner Join [di].vw_CustomerMstr C On (M.fk_CreatedBy = C.RowID)
	Inner Join [bhp].RecipeIngredients RI On (M.RowID = RI.fk_RecipeJrnlMstrID)
	Inner Join [bhp].RecipeIngredient_Tags T On (T.fk_RecipeIngredient = RI.RowID)
	Inner Join [bhp].BHPTagWords W on (T.fk_TagID = W.RowID)
	Inner Join [bhp].UOMTypes U On (RI.fk_IngredientUOM = U.RowID)
	Inner Join [bhp].StageTypes S On (RI.fk_Stage = S.RowID)
	Where (T.RowID = @rowid);

	Set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute recipe_id {sql:variable("@rid")}
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
	');

	Set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute id {sql:variable("@iid")}
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredient)[1]
	');

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
			<b:Phrase>{sql:variable("@phrase")}</b:Phrase>,
			<b:Qty>
				<b:Amt>{sql:variable("@Qty")}</b:Amt>
				<b:UOM id=''{sql:variable("@IngredUOMID")}''>{sql:variable("@IngredUOM")}</b:UOM>
			</b:Qty>,
			<b:Stage id=''{sql:variable("@StageID")}''>{sql:variable("@StageNm")}</b:Stage>,
			<b:Tag id=''{sql:variable("@tagID")}'' lang=''{sql:variable("@Lang")}''>
				<b:Value>{sql:variable("@tag")}</b:Value>
			</b:Tag>
		)
		as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Ingredient)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeIngredientTagMesg @rowid=20, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/