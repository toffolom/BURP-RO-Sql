use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpEnvironMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpEnvironMesg;
	print 'proc:: [bhp].GenBurpEnvironMesg dropped!!!';
end
go

create proc [bhp].GenBurpEnvironMesg (
	@id int, -- a rowid value mash types master table ([bhp].MashTypeMstr)
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption, execute as 'sticky'
as
begin
	Declare @sql nvarchar(max);
	Declare @var nvarchar(200);
	Declare @val nvarchar(4000);
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
		<b:Environment_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		</b:Environment_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''env''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	set @sql = N'
Select 
	@outvar=M.[VarNm],
	@outval=M.[VarVal],
	@outnotes=[bhp].fn_ToXMLNote(M.[Notes]),
	@outLang=N''en_us''
From [bhp].Environment As M
Where (M.RowID = @InRowID);
';

	exec [dbo].sp_ExecuteSql
		@Stmt=@sql,
		@Params = N'@InRowID int, 
				@outvar nvarchar(200) output, 
				@outval nvarchar(4000) output, 
				@outnotes xml output,
				@outlang varchar(20) output',
		@InRowID = @id,
		@outvar = @var output,
		@outval = @val output,
		@outLang = @lang output,
		@outnotes = @notes output;

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Var>{sql:variable("@var")}</b:Var>,
			<b:Val>{sql:variable("@val")}</b:Val>
		)
		into (/b:Burp_Belch/b:Payload/b:Environment_Evnt/b:Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Environment_Evnt/b:Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Environment_Evnt/b:Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpEnvironMesg @id=10, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/