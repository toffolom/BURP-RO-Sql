use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpBelchRootNode',N'P') is not null
begin
	drop proc [bhp].GenBurpBelchRootNode;
	print 'proc:: [bhp].GenBurpBelchRootNode dropped!!!';
end
go

/*
** this proc will establish the root node called <Burp_Belch>
** Along with this will be the <Session_Src> and <Payload> node(s) appended underneath.
** Session Source contains the session information passed around
** the Payload is the actual message of what this Burp Belch message contains.
** 
*/
create proc [bhp].GenBurpBelchRootNode (
	@SessID varchar(256),
	@mesg xml output,
	@ver varchar(20) = '1.0',
	@noSessSrcNode bit = 0
)
with encryption
as
begin
	Declare @pylduid varchar(256);
	Declare @docts varchar(40);
	Declare @SessSrc xml;
	Declare @did varchar(256); -- our deployment id (guid).
	Declare @rc int;
	Declare @emsg nvarchar(2000);

	set @ver = ISNULL([di].fn_IsNull(@ver),'1.0');
	set @noSessSrcNode = ISNULL(@NoSessSrcNode,0);

	If Not Exists (Select * from [di].vw_SessionInfo Where SessionID = @SessID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@emsg output;
		Raiserror(@emsg,16,1);
		Return @rc;
	End

	Set @pylduid = convert(varchar(256), newid()); -- ea. paylod node has a uniq id value (attribute 'uid')!!!
	Set @docts = [di].fn_Timestamp(getdate()); -- when the mesg was gen'd

	-- grab our deployment id (guid)...stuff into the root node!!!
	Select @did = S.DeploymentID
	From [di].vw_SessionInfo S Where (S.SessionID = @SessID);
	--Inner Join DI.[bhp].vw_DeploymentInfo D on (S.SessionID = @SessID And S.DeploymentRowID = D.RowID);

	-- create our stub root node.
	Set @mesg = cast(N'<Burp_Belch xmlns="http://burp.net/recipe/evnts"/>' as xml);

	if (@noSessSrcNode = 0)
	Begin
		Exec [bhp].GenSessSrcMesg @SessID = @SessID, @Mesg = @SessSrc output;

		-- stuff in session source node
		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@SessSrc") as first into (/b:Burp_Belch)[1]
		');
	End

	-- stuff in the document timestamp (attribute 'ts') & deployment id
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute ver {sql:variable("@ver")},
			attribute ts {sql:variable("@docts")},
			attribute did {sql:variable("@did")}
		) into (/*)[1]');

	-- prime up the rest...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert 
		<b:Payload uid=''{sql:variable("@pylduid")}''/>
		into (/b:Burp_Belch)[1]');

	

	Return 0;
end
go


/*
execute as user = 'BHPApp'
declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpBelchRootNode @SessID='00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b)
select @rc [@rc], @m [the message];
revert;

*/