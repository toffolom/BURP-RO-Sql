use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeTagMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeTagMesg;
	print 'proc:: [bhp].GenRecipeTagMesg dropped!!!';
end
go

create proc [bhp].GenRecipeTagMesg (
	@rowid bigint, -- rowid for the tag entry (eg: [bhp].Recipe_Tags table)
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin

	Declare @name varchar(256); -- recipe name
	Declare @tag nvarchar(100); -- actual word from [bhp].BHPTagWords
	Declare @isDraft bit;
	Declare @Lang varchar(20); -- word lang type
	Declare @SessSrc xml;
	Declare @ts varchar(50);
	Declare @rid int; -- recipe id
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
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''recipe tag''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get the ingredient (word) from [bhp].RecipeIngredientItem table
	Select 
		@rid = M.RowID,
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@tag = W.[Name],
		@Lang = ISNULL(W.Lang,'en_us'),
		@ts = [di].fn_Timestamp(M.EnteredOn),
		@rid=M.RowID,
		@tagID=W.RowID,
		@custid = C.RowID,
		@custuid = C.BHPUid,
		@custnm = C.[Name]
	From [bhp].RecipeJrnlMstr M 
	Inner Join [di].vw_CustomerMstr C On (M.fk_CreatedBy = C.RowID)
	Inner Join [bhp].Recipe_Tags RT On (RT.fk_RecipeID = M.RowID And RT.RowID = @RowID)
	Inner Join [bhp].BHPTagWords W on (RT.fk_TagID = W.RowID)
	Full Outer Join [bhp].GCTagWords GC On (W.[Name] = GC.Tag)
	Where (GC.Tag is  null);

	Set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute recipe_id {sql:variable("@rid")}
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
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
			<b:Tag id=''{sql:variable("@tagID")}'' lang=''{sql:variable("@Lang")}''>
				<b:Value>{sql:variable("@tag")}</b:Value>
			</b:Tag>
		)
		as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
	');

	Return 0;
end
go


/*
execute as user = 'bhpApp';
declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeTagMesg @rowid=9, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];
revert;
*/