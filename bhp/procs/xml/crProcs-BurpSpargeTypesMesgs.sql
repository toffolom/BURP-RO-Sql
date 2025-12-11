use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpSpargeTypeMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpSpargeTypeMesg;
	print 'proc:: [bhp].GenBurpSpargeTypeMesg dropped!!!';
end
go

create proc [bhp].GenBurpSpargeTypeMesg (
	@id int, -- a rowid value mash types master table ([bhp].MashTypeMstr)
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption, execute as 'sticky'
as
begin
	Declare @sql nvarchar(max);
	Declare @nm varchar(20);
	Declare @aka varchar(20);
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
		<b:Sparge_Type_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		</b:Sparge_Type_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''sparge''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	set @sql = N'
Select 
	@outnm=M.[Name],
	@outaka=ISNULL(M.[AKA],''n/a''),
	@outnotes=[di].fn_ToXMLNote(M.[Comment]),
	@outLang=N''en_us''
From [bhp].SpargeTypes As M
Where (M.RowID = @InRowID);
';

	exec [dbo].sp_ExecuteSql
		@Stmt=@sql,
		@Params = N'@InRowID int, 
				@outnm varchar(20) output, 
				@outaka varchar(20) output,
				@outnotes xml output,
				@outlang varchar(20) output',
		@InRowID = @id,
		@outnm = @nm output,
		@outaka = @aka output,
		@outLang = @lang output,
		@outnotes = @notes output;

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:AKA>{sql:variable("@aka")}</b:AKA>
		)
		into (/b:Burp_Belch/b:Payload/b:Sparge_Type_Evnt/b:Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Sparge_Type_Evnt/b:Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Sparge_Type_Evnt/b:Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpSpargeTypeMesg @id=3, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/