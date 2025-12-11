use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpYeastPkgInfoMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpYeastPkgInfoMesg;
	print 'proc:: [bhp].GenBurpYeastPkgInfoMesg dropped!!!';
end
go

create proc [bhp].GenBurpYeastPkgInfoMesg (
	@pkgID int, -- a rowid value from one of the mfr tables
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @nm varchar(200);
	declare @notes xml;
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
		<b:Yeast_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Pkg_Info/>
		</b:Yeast_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''yeast_pkg''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select 
		@nm=M.[Name],
		@notes=[di].fn_ToXMLNote(M.Notes),
		@lang=ISNULL(M.[Lang],'en_us')
	From [bhp].YeastPackagingTypes As M
	--cross apply (
	--	select [bhp].fn_ToXMLNote(Notes)
	--) As n(x)
	Where (M.RowID = @pkgID);

	--select @nm, @notes, @lang;

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>
		)
		into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Pkg_Info)[1]
	');

	-- NOTE: notes/comments are stored in dbms as a nvarchar. they can contain multiple note entries
	-- EG: <Notes><Note nbr='1'>this is note 1...</Note><Note nbr='2'>second note...</Note></Notes>
	-- the fragment is stuffed into @mesg doc!!! THe func call (above) to [bhp].fn_ToXMLNote() does all the heavy
	-- lifting to convert a comment/note column to the aforementioned xml frag!!!
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Pkg_Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@pkgID")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Pkg_Info)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpYeastPkgInfoMesg @pkgID=3, @SessID='00000000-0000-0000-0000-000000000000', @evnttype='add', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b)
select @rc [@rc], @m [the message];

*/