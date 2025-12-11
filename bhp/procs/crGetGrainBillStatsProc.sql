use [BHP1-RO]
go

begin try
	drop proc bhp.GetGrainBillInfo;
	print 'proc:: ''bhp.GetGrainBillInfo'' dropped!!!';
end try
begin catch
	print 'proc:: ''bhp.GetGrainBillInfo'' doesn''t exist...no prob!!!';
end catch
go

Create Proc bhp.GetGrainBillInfo (
	@SessID varchar(256),
	@IncPlsSel bit = 1
)
with encryption
as
begin
	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @currow int;
	Declare @status bit;
	Declare @SessRowID bigint;
	Declare @CustID bigint;
	Declare @PrivateBit smallint;
	Declare @SelPrivMode varchar(20);

	Declare @tmpGrains Table (
		RowID int identity(1,1) not null,
		RecipeID int not null,
		RecipeName nvarchar(256) not null,
		fk_GrainMstrID int not null,
		lovi numeric(8,2) not null,
		UOM varchar(50) not null,
		QtyOrAmount numeric(10,4) not null,
		MCU numeric(10,4) null,
		SRM numeric(10,4) Null,
		TrgtVol numeric(6,2) not null
	);

	Declare @stats Table (
		RecipeID int,
		RecipeName nvarchar(256),
		TotGrains numeric(10,4),
		TotMCU numeric(10,4),
		TotSRM numeric(10,4)
	);

	if (1=0)
	begin
		select
			cast(null as int) as RecipeID,
			cast(null as nvarchar(256)) as RecipeName,
			cast(null as numeric(10,4)) As TotGrains,
			cast(null as numeric(10,4)) as TotMCU,
			cast(null as numeric(10,4)) as TotSRM
		set fmtonly off;
		return 0;
	end


	Exec @rc = di.IsSessStale @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec di.getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @SessRowID = [RowID], @CustID = fk_CustID from di.SessionMstr Where SessID=@SessID;
	Select @PrivateBit = [BitVal] from [bhp].SharingTypes Where Descr like 'Priv%';
	Set @PrivateBit = ISNULL(@PrivateBit,0); -- assume 'private' is zero.

	Exec di.getEnv @VarNm='Allow Private Grain Bill Selection Mode', @VarVal=@SelPrivMode output, @DfltVal='no';

	if (di.fn_ISTRUE(@SelPrivMode) = 1) -- allow private grain bill(s) to be qualified.
		set @PrivateBit = -99; -- wacky bitval...so all row(s) will be returned.

	If (@SessRowID = 0)
	Begin
		insert into @tmpGrains (
			RecipeID, 
			RecipeName,
			fk_GrainMstrID, 
			lovi, 
			UOM, 
			QtyOrAmount, 
			MCU,
			SRM,
			TrgtVol
		)
		SELECT 
			R.RowID,
			R.Name,
			G.RowID,
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
			RG.UOM,
			Convert(numeric(10,4),ISNULL(RG.QtyOrAmount, 0.00)) As QtyOrAmount, 
			0.00 As MCU,
			0.00 As SRM,
			R.BatchQty As TrgtVol
		FROM bhp.RecipeGrains As RG
		Inner Join bhp.GrainMstr G On (RG.fk_GrainMstrID = G.RowID)
		Inner Join bhp.RecipeJrnlMstr R On (RG.fk_RecipeJrnlMstrID = R.RowID And R.SharingMask != @PrivateBit)
		Where (R.RowID > 0);
	End
	Else -- only retrieve grain bills that belong to this customer (found thru the session info)
	Begin
		insert into @tmpGrains (
			RecipeID, 
			RecipeName,
			fk_GrainMstrID, 
			lovi, 
			UOM, 
			QtyOrAmount, 
			MCU,
			SRM,
			TrgtVol
		)
		SELECT 
			R.RowID,
			R.Name,
			G.RowID,
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
			RG.UOM,
			Convert(numeric(10,4),ISNULL(RG.QtyOrAmount, 0.00)) As QtyOrAmount, 
			0.00 As MCU,
			0.00 As SRM,
			R.BatchQty As TrgtVol
		FROM bhp.RecipeGrains As RG
		Inner Join bhp.GrainMstr G On (RG.fk_GrainMstrID = G.RowID)
		Inner Join bhp.RecipeJrnlMstr R On (RG.fk_RecipeJrnlMstrID = R.RowID)
		Where (R.RowID > 0 And R.fk_CreatedBy = @CustID);
	End

	set @currow = 0;

	-- walk ea row (RBAR) and calc out the MCU value...
	-- i've choosen to do it this way cause the sql stmt would be unreadable with soooo many
	-- ISNULL stmts and test for value existance...
	-- Plus we don't have a large nbr of grains in recipes!!!
	while exists (select * from @tmpGrains where lovi > 0 And RowID > @currow)
	begin
		select top (1)
			@currow = RowID
		from @tmpGrains 
		where lovi > 0
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

	if (@IncPlsSel = 1)
		insert into @stats values (0,N'Select Grain Bill...',0,0,0);

	insert into @stats
	select
		RecipeID,
		RecipeName,
		Count(*) As TotGrains,
		SUM(ISNULL(MCU,0.00)) As TotMCU,
		SUM(ISNULL(SRM,0.00)) As TotSRM
	from @tmpGrains
	group by RecipeID, RecipeName
	order by RecipeName;

	select RecipeID, RecipeName, TotGrains, TotMCU, TotSRM from @stats;

	return @@ERROR;
end
go

/*

set nocount on;
declare @rc int;
exec @rc = bhp.GetGrainBillInfo @SessID='00000000-0000-0000-0000-000000000000'; --, @incplssel=0;
select @rc;
go

*/