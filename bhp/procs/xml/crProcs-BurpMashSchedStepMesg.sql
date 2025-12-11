use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpMashSchedStepMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpMashSchedStepMesg;
	print 'proc:: [bhp].GenBurpMashSchedStepMesg dropped!!!';
end
go

create proc [bhp].GenBurpMashSchedStepMesg (
	@id int, -- a rowid value from one of the aging detail table
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption
as
begin

	Declare @nm varchar(200);
	Declare @stepNm varchar(50);
	Declare @custID bigint;
	Declare @custNm nvarchar(200);
	Declare @Lang varchar(20);
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
	Declare @SessSrc xml;
	Declare @MstrInfo xml; -- hold the <Info> node which contains the master record info this step belongs to
	Declare @MstrID int;
	Declare @StrikeTemp numeric(12,2);
	Declare @fk_StrikeTempUOMID int;
	Declare @StrikeTempUOM varchar(50);
	Declare @BegTrgtTemp numeric(12,2);
	Declare @EndTrgtTemp numeric(12,2);
	Declare @fk_TrgtTempUOMID int;
	Declare @TrgtTempUOM varchar(50);
	Declare @BegTime numeric(12,2);
	Declare @EndTime numeric(12,2);
	Declare @fk_TimeUOMID int;
	Declare @TimeUOM varchar(50);
	Declare @StageID int;
	Declare @StageNm varchar(50);
	Declare @fk_WtrUOMID int;
	Declare @WtrUOM varchar(50);
	Declare @WtrAmt numeric(12,2);
	Declare @GrainAmt numeric(12,2);
	Declare @fk_GrainUOMID int;
	Declare @GrainUOM varchar(50);
	Declare @Pos int;


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
		</b:MashSched_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''mash_sched_step''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- now get values to stuff in
	Select
		@MstrID = A.fk_MashSchedMstrID,
		@stepNm = A.StepName,
		@StageID = A.fk_StageTypID,
		@StageNm = A.StageName,
		@StrikeTemp = A.StrikeTempAmt,
		@fk_StrikeTempUOMID = A.fk_StrikeTempUOM,
		@StrikeTempUOM = A.StrikeTempUOM,
		@BegTrgtTemp = A.BegTargetTempAmt,
		@EndTrgtTemp = A.EndTargetTempAmt,
		@fk_TrgtTempUOMID = A.fk_TargetTempsUOM,
		@TrgtTempUOM = A.TempUOM,
		@BegTime = A.BegTimeAmt,
		@EndTime = A.EndTimeAmt,
		@fk_TimeUOMID = A.fk_TimeUOM,
		@TimeUOM = A.TimeUOM,
		@WtrAmt = A.WaterAmt,
		@fk_WtrUOMID = A.fk_WaterUOM,
		@WtrUOM = A.WaterUOM,
		@GrainAmt = A.GrainAmt,
		@fk_GrainUOMID = A.fk_GrainUOM,
		@GrainUOM = A.GrainUOM,
		@notes = [di].fn_ToXMLNote(A.Comments),
		@Lang = N'en_us',
		@Pos = A.[Pos]
	From [bhp].MashSchedDetails A
	Where (A.RowID = @id);

	exec [bhp].GenBurpMashSchedMstrMesg @id=@MstrID, @evnttype=@evnttype, @SessID=@SessID, @InfoNodeOnly = 1, @Mesg = @MstrInfo output;

	-- stuff in <Info> fragment..aka: master sched info
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@MstrInfo") as last into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt)[1]
	');

	-- stuff in <Step_Info> fragment..aka: this detail sched record
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert <b:Step_Info/> as last into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt)[1]
	');

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Name>{sql:variable("@StepNm")}</b:Name>,
			<b:Pos>{sql:variable("@Pos")}</b:Pos>,
			<b:Stage id=''{sql:variable("@StageID")}''>{sql:variable("@StageNm")}</b:Stage>,
			<b:Strike_Temp>
				<b:Amt>{sql:variable("@StrikeTemp")}</b:Amt>
				<b:UOM id=''{sql:variable("@fk_StrikeTempUOMID")}''>{sql:variable("@StrikeTempUOM")}</b:UOM>
			</b:Strike_Temp>,
			<b:Target_Temp>
				<b:Beg>{sql:variable("@BegTrgtTemp")}</b:Beg>
				<b:End>{sql:variable("@EndTrgtTemp")}</b:End>
				<b:UOM id=''{sql:variable("@fk_TrgtTempUOMID")}''>{sql:variable("@TrgtTempUOM")}</b:UOM>
			</b:Target_Temp>,
			<b:Time>
				<b:Beg>{sql:variable("@BegTime")}</b:Beg>
				<b:End>{sql:variable("@EndTIme")}</b:End>
				<b:UOM id=''{sql:variable("@fk_TimeUOMID")}''>{sql:variable("@TimeUOM")}</b:UOM>
			</b:Time>,
			<b:Water>
				<b:Amt>{sql:variable("@WtrAmt")}</b:Amt>
				<b:UOM id=''{sql:variable("@fk_WtrUOMID")}''>{sql:variable("@WtrUOM")}</b:UOM>
			</b:Water>,
			<b:Grain>
				<b:Amt>{sql:variable("@GrainAmt")}</b:Amt>
				<b:UOM id=''{sql:variable("@fk_GrainUOMID")}''>{sql:variable("@GrainUOM")}</b:UOM>
			</b:Grain>
		)
		into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Step_Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Step_Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute id {sql:variable("@id")},
			attribute lang {sql:variable("@Lang")}
		)
		into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Step_Info)[1]
	');


	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpMashSchedStepMesg @id=3, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message]; --, @m.query('(/Burp_Belch/Payload/MashSched_Evnt/Info)')

*/