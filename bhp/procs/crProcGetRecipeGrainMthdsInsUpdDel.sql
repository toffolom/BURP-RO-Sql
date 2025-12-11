use [BHP1-RO]
go

begin try
	drop proc [bhp].GetRecipeGrains;
	print 'proc: [bhp].GetRecipeGrains dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].GetRecipeGrains doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].AddRecipeGrain;
	print 'proc: [bhp].AddRecipeGrain dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].AddRecipeGrain doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].DelRecipeGrain;
	print 'proc: [bhp].DelRecipeGrain dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].DelRecipeGrain doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].ChgRecipeGrain;
	print 'proc: [bhp].ChgRecipeGrain dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].ChgRecipeGrain doesn''t exist...no prob!!!',0,1);
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeGrains (
	@SessID varchar(256),
	@RecipeID int
)
with encryption
as
begin
	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @currow int;
	Declare @tmpGrains Table (
		RowID int not null,
		fk_RecipeJrnlMstrID int not null,
		fk_GrainMstrID int not null,
		lovi numeric(8,2) not null,
		fk_GrainUOM int not null,
		UOM varchar(50) not null,
		QtyOrAmount numeric(10,4) not null,
		fk_Stage int not null,
		Comment nvarchar(4000) null,
		MCU numeric(10,4) null,
		SRM numeric(10,4) Null,
		TrgtVol numeric(6,2) not null
	);

	if (1=0)
	begin
		select
			cast(null as int) as RowID,
			cast(null as int) as fk_RecipeJrnlMstrID,
			cast(null as int) as fk_GrainMstrID,
			cast(null as int) as fk_GrainUOM,
			cast(null as numeric(10,4)) As QtyOrAmount,
			cast(null as int) as fk_Stage,
			cast(null as nvarchar(4000)) as Comment,
			cast(null as numeric(10,4)) as MCU,
			cast(null as numeric(10,4)) as SRM
		set fmtonly off;
		return 0;
	end

	Set @rc = 0;

	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	insert into @tmpGrains (
		RowID, 
		fk_RecipeJrnlMstrID, 
		fk_GrainMstrID, 
		lovi, 
		fk_GrainUOM, 
		UOM, 
		QtyOrAmount, 
		fk_Stage, 
		Comment, 
		MCU,
		SRM,
		TrgtVol
	)
	SELECT 
		RG.RowID, 
		RG.fk_RecipeJrnlMstrID, 
		RG.fk_GrainMstrID,
		case
			when (ISNULL(G.degLStart,0) = ISNULL(G.degLEnd,0)) Then ISNULL(G.degLStart,0.00) -- no range or zero
			when ISNULL(G.degLStart,0) < ISNULL(G.degLEnd,0) -- this is expect entry start < end
				then
					ISNULL(G.degLStart,0) + ((ISNULL(G.degLEnd,0) - ISNULL(G.degLStart,0)) / 2)
			when ISNULL(G.degLStart,0) > ISNULL(G.degLEnd,0) -- lovibond entries are backwards!!!
				then
					ISNULL(G.degLEnd,0) + ((ISNULL(G.degLStart,0) - ISNULL(G.degLEnd,0)) / 2)
			else
				0	
		end As lovi,
		RG.fk_GrainUOM,
		RG.UOM,
		Convert(numeric(10,4),ISNULL(RG.QtyOrAmount, 0.00)) As QtyOrAmount, 
		ISNULL(RG.fk_Stage, 0) As fk_Stage,
		ISNULL(RG.[Comment], 'no comment given...') As Comment,
		0.00 As MCU,
		0.00 As SRM,
		R.BatchQty As TrgtVol
	FROM [bhp].RecipeGrains As RG
	Inner Join [bhp].GrainMstr G On (RG.fk_GrainMstrID = G.RowID)
	Inner Join [bhp].RecipeJrnlMstr R On (RG.fk_RecipeJrnlMstrID = R.RowID)
	WHERE (RG.fk_RecipeJrnlMstrID = @RecipeID);

	set @currow = 0;

	-- walk ea row (RBAR) and calc out the MCU value...
	-- i've choosen to do it this way cause the sql stmt would be unreadable with soooo many
	-- ISNULL stmts and test for value existance...
	-- Plus we don't have a large nbr of grains in recipes!!!
	while exists (
		select * from @tmpGrains 
		where fk_RecipeJrnlMstrID=@RecipeID And lovi > 0
		And RowID > @currow
	)
	begin
		select top (1)
			@currow = RowID
		from @tmpGrains 
		where fk_RecipeJrnlMstrID=@RecipeID And lovi > 0
		And RowID > @currow
		Order By RowID;

		update @tmpGrains
			set MCU = 
				case UOM
				when 'lb' then ((lovi * QtyOrAmount) / TrgtVol)
				when 'oz' then ((lovi * (QtyOrAmount / 16)) / TrgtVol)
				when 'cup' then ((lovi * ((QtyOrAmount * 8) / 16)) / TrgtVol)
				when 'qt' then ((lovi * ((QtyOrAmount * 32) / 16)) / TrgtVol)
				when 'pt' then ((lovi * QtyOrAmount) / TrgtVol)
				else 0
				end
		Where (RowID = @currow);

		Update @tmpGrains
			set SRM = 1.4922 * (ISNULL(MCU,0) * .6859)
		where (RowID = @currow);

	end -- endof while exists...

	select
		RowID,
		fk_RecipeJrnlMstrID,
		fk_GrainMstrID,
		fk_GrainUOM,
		QtyOrAmount,
		fk_Stage,
		Comment,
		ISNULL(MCU,0.00) As MCU,
		ISNULL(SRM,0.00) As SRM
	from @tmpGrains;

	return @@ERROR;
end
go

create proc [bhp].AddRecipeGrain (
	@SessID varchar(256),
	@fk_RecipeJrnlMstrID int,
	@fk_GrainMstrID int,
	@fk_GrainUOM int,
	@fk_StageID int,
	@QtyOrAmt numeric(10,4),
	@Comment nvarchar(4000),
	@RowID int output,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @fragDoc xml;
	
	Set @rc = 0;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if (@QtyOrAmt is null or @QtyOrAmt < 0)
	begin
		-- should write and audit record here...
		Set @rc = 66071; -- qty/amt values must be positive
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where RowID = @fk_RecipeJrnlMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- represents an unknown recipe
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].GrainMstr Where RowID = @fk_GrainMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66032; -- represents an unknown grain
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].StageTypes Where RowID = @fk_StageID and AllowedInMashSched=1)
	Begin
		-- should write and audit record here...
		Set @rc = 66054; -- represents stage value is not setup for mashing
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_GrainUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	insert into [bhp].RecipeGrains (fk_RecipeJrnlMstrID, fk_GrainMstrID, fk_GrainUOM, QtyOrAmount, fk_Stage, Comment)
	select @fk_RecipeJrnlMstrID, @fk_GrainMstrID, @fk_GrainUOM, @QtyOrAmt, @fk_StageID, ISNULL(@Comment,'not set');

	Set @RowID = SCOPE_IDENTITY();

	--if (@BCastMode = 1)
	--begin
		exec @rc = [bhp].GenRecipeGrainMesg @rid=@fk_RecipeJrnlMstrID, @gid=@fk_GrainMstrID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='Recipe-Grains';
	--end

	return @@ERROR;
end
go

create proc [bhp].DelRecipeGrain (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @fragDoc xml;
	Declare @rid int;
	Declare @gid int;
	
	Set @rc = 0;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @rid = fk_RecipeJrnlMstrID, @gid = fk_GrainMstrID
	From [bhp].RecipeGrains
	Where (RowID = @RowID);

	--if (@BCastMode = 1)
		exec @rc = [bhp].GenRecipeGrainMesg @rid=@rid, @gid=@gid, @evnttype='del', @SessID=@SessID, @mesg = @xml output;

	Delete Top (1) [bhp].RecipeGrains Where (RowID = @RowID);
	
	--if (@BCastMode = 1)
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='Recipe-Grains';

	return @@ERROR;
end
go

create proc [bhp].ChgRecipeGrain (
	@SessID varchar(256),
	@RowID int,
	@fk_RecipeJrnlMstrID int,
	@fk_GrainMstrID int,
	@fk_GrainUOM int,
	@fk_StageID int,
	@QtyOrAmt numeric(10,4),
	@Comment nvarchar(4000),
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @fragDoc xml;
	Declare @oldinfo Table (grainid int, uomid int, qty numeric(10,4), stageid int, recipeID int);
	Declare @oldgrainNm nvarchar(256);
	Declare @olduomnm varchar(50);
	Declare @oldqty numeric(10,4);
	Declare @oldstagenm nvarchar(100);
	Declare @oldgrainMfrNm nvarchar(300);
	Declare @OldrecipeNm nvarchar(256);
	
	Set @rc = 0;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if (@QtyOrAmt is null or @QtyOrAmt < 0)
	begin
		-- should write and audit record here...
		Set @rc = 66071; -- qty/amt values must be positive
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	end

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where RowID = @fk_RecipeJrnlMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- represents an unknown recipe
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].GrainMstr Where RowID = @fk_GrainMstrID)
	Begin
		-- should write and audit record here...
		Set @rc = 66032; -- represents an unknown grain
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].StageTypes Where RowID = @fk_StageID and AllowedInMashSched=1)
	Begin
		-- should write and audit record here...
		Set @rc = 66054; -- represents stage value is not setup for mashing
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_GrainUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Update [bhp].RecipeGrains
		Set
		fk_RecipeJrnlMstrID = @fk_RecipeJrnlMstrID,
		fk_GrainMstrID = @fk_GrainMstrID,
		fk_GrainUOM = @fk_GrainUOM,
		fk_Stage = @fk_StageID,
		QtyOrAmount = @QtyOrAmt,
		Comment = ISNULL(@Comment, 'no comment given...')
	Output Deleted.fk_GrainMstrID, Deleted.fk_GrainUOM, Deleted.fk_Stage, Deleted.QtyOrAmount, Deleted.fk_RecipeJrnlMstrID
	Into @oldinfo(grainid, uomid, stageid, qty, recipeID)
	Where (RowID = @RowID);

	-- grab the old name(s) and stuff into the outbound xml doc as attribute(s) 'old' in ea. appropriate place
	Select @oldgrainNm=G.[Name], @oldstagenm=S.[Name], @olduomnm=U.[UOM], @oldqty=I.qty, @oldgrainMfrNm=M.[Name], @OldrecipeNm=R.Name
	From @oldinfo I
	Inner Join [bhp].GrainMstr G On (I.grainid = G.RowID)
	Inner Join [bhp].StageTypes S On (I.stageid = S.RowID)
	Inner Join [bhp].UOMTypes U On (I.uomid = U.RowID)
	Inner Join [bhp].GrainManufacturers M On (G.fk_GrainMfr = M.RowID)
	Inner Join [bhp].RecipeJrnlMstr R On (I.recipeID = R.RowID)

	--if (@BCastMode = 1)
	--begin
		exec @rc = [bhp].GenRecipeGrainMesg @rid=@fk_RecipeJrnlMstrID, @gid=@fk_GrainMstrID, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;

		-- stuff in the 'old' attr's now...
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldgrainnm")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Grains/b:Grain/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldgrainMfrNm")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Grains/b:Grain/b:MfrInfo)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@olduomnm")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Grains/b:Grain/b:Qty/b:UOM)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldqty")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Grains/b:Grain/b:Qty/b:Amt)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldstagenm")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Grains/b:Grain/b:Stage)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldrecipenm")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='Recipe-Grains';
	--end

	return @@ERROR;
end
go

checkpoint
go