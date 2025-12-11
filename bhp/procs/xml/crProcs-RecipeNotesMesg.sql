use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeNotesMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeNotesMesg;
	print 'proc:: [bhp].GenRecipeNotesMesg dropped!!!';
end
go

create proc [bhp].GenRecipeNotesMesg (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @name varchar(256);
	Declare @isDraft bit;
	Declare @Lang varchar(20);
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
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
		<b:Recipe_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		</b:Recipe_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''recipe''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in

	Select 
		@name = [Name],
		@isDraft = ISNULL(isDraft, 1),
		@notes=[di].fn_ToXMLNote([Notes]),
		@Lang=N'en_us',
		@ts = [di].fn_Timestamp(EnteredOn)
	From [bhp].RecipeJrnlMstr
	Where (RowID = @rid);

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@name")}</b:Name>,
			<b:IsDraft>{sql:variable("@isDraft")}</b:IsDraft>,
			<b:CreatedOn>{sql:variable("@ts")}</b:CreatedOn>
		) into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute recipe_id {sql:variable("@rid")}
		)
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeNotesMesg @rid=9, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/