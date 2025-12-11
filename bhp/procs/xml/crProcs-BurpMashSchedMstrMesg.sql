use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpMashSchedMstrMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpMashSchedMstrMesg;
	print 'proc:: [bhp].GenBurpMashSchedMstrMesg dropped!!!';
end
go

create proc [bhp].GenBurpMashSchedMstrMesg (
	@id int, -- a rowid value from one of the mfr tables
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@InfoNodeOnly bit = 0,
	@mesg xml output
)
with encryption
as
begin
	Declare @nm varchar(200);
	Declare @Lang varchar(20);
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
	Declare @SessSrc xml;
	Declare @fk_MashTypID int;
	Declare @MashTypeNm nvarchar(200);
	Declare @fk_WtrToGrainRatioUOMID int;
	Declare @WtrToGrainRatio numeric(3,2);
	Declare @WtrToGrainRatioUOM varchar(50);
	Declare @fk_SpargeTypeID int;
	Declare @SpargeTypeNm varchar(50);
	Declare @isDflt4Nu bit;
	Declare @currbit int;
	Declare @mask int; -- sharing mask value
	Declare @bitstatus varchar(10);
	Declare @bitname varchar(40);
	Declare @maskAsCSV varchar(200);
	Declare @custuid nvarchar(256);
	Declare @custID bigint;
	Declare @custNm nvarchar(200);


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
		<b:MashSched_Evnt type=''{sql:variable("@evnttype")}''>
		<b:Info/>
		</b:MashSched_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''mash_sched''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select
		@nm = A.[Name],
		@custid = C.RowID,
		@custuid = C.BHPUid,
		@custnm = C.[Name],
		@fk_MashTypID = A.fk_MashTYpeID,
		@MashTypeNm = A.MashTYpeNm,
		@fk_SpargeTypeID = A.fk_SpargeTYpe,
		@SpargeTypeNm = A.SpargeType,
		@fk_WtrToGrainRatioUOMID = A.fk_WtrTOGrainRatioUOM,
		@WtrToGrainRatio = ISNULL(A.WtrToGrainRatio, 0.0),
		@WtrToGrainRatioUOM = A.WtrToGrainRatioUOM,
		@notes = [di].fn_ToXMLNote(A.Comments),
		@Lang = N'en_us',
		@isDflt4Nu=ISNULL(IsDfltForNu,0),
		@mask = ISNULL(SharingMask,0),
		@maskAsCSV = SharingMaskAsCSV
	From [bhp].MashSchedMstr A 
	Inner Join [di].vw_CustomerMstr C On (A.fk_CreatedBy = C.RowID)
	Where (A.RowID = @id);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:Creator custid=''{sql:variable("@custID")}'' uid=''{sql:variable("@custUID")}''>
				{sql:variable("@custNm")}
			</b:Creator>,
			<b:Mash_Type id=''{sql:variable("@fk_MashTypID")}''>{sql:variable("@MashTypeNm")}</b:Mash_Type>,
			<b:WaterToGrain_Ratio>
				<b:Amt>{sql:variable("@WtrToGrainRatio")}</b:Amt>
				<b:UOM id=''{sql:variable("@fk_WtrToGrainRatioUOMID")}''>{sql:variable("@WtrToGrainRatioUOM")}</b:UOM>
			</b:WaterToGrain_Ratio>,
			<b:Sparge_Type id=''{sql:variable("@fk_SpargeTypeID")}''>{sql:variable("@SpargeTypeNm")}</b:Sparge_Type>
		)
		into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info)[1]
	');
	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")},
			attribute isnudflt {sql:variable("@isDflt4Nu")}
		)
		into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info)[1]
	');

		-- stuff in the sharing info node now...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
		<b:Sharing_Flags mask=''{sql:variable("@mask")}'' names=''{sql:variable("@maskAsCSV")}''/>
		)as last into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info)[1]
	');

	if (@mask = 0) -- if only the 'private' flag 'on'...then add that in now...all the rest will come out 'off'
	begin
		Select @bitname=[Descr] from [bhp].SharingTypes where BitVal=@mask;
		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				<b:Flag val=''{sql:variable("@mask")}'' name=''{sql:variable("@bitname")}'' status=''on''/>
			)
			into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info/b:Sharing_Flags)[1]
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
			into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info/b:Sharing_Flags)[1]
		');
	end

	/*
	** when this proc is called from a step detail generator request...we only need the <Info> node as we're
	** going to be inserting the <Info> node into a belch doc that includes the sched step(s)...
	** NOTE: Just like notes above...we're stuff'n a fragment into a larger xml doc!!!
	*/
	If (@InfoNodeOnly = 1)
	Begin
		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		Select @mesg = @mesg.query('(/Burp_Belch/Payload/MashSched_Evnt/Info)');
	End

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpMashSchedMstrMesg @id=2, @evnttype='add', @InfoNodeOnly=0, @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message], @m.query('(/Burp_Belch/Payload/MashSched_Evnt/Info)')

*/