use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpBHPTagWordMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpBHPTagWordMesg;
	print 'proc:: [bhp].GenBurpBHPTagWordMesg dropped!!!';
end
go

create proc [bhp].GenBurpBHPTagWordMesg (
	@id int, -- a rowid value
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @nm varchar(100);
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
		<b:Tag_Evnt type=''{sql:variable("@evnttype")}''/>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''search tag''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select 
		@nm=M.[Name],
		@lang=ISNULL(M.[Lang],'en_us')
	From [bhp].BHPTagWords As M
	Where (M.RowID = @id);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Tag id=''{sql:variable("@id")}'' lang=''{sql:variable("@Lang")}''>
				<b:Name>{sql:variable("@nm")}</b:Name>
			</b:Tag>
		)
		into (/b:Burp_Belch/b:Payload/b:Tag_Evnt)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpBHPTagWordMesg @id=9, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b)
select @rc [@rc], @m [the message];

*/