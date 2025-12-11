use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeHopBinderEvntMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeHopBinderEvntMesg;
	print 'proc:: [bhp].GenRecipeHopBinderEvntMesg dropped!!!';
end
go

create proc [bhp].GenRecipeHopBinderEvntMesg (
	@bid int, -- a Hop binder rowid value...
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @rid int; -- recipe id
	Declare @sid int; -- schedule id
	Declare @rcustID bigint;
	Declare @rcustNm nvarchar(200);
	Declare @rcustUID nvarchar(256); -- bhpuid value
	Declare @scustID bigint;
	Declare @scustNm nvarchar(200);
	Declare @scustUID nvarchar(256); -- bhpuid value
	Declare @name varchar(256); -- recipe name
	declare @sname varchar(200); -- schedule name
	Declare @isDraft bit;
	Declare @Lang varchar(20);
	Declare @currow int; -- curr row marker whilst/used to walk'n thru the sched details...
	Declare @SessSrc xml;
	Declare @StepDoc xml; -- temporarily holds a gen'd burp Hop step doc...gets strip'd and inserted into this recipe doc
	Declare @fragDoc xml; -- holds just the <Step_Info> node from repo doc
	Declare @notes xml;
	Declare @ts varchar(50);
	Declare @boilTime numeric(9,2);
	Declare @boilTimeUOM varchar(50);
	Declare @boilTimeUOMID int;
	

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
		insert (
			attribute type {''binder''},
			<b:Recipe_Evnt type=''{sql:variable("@evnttype")}''>
			<b:Info/>
			<b:Sched_Info/>
			</b:Recipe_Evnt>
		)
		into (/b:Burp_Belch/b:Payload)[1]');

	-- now get the <Base> node values...
	Select 
		@name = R.[Name], -- recipe name
		@sname = S.[Name], -- sched name
		@rid = B.fk_RecipeJrnlMstrID,
		@sid = B.fk_HopSchedMstrID,
		@isDraft = ISNULL(R.isDraft, 1),
		@rcustID = C.RowID, -- cust id (recipe creator)
		@rcustNm = C.[Name], -- cust name
		@rcustUID = C.[BHPUid],
		@scustID = C2.RowID, -- cust id of (schedule creator)
		@scustNm = C2.[Name], -- cust name
		@scustUID = C2.[BHPUid],
		@Lang = ISNULL(C.[DfltLang],'en_us'),
		@notes = [di].fn_ToXMLNote(S.Comments),
		@ts = [di].fn_Timestamp(R.EnteredOn),
		@boilTime = ISNULL(S.TotBoilTime, 60),
		@boilTimeUOM = U.UOM,
		@boilTimeUOMID = U.RowID
	From [bhp].RecipeHopSchedBinder B
	Inner Join [bhp].HopSchedMstr S On (B.fk_HopSchedMstrID = S.RowID)
	Inner Join [bhp].RecipeJrnlMstr R On (B.fk_RecipeJrnlMstrID = R.RowID)
	Inner Join [di].vw_CustomerMstr C On (R.fk_CreatedBy = C.RowID)
	Inner Join [di].vw_CustomerMstr C2 On (S.fk_CreatedBy = C2.RowID)
	Inner Join [bhp].UOMTypes U On (ISNULL(S.fk_TotBoilTimeUOM,[bhp].fn_GetUOMIdByNm('min')) = U.RowID)
	Where (B.RowID = @bid);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Base type=''hop'' binder_id=''{sql:variable("@bid")}''>
				<b:Name id=''{sql:variable("@sid")}''>{sql:variable("@sname")}</b:Name>
				<b:BoilTime>
					<b:Amt>{sql:variable("@BoilTime")}</b:Amt>
					<b:UOM id=''{sql:variable("@BoilTimeUOMID")}''>{sql:variable("@BoilTimeUOM")}</b:UOM>
				</b:BoilTime>
				<b:Creator_Info custid=''{sql:variable("@scustID")}'' uid=''{sql:variable("@scustUID")}''>
				{sql:variable("@scustNm")}
				</b:Creator_Info>
			</b:Base>,
			<b:Hop_Details/>
		)
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sched_Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sched_Info/b:Base)[1]
	');

	-- now walk thru the detail(s) of sched. Using the proc genBurpHopSchedStepMesg...we build a repo doc and insert
	-- what we need outta it into this recipe doc.
	-- ea. iteration gens a <Step_Info> node that we stuff into this recipe doc...
	set @currow = 0;
	while exists (Select * from [bhp].HopSchedDetails where (fk_HopSchedMstrID = @sid and rowid > @currow))
	begin
		Select Top (1) @currow = [RowID]
		from [bhp].HopSchedDetails where (fk_HopSchedMstrID = @sid and rowid > @currow)
		Order By RowID;

		exec [bhp].GenBurpHopSchedStepMesg @id=@currow, @evnttype=@evnttype, @SessID=@SessID, @mesg = @stepDoc output;

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @StepDoc.query('(/Burp_Belch/Payload/HopSched_Evnt/Step_Info)');

		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") 
			as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sched_Info/b:Hop_Details)[1]
		');

	end

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Creator custid=''{sql:variable("@rcustID")}'' uid=''{sql:variable("@rcustUID")}''>
				{sql:variable("@rcustNm")}
			</b:Creator>,
			<b:Name>{sql:variable("@name")}</b:Name>,
			<b:IsDraft>{sql:variable("@isDraft")}</b:IsDraft>,
			<b:CreatedOn>{sql:variable("@ts")}</b:CreatedOn>
		) into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info)[1]
	');

	-- set the attributes on node <Info>...id (aka: rowid) and lang
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			attribute recipe_id {sql:variable("@rid")}
		)
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
	');

	Return 0;
end
go


/*

declare @m xml;
declare @rc int;
exec @rc = [bhp].GenRecipeHopBinderEvntMesg @bid=9, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/