use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeStyleMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeStyleMesg;
	print 'proc:: [bhp].GenRecipeStyleMesg dropped!!!';
end
go

create proc [bhp].GenRecipeStyleMesg (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @StyleID int;
	Declare @StyleCat nvarchar(200);
	Declare @StyleNm nvarchar(100);
	Declare @StyleDescr nvarchar(4000);
	Declare @name varchar(256);
	Declare @isDraft bit;
	Declare @Lang varchar(20);
	Declare @SessSrc xml;
	Declare @ts varchar(50);

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
		<b:Recipe_Evnt type=''{sql:variable("@evnttype")}'' recipe_id=''{sql:variable("@rid")}''>
		<b:Info/>
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''style''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in

	Select 
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@StyleID = M.fk_BeerStyle,
		@StyleNm = A.[Name],
		@StyleCat = A.[CategoryName],
		@Lang = ISNULL(A.Lang,'en_us'),
		@StyleDescr = convert(varchar(4000), ISNULL(A.[Descr],'no description available...')),
		@ts = [di].fn_Timestamp(M.EnteredOn)
	From [bhp].RecipeJrnlMstr M Inner Join [bhp].AHABeerStyle A on (M.fk_BeerStyle = A.RowID)
	Where (M.RowID = @rid);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Style_Info id=''{sql:variable("@StyleID")}'' lang=''{sql:variable("@Lang")}''>
				<b:Category>{sql:variable("@StyleCat")}</b:Category>
				<b:Name>{sql:variable("@StyleNm")}</b:Name>
				<b:Descr>{sql:variable("@StyleDescr")}</b:Descr>
			</b:Style_Info>
		)
		into(/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
	');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@name")}</b:Name>,
			<b:IsDraft>{sql:variable("@isDraft")}</b:IsDraft>,
			<b:CreatedOn>{sql:variable("@ts")}</b:CreatedOn>
		) into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeStyleMesg @rid=9, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/