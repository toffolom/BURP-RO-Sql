use [BHP1-RO]
go

if object_id(N'[bhp].GenRecipeAgingBinderEvntMesg',N'P') is not null
begin
	drop proc [bhp].GenRecipeAgingBinderEvntMesg;
	print 'proc:: [bhp].GenRecipeAgingBinderEvntMesg dropped!!!';
end
go

create proc [bhp].GenRecipeAgingBinderEvntMesg (
	@bid int, -- a aging binder rowid value...
	@evnttype varchar(10), -- must be one of 'add','chg','del'
	@sessid varchar(256),
	@mesg xml output
)
with encryption
as
begin
	Declare @rid int; -- recipe id
	Declare @sid int; -- schedule id
	Declare @custID bigint;
	Declare @custNm nvarchar(200);
	Declare @name varchar(256); -- recipe name
	declare @sname varchar(200); -- schedule name
	Declare @isDraft bit;
	Declare @Lang varchar(20);
	Declare @currow int; -- curr row marker whilst/used to walk'n thru the sched details...
	Declare @SessSrc xml;
	Declare @StepDoc xml; -- temporarily holds a gen'd burp aging step doc...gets strip'd and inserted into this recipe doc
	Declare @fragDoc xml; -- holds just the <Step_Info> node from repo doc
	Declare @notes xml;
	Declare @ts varchar(50);
	Declare @custUID nvarchar(256); -- bhpuid value

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
		@sid = B.fk_AgingSchedMstrID,
		@isDraft = ISNULL(R.isDraft, 1),
		@custID = C.RowID, -- cust id
		@custNm = C.[Name], -- cust name
		@custUID = C.[BHPUid],
		@Lang = ISNULL(C.[DfltLang],'en_us'),
		@notes = [di].fn_ToXMLNote(S.Comments),
		@ts = [di].fn_Timestamp(R.EnteredOn)
	From [bhp].RecipeAgingSchedBinder B
	Inner Join [bhp].AgingSchedMstr S On (B.fk_AgingSchedMstrID = S.RowID)
	Inner Join [bhp].RecipeJrnlMstr R On (B.fk_RecipeJrnlMstrID = R.RowID)
	Inner Join [di].vw_CustomerMstr C On (R.fk_CreatedBy = C.RowID)
	Where (B.RowID = @bid);

	-- stuff in values...
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
			<b:Base type=''aging''>
				<b:Name id=''{sql:variable("@bid")}''>{sql:variable("@sname")}</b:Name>
				<b:Creator_Info custid=''{sql:variable("@custID")}'' uid=''{sql:variable("@custUID")}''>{sql:variable("@custNm")}</b:Creator_Info>
			</b:Base>,
			<b:Aging_Details/>
		)
		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sched_Info)[1]
	');

	-- stuff in any note/comment....
	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert sql:variable("@notes") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sched_Info/b:Base)[1]
	');

	-- now walk thru the detail(s) of sched. Using the proc genBurpAgingSchedStepMesg...we build a repo doc and insert
	-- what we need outta it into this recipe doc.
	-- ea. iteration gens a <Step_Info> node that we stuff into this recipe doc...
	set @currow = 0;
	while exists (Select * from [bhp].AgingSchedDetails where (fk_AgingSchedMstrID = @sid and rowid > @currow))
	begin
		Select Top (1) @currow = [RowID]
		from [bhp].AgingSchedDetails where (fk_AgingSchedMstrID = @sid and rowid > @currow)
		Order By RowID;

		exec [bhp].GenBurpAgingSchedStepMesg @id=@currow, @evnttype=@evnttype, @SessID=@SessID, @mesg = @stepDoc output;

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @StepDoc.query('(/Burp_Belch/Payload/AgingSched_Evnt/Step_Info)');

		set @mesg.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") 
			as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sched_Info/b:Aging_Details)[1]
		');

	end

	set @mesg.modify('
		declare namespace b="http://burp.net/recipe/evnts";
		insert (
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
exec @rc = [bhp].GenRecipeAgingBinderEvntMesg @bid=7, @evnttype='add', @SessID=N'00000000-0000-0000-0000-000000000000', @mesg = @m output;

with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
select @rc [@rc], @m [the message];

*/