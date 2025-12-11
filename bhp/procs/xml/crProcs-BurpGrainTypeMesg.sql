use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpGrainTypeMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpGrainTypeMesg;
	print 'proc:: [bhp].GenBurpGrainTypeMesg dropped!!!';
end
go

create proc [bhp].GenBurpGrainTypeMesg (
	@id int, -- a rowid value
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @nm varchar(256);
	declare @phylum nvarchar(256);
	Declare @Lang varchar(20);
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
		<b:Grain_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Type_Info/>
		</b:Grain_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''grain_type''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select 
		@nm=M.[Name],
		@lang=ISNULL(M.[Lang],'en_us')
	From [bhp].GrainTypes As M
	Where (M.RowID = @id);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>
		)
		into (/b:Burp_Belch/b:Payload/b:Grain_Evnt/b:Type_Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Grain_Evnt/b:Type_Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpGrainTypeMesg @id=4, @sessid='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b)
select @rc [@rc], @m [the message];

*/