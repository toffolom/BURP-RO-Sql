use [BHP1-RO]
go

if object_id(N'[bhp].GenBurpHopSchedAllMesg',N'P') is not null
begin
	drop proc [bhp].GenBurpHopSchedAllMesg;
	print 'proc:: [bhp].GenBurpHopSchedAllMesg dropped!!!';
end
go

create proc [bhp].GenBurpHopSchedAllMesg (
	@id int, -- a rowid value from one of the hop sched table
	@evnttype varchar(10), -- must be one of 'add' or 'chg'
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
	Declare @MstrInfo xml; -- hold the <Info> node which contains the master record info this step belongs to
	Declare @MstrID int;
	Declare @HopID int;
	Declare @HopNm varchar(50);
	Declare @StageID int;
	Declare @StageNm varchar(50);
	Declare @fk_QtyUOMID int;
	Declare @QtyUOM varchar(50);
	Declare @Qty numeric(14,2);
	Declare @fk_TimeUOMID int;
	Declare @TimeUOM varchar(50);
	Declare @TimeAmt numeric(14,2);
	Declare @StepName varchar(50);
	Declare @MfrID int;
	Declare @MfrNm nvarchar(300);
	Declare @SessStatus bit;
	Declare @rc int;
	Declare @StepRowID int;

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@MfrNm output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@MfrNm output;
		Raiserror(@MfrNm,16,1);
		Return @rc;
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
		<b:HopSched_Evnt type=''{sql:variable("@evnttype")}''>
		</b:HopSched_Evnt>
		into (/b:Burp_Belch/b:Payload)[1]');

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert attribute type {''hop_sched''}
		into (/b:Burp_Belch/b:Payload)[1]
	');

	-- this generator can only work on additions and changes to hop schedules!!!
	If (@evnttype not in ('add','chg'))
	Begin
		Raiserror(N'Unknown event type! Must be ''add'' or ''chg''...',16,1);
		Return -1;
	End

	-- now get values to stuff in
	If Not Exists (Select 1 From [bhp].[HopSchedMstr] Where (RowID = @Id))
	Begin
		Raiserror(N'Hop Sched Doesn''t exist...aborting!!!',16,1);
		Return -1;
	End

	exec [bhp].GenBurpHopSchedMstrMesg @id=@id, @evnttype=@evnttype, @SessID=@SessID, @InfoNodeOnly = 1, @Mesg = @MstrInfo output;

	-- stuff in <Info> fragment..aka: master sched info
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@MstrInfo") 
		as last into (/b:Burp_Belch/b:Payload/b:HopSched_Evnt)[1]
	');

	Set @StepRowID = 0;
	While Exists (Select 1 from bhp.HopSchedDetails Where fk_HopSchedMstrID = @id And RowID > @StepRowID)
	Begin
		Select Top (1)
			@StepRowID = A.RowID,
			@StepName= A.StepName,
			@HopID = A.fk_HopTypID,
			@HopNm = HT.[Name],
			@StageID = A.fk_Stage,
			@StageNm = A.StageName,
			@fk_QtyUOMID = A.fk_HopUOM,
			@QtyUOM = A.HopUOM,
			@Qty = ISNULL(A.QtyOrAmount, 0),
			@TimeAmt = ISNULL(A.TimeAmt, 0),
			@fk_TimeUOMID = A.fk_TimeUOM,
			@TimeUOM = A.TimeUOM,
			@notes = [di].fn_ToXMLNote(A.Comment),
			@Lang = N'en_us',
			@MfrID = M.ROwID,
			@MfrNm = M.[Name]
		From [bhp].HopSchedDetails A
		Inner Join [bhp].HopTypesV2 HT On (A.fk_HopTypID = HT.RowID)
		Inner Join [bhp].HopManufacturers M On (HT.fk_HopMfrID = M.RowID)
		Where (A.fk_HopSchedMstrID = @id And A.RowID > @StepRowID)
		Order By A.RowID;

		-- stuff in step...
		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				<b:Step_Info id=''{sql:variable("@StepRowID")}'' lang=''{sql:variable("@Lang")}''>
					<b:Name>{sql:variable("@StepName")}</b:Name>
					<b:Hop_Info id=''{sql:variable("@HopID")}''>
						<b:Name>{sql:variable("@HopNm")}</b:Name>
						<b:MfrInfo id=''{sql:variable("@MfrID")}''>{sql:variable("@MfrNm")}</b:MfrInfo>
					</b:Hop_Info>
					<b:Stage id=''{sql:variable("@StageID")}''>{sql:variable("@StageNm")}</b:Stage>
					<b:Qty>
						<b:Amt>{sql:variable("@Qty")}</b:Amt>
						<b:UOM id=''{sql:variable("@fk_QtyUOMID")}''>{sql:variable("@QtyUOM")}</b:UOM>
					</b:Qty>
					<b:Time>
						<b:Amt>{sql:variable("@TimeAmt")}</b:Amt>
						<b:UOM id=''{sql:variable("@fk_TimeUOMID")}''>{sql:variable("@TimeUOM")}</b:UOM>
					</b:Time>
				</b:Step_Info>
			)
			as last into (/b:Burp_Belch/b:Payload/b:HopSched_Evnt)[1]
		');

		-- stuff in any note/comment....
		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:HopSched_Evnt/b:Step_Info[last()])[1]
		');

	End -- endof while exists...


	Return 0;
end
go


/*

execute as user = 'BhpApp';
declare @m xml;
declare @rc int;
exec @rc = [bhp].GenBurpHopSchedAllMesg @id=55, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message]; --, @m.query('(/Burp_Belch/Payload/HopSched_Evnt/Info)')
revert;
*/