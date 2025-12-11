use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeSharingMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeSharingMesg;
	print 'proc:: [bhp].GenRecipeSharingMesg dropped!!!';
end
go

create proc [bhp].GenRecipeSharingMesg (
	@rid int, -- a recipe id value from RecipeJrnlMstr tbl
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @isDraft bit;
	Declare @mask int;
	Declare @maskdescr varchar(200);
	Declare @name varchar(256);
	Declare @Lang varchar(20);
	Declare @SessSrc xml;
	Declare @ts varchar(50);
	Declare @currbit smallint;
	Declare @bitstatus varchar(10);
	Declare @bitname varchar(40);
	Declare @custid bigint;
	Declare @custuid nvarchar(256);
	Declare @custnm nvarchar(200);

	-- create our stub root node.
	Begin Try
		Exec [bhp].GenBurpBelchRootNode @SessID=@SessID, @Mesg=@Mesg output;
	End Try
	Begin Catch
		Return -1;
	End Catch

	-- pull our value(s) outta the dbms...
	Select 
		@name = M.[Name],
		@isDraft = ISNULL(M.isDraft, 1),
		@mask = M.SharingMask,
		@maskdescr = M.SharingMaskAsCSV,
		@ts = [di].fn_Timestamp(M.EnteredOn),
		@custID = C.RowID,
		@custUID = C.BHPUid,
		@custNm = C.[Name]
	From [bhp].RecipeJrnlMstr M
	Inner Join [di].vw_CustomerMstr C On (M.fk_CreatedBy = C.RowID)
	Where (M.RowID = @rid);

	-- stuff'm into the doc...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute type {''sharing flags''},
			<b:Recipe_Evnt type=''{sql:variable("@evnttype")}'' recipe_id=''{sql:variable("@rid")}''>
				<b:Info>
					<b:Creator custid=''{sql:variable("@custID")}'' uid=''{sql:variable("@custUID")}''>
						{sql:variable("@custNm")}
					</b:Creator>
					<b:Name>{sql:variable("@name")}</b:Name>
					<b:IsDraft>{sql:variable("@isDraft")}</b:IsDraft>
					<b:CreatedOn>{sql:variable("@ts")}</b:CreatedOn>
				</b:Info>
				<b:Sharing_Flags mask=''{sql:variable("@mask")}'' names=''{sql:variable("@maskdescr")}''/>
			</b:Recipe_Evnt>
		)
		into (/b:Burp_Belch/b:Payload)[1]');

	if (@mask = 0) -- if only the 'private' flag 'on'...then add that in now...all the rest will come out 'off'
	begin
		Select @bitname=[Descr] from [bhp].SharingTypes where BitVal=0;
		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				<b:Flag val=''{sql:variable("@mask")}'' name=''{sql:variable("@bitname")}'' status=''on''/>
			)
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sharing_Flags)[1]
		');
	end

	set @currbit = 0;
	while exists (select * from [bhp].SharingTypes where BitVal > @currbit)
	begin
		select top (1)
			@currbit = BitVal,
			@bitstatus = case when ((@mask & BitVal) = BitVal) Then 'on' else 'off' end,
			@bitname = [Descr]
		from [bhp].SharingTypes 
		Where (BitVal > @currbit)
		order by BitVal;

		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				<b:Flag val=''{sql:variable("@currbit")}'' name=''{sql:variable("@bitname")}'' status=''{sql:variable("@bitstatus")}''/>
			)
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sharing_Flags)[1]
		');
	end

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeSharingMesg @rid=9, @evnttype='chg', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @m.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sharing_Flags)');

*/