/*
** NOTE: be sure to change the client queue name if installing on AZURE!!!!
*/

use [BHP1-RO]
go

if object_id(N'[di].GetAcctInfoListing',N'P') is not null
begin
	Drop Proc [di].GetAcctInfoListing;
	Print 'proc:: [di].GetAcctInfoListing dropped!!!';
end
go

/*
** NOTE: on Azure Sql...this proc cannot perform the ssb call...so we just return an empty resultset!!!
*/
Create Proc [di].GetAcctInfoListing (
	@ovrWaitTimeSecs tinyint = null
)
with encryption
as
begin
	
	Set Nocount on;

	If (1=0) -- lil tidbit here so Visual Studio won't puck when try'n to figure out this proc!!!
	Begin
		select 
			Cast(Null As bigint) As CustID,
			Cast(Null As nvarchar(256)) As BHPUid,
			Cast(Null As nvarchar(200)) As [Name],
			Cast(Null As int) As DeployID,
			Cast(Null As varchar(200)) As DeployNm;
		
		Set FMTONLY OFF;
		Return;
	End

	Declare @rply Table (
		CustID bigint not null,
		BHPUid nvarchar(256) not null,
		[Name] nvarchar(200),
		DeployID int not null,
		DeployNm varchar(200) not null
	);

	select * from @rply; -- where (@hasFailed=0);

	Return 0;

end
go

/*
**

--end conversation 'EACA8383-0AF4-E811-80FC-000D3A70EDF8' with cleanup;
set fmtonly off;
declare @rc int;
exec @rc = [di].GetAcctInfoListing;
select @rc [@rc];
select * from sys.conversation_endpoints;
select * from sys.transmission_queue;
**
*/