use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpMashSchedAllMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpMashSchedAllMesg;
	print 'proc:: [bhp].GenBurpMashSchedAllMesg dropped!!!';
end
go

create proc [bhp].GenBurpMashSchedAllMesg (
	@id int, -- a rowid value from one of the mash sched mstr
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@SessID varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @nm varchar(200);
	Declare @Lang varchar(20);
	Declare @notes xml; -- holds any notes/comments. eg: <Notes><Note nbr='int'>string</Note><Notes>...
	Declare @MstrInfo xml; -- hold the <Info> node which contains the master record info this step belongs to
	Declare @SessStatus bit;
	Declare @rc int;
	Declare @StepRowID int;
	Declare @stepNm varchar(50);
	Declare @I18Msg nvarchar(2000);
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

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@I18Msg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@I18Msg output;
		Raiserror(@I18Msg,16,1);
		Return @rc;
	End	

	-- this generator can only work on additions and changes to hop schedules!!!
	If (@evnttype not in ('add','chg'))
	Begin
		Raiserror(N'Unknown event type! Must be ''add'' or ''chg''...',16,1);
		Return -1;
	End

	-- now get values to stuff in
	If Not Exists (Select 1 From [bhp].[MashSchedMstr] Where (RowID = @Id))
	Begin
		Raiserror(N'Mash Sched Doesn''t exist...aborting!!!',16,1);
		Return -1;
	End

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
		insert attribute type {''mash_sched''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	exec [bhp].GenBurpMashSchedMstrMesg @id=@id, @evnttype=@evnttype, @SessID=@SessID, @InfoNodeOnly = 1, @Mesg = @MstrInfo output;

	-- stuff in <Info> fragment..aka: master sched info
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@MstrInfo") 
		as last into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt)[1]
	');

	Set @StepRowID=0;
	Set @Pos = 0;
	While Exists (Select 1 from bhp.MashSchedDetails Where fk_MashSchedMstrID=@id And [Pos] > @Pos)
	Begin

		Select Top (1)
			@StepRowID = A.RowID,
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
		Where (A.[Pos] > @Pos)
		Order By A.[Pos];

		-- stuff in values...
		set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Step_Info id=''{sql:variable("@StepRowID")}'' lang=''{sql:variable("@Lang")}''>
				<b:Name>{sql:variable("@StepNm")}</b:Name>
				<b:Pos>{sql:variable("@Pos")}</b:Pos>
				<b:Stage id=''{sql:variable("@StageID")}''>{sql:variable("@StageNm")}</b:Stage>
				<b:Strike_Temp>
					<b:Amt>{sql:variable("@StrikeTemp")}</b:Amt>
					<b:UOM id=''{sql:variable("@fk_StrikeTempUOMID")}''>{sql:variable("@StrikeTempUOM")}</b:UOM>
				</b:Strike_Temp>
				<b:Target_Temp>
					<b:Beg>{sql:variable("@BegTrgtTemp")}</b:Beg>
					<b:End>{sql:variable("@EndTrgtTemp")}</b:End>
					<b:UOM id=''{sql:variable("@fk_TrgtTempUOMID")}''>{sql:variable("@TrgtTempUOM")}</b:UOM>
				</b:Target_Temp>
				<b:Time>
					<b:Beg>{sql:variable("@BegTime")}</b:Beg>
					<b:End>{sql:variable("@EndTIme")}</b:End>
					<b:UOM id=''{sql:variable("@fk_TimeUOMID")}''>{sql:variable("@TimeUOM")}</b:UOM>
				</b:Time>
				<b:Water>
					<b:Amt>{sql:variable("@WtrAmt")}</b:Amt>
					<b:UOM id=''{sql:variable("@fk_WtrUOMID")}''>{sql:variable("@WtrUOM")}</b:UOM>
				</b:Water>
				<b:Grain>
					<b:Amt>{sql:variable("@GrainAmt")}</b:Amt>
					<b:UOM id=''{sql:variable("@fk_GrainUOMID")}''>{sql:variable("@GrainUOM")}</b:UOM>
				</b:Grain>
			</b:Step_Info>
		)
		into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt)[1]
		');

		-- stuff in any note/comment....
		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Step_Info[last()])[1]
		');

	End -- endof while exists.

	Return @@ERROR;

end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpMashSchedAllMesg @id=2, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message]; --, @m.query('(/Burp_Belch/Payload/MashSched_Evnt/Info)')

*/