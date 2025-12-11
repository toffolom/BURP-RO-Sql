use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpMashTypeMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpMashTypeMesg;
	print 'proc:: [bhp].GenBurpMashTypeMesg dropped!!!';
end
go

create proc [bhp].GenBurpMashTypeMesg (
	@id int, -- a rowid value mash types master table ([bhp].MashTypeMstr)
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @nm nvarchar(200);
	Declare @fkTempUOM int;
	Declare @TempUOM varchar(50);
	Declare @begTemp numeric(6,2);
	Declare @endTemp numeric(6,2);
	Declare @Lang varchar(20);
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
	Declare @SessSrc xml;


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
		<b:Mash_Type_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		</b:Mash_Type_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''mash_type''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	Select 
		@nm=M.[Name],
		@FkTempUOM=ISNULL(M.fk_TempUOM,0),
		@BegTemp=ISNULL(M.[BegTempAmt],0.0),
		@EndTemp=ISNULL(M.[EndTempAmt],0.0),
		@notes=[di].fn_ToXMLNote(M.[Comments]),
		@TempUOM=M.TempUOM,
		@Lang=N'en_us'
	From [bhp].MashTypeMstr As M
	Where (M.RowID = @id);


	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:TempRange>
			<b:Beg>{sql:variable("@begTemp")}</b:Beg>
			<b:End>{sql:variable("@endTemp")}</b:End>
			<b:UOM id=''{sql:variable("@fkTempUOM")}''>{sql:variable("@tempUOM")}</b:UOM>
			</b:TempRange>
		)
		into (/b:Burp_Belch/b:Payload/b:Mash_Type_Evnt/b:Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Mash_Type_Evnt/b:Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Mash_Type_Evnt/b:Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpMashTypeMesg @id=2, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/