use [BHP1-RO]
go

if object_id(N'[bhp].GenSessSrcMesg',N'P') is not null
begin
	drop proc [bhp].GenSessSrcMesg;
	print 'proc:: [bhp].GenSessSrcMesg dropped!!!';
end
go

/*
** Effectivly this is a strip'd down version of session burp mesg.  We gen this one here
** and stuff it into the Belch_Burp root node.
** It effectively links any burp mesg to a session (creator)!!!
*/
create proc [bhp].GenSessSrcMesg (
	@sessID varchar(256),
	@mesg xml output
)
with encryption
as
begin

	Declare @CustNm nvarchar(200);
	Declare @CustID bigint;
	Declare @uid nvarchar(256);
	Declare @SessRowID bigint;

	if not exists (select * From [di].vw_SessionInfo Where (SessionID = @sessID))
	begin
		Raiserror(N'unknown session value:[%s]!? Aborting...',16,1,@sessID);
		Return -1;
	end

	-- create our stub root node.
	Set @mesg = cast(N'<Session_Src xmlns="http://burp.net/recipe/evnts"/>' as xml);

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute uid {sql:variable("@SessID")}
		into (/b:Session_Src)[1]
	');

	Select @SessRowID = RowID, @CustID = CustomerNbr
	From [di].vw_SessionInfo Where SessionID=@sessID;

	-- if session id is -> N'00000000-0000-0000-0000-000000000000'
	-- then we want to set the session info to the 'admin' user...which is defined in the ENvironment tbl by
	-- entry 'Admin UID'. We use the varVal value to look into the CustMstr tbl to extract the admin user info...
	if (@SessRowID > 0)
	Begin
		Select
			--@CustID=C.RowID, 
			@CustNm=C.Name,
			@uid = C.BHPUid
		From [di].vw_CustomerMstr C WHere (C.RowID = @CustID);
		--From [di].vw_SessionInfo S
		--Inner Join [di].vw_CustomerMstr C On (C.RowID = S.CustomerNbr)
		--Where (SessionID = convert(uniqueidentifier, @sessID));
	End
	Else -- its an admin sess...pull the 'admin' user from custmstr by look'n for id in env
	Begin
		If Not Exists (Select * From [di].Environment E Inner Join [di].vw_CustomerMstr C On (E.VarVal = C.RowID) Where (E.VarNm = 'Admin UID'))
		Begin
			Select @CustID = 0, @CustNm = 'env cnfg err...chk setup!!!', @uid='sysadmin@bhp.biz'
		End
		Else
		Begin
			Select
				@CustID=C.RowID, 
				@CustNm=C.[Name],
				@uid = BHPUid
			From [di].Environment E
			Inner Join [di].vw_CustomerMstr C On (E.VarVal = C.RowID)
			Where (E.VarNm = 'Admin UID');
		End
	End

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Cust custid=''{sql:variable("@CustID")}'' uid=''{sql:variable("@uid")}''>{sql:variable("@CustNm")}</b:Cust>
		)
		into (/b:Session_Src)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenSessSrcMesg @SessID='1320FBA0-4C69-4BB8-94B4-083C10FAEDE0', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/