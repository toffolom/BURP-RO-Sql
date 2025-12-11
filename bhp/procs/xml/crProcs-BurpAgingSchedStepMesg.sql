use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpAgingSchedStepMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpAgingSchedStepMesg;
	print 'proc:: [bhp].GenBurpAgingSchedStepMesg dropped!!!';
end
go

create proc [bhp].GenBurpAgingSchedStepMesg (
	@id int, -- a rowid value from one of the aging detail table
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @nm varchar(200);
	Declare @custID bigint;
	Declare @custNm nvarchar(200);
	Declare @Lang varchar(20);
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
	Declare @SessSrc xml;
	Declare @MstrInfo xml; -- hold the <Info> node which contains the master record info this step belongs to
	Declare @MstrID int;
	Declare @StageID int;
	Declare @StageNm varchar(50);
	Declare @Duration numeric(14,2);
	Declare @fk_DurationUOM int;
	Declare @DurationUOM varchar(50);
	Declare @BegTempRange int;
	Declare @EndTempRange int;
	Declare @fk_TempUOM int;
	Declare @TempUOM varchar(50);


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
		<b:AgingSched_Evnt type=''{sql:variable("@evnttype")}''>
		</b:AgingSched_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''aging_sched_step''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select
		@MstrID = A.fk_AgingSchedMstrID,
		@nm = A.[StepName],
		@StageID = A.fk_Stage,
		@StageNm = StageName,
		@Duration = ISNULL(Duration,0),
		@fk_DurationUOM = fk_DurationUOM,
		@DurationUOM = DurationUOM,
		@BegTempRange = BegTempRange,
		@EndTempRange = EndTempRange,
		@fk_TempUOM = fk_TempRangeUOM,
		@TempUOM = TempRangeUOM,
		@notes = [di].fn_ToXMLNote(A.Comment),
		@Lang = N'en_us'
	From [bhp].AgingSchedDetails A
	Where (A.RowID = @id);

	exec [bhp].GenBurpAgingSchedMstrMesg @id=@MstrID, @evnttype=@evnttype, @SessID=@SessID, @InfoNodeOnly = 1, @Mesg = @MstrInfo output;

	-- stuff in <Info> fragment..aka: master sched info
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@MstrInfo") as last into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt)[1]
	');

	-- stuff in <Step_Info> fragment..aka: this detail sched record
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert <b:Step_Info/> as last into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt)[1]
	');

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@nm")}</b:Name>,
			<b:Stage id=''{sql:variable("@StageID")}''>{sql:variable("@StageNm")}</b:Stage>,
			<b:Duration>
				<b:Amt>{sql:variable("@Duration")}</b:Amt>
				<b:UOM id=''{sql:variable("@fk_DurationUOM")}''>{sql:variable("@DurationUOM")}</b:UOM>
			</b:Duration>,
			<b:Temp_Range>
				<b:Beg>{sql:variable("@BegTempRange")}</b:Beg>
				<b:End>{sql:variable("@EndTempRange")}</b:End>
				<b:UOM id=''{sql:variable("@fk_TempUOM")}''>{sql:variable("@TempUOM")}</b:UOM>
			</b:Temp_Range>
		)
		into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt/b:Step_Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt/b:Step_Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt/b:Step_Info)[1]
	');


	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpAgingSchedStepMesg @id=5, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message]; --, @m.query('(/Burp_Belch/Payload/AgingSched_Evnt/Info)')

*/