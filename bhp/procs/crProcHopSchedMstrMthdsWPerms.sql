USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetHopSchedMstrRecs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetHopSchedMstrRecs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetHopSchedMstrRecs];
Print 'Proc:: [bhp].GetHopSchedMstrRecs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[GetHopSched]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetHopSched]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].GetHopSched;
Print 'Proc:: [bhp].GetHopSched dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[GetHopSched]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[CloneHopSched]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].CloneHopSched;
Print 'Proc:: [bhp].CloneHopSched dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddHopSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddHopSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddHopSchedMstrRec];
Print 'Proc:: [bhp].AddHopSchedMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgHopSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgHopSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgHopSchedMstrRec];
Print 'Proc:: [bhp].ChgHopSchedMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgHopSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelHopSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelHopSchedMstrRec];
Print 'Proc:: [bhp].DelHopSchedMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[EstablishRecipeHopSched]    Script Date: 03/15/2011 15:59:54 ******/
--IF OBJECT_ID(N'[bhp].[EstablishRecipeHopSched]',N'P') IS NOT NULL
--BEGIN
--DROP PROCEDURE [bhp].EstablishRecipeHopSched;
--Print 'Proc:: [bhp].EstablishRecipeHopSched dropped!!!';
--END
--GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetHopSchedMstrRecs (
	@SessID varchar(256),
	@HideZeroRow bit = 0 -- if we should or should NOT return the 'pls select...' row aka: zero row!!!
)
with encryption
as
begin
	--Set Nocount on;
	Declare @SessRowID bigint;
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @admid bigint;
	Declare @SessStatus bit;

	if (1=0)
	Begin
		Select 
			Cast(null As int) As RowID, 
			Cast(null as nvarchar(200)) as Name, 
			Cast(Null As bigint) As fk_CreatedBy, 
			Cast(Null As nvarchar(256)) As CreatedBy,
			Cast(null as int) As TotRecipes, 
			Cast(Null as nvarchar(4000)) As Comments, 
			Cast(Null As Bit) As UnBind,
			Cast(Null As Int) As DeployID,
			Cast(Null as int) As SharingMask,
			Cast(Null as varchar(200)) as SharingMaskAsCSV,
			Cast(Null As numeric(9,2)) As TotBoilTime,
			Cast(Null As int) as fk_TotBoilTimeUOM;
		Set fmtonly off;
		return 0;
	End
	

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @SessRowID=[RowID] from [di].SessionMstr Where (SessID=@SessID);

	Begin Try
		Drop Table #tmpListn;
	End Try
	Begin Catch
	End Catch

	Create Table #tmpListn (
		[RowID] int,
		[Name] nvarchar(200),
		fk_CreatedBy bigint,
		CreatedBy nvarchar(256),
		TotRecipes int,
		Comments nvarchar(4000),
		UnBind bit,
		DeployID int,
		SharingMask int,
		SharingMaskAsCSV varchar(200),
		TotBoilTime numeric(9,2),
		fk_TotBoilTimeUOM int,
		FakeRow int identity(1,1)
	);

	-- stuff in the '0' row...top of the list for drop down!!!
	if (ISNULL(@HideZeroRow,0) = 0)
	Begin
		Set Identity_Insert #tmpListn On;
		Insert Into #tmpListn ([RowID], [Name], fk_CreatedBy, CreatedBy, TotRecipes, Comments, UnBind, DeployID, SharingMask, SharingMaskAsCSV, TotBoilTime, fk_TotBoilTimeUOM,FakeRow)
		Values(0,'pls select...',0,'',0,N'pls enter comment...',0,0,0,'Private',60,bhp.fn_GetUOMIdByNm('min'),0);
		Set Identity_Insert #tmpListn Off;
	End

	exec [di].[GetEnv] @varNm='Admin UID', @varVal=@admid output;
	set @admid = ISNULL(@admid,0);
	
	if (@SessRowID > 0)
	Begin
		Insert Into #tmpListn (
			RowID, 
			Name, 
			fk_CreatedBy, 
			CreatedBy, 
			TotRecipes, 
			Comments, 
			UnBind, 
			DeployID,
			SharingMask,
			SharingMaskAsCSV,
			TotBoilTime,
			fk_TotBoilTimeUOM
		)
		SELECT 
			HSM.[RowID]
			,HSM.[Name]
			,HSM.fk_CreatedBy
			,HSM.CreatedBy
			,ISNULL(XX.Cnt,0) As TotRecipes
			,ISNULL(HSM.[Comments],N'not set') As [Comments]
			,Convert(bit, 0) As UnBind
			,ISNULL(HSM.fk_DeployInfo,S.fk_DeployInfo)
			,ISNULL(HSM.SharingMask,0)
			,HSM.SharingMaskAsCSV
			,ISNULL(HSM.TotBoilTime,60)
			,ISNULL(HSM.fk_TotBoilTimeUOM, [bhp].fn_GetUOMIDByNm('min'))
		FROM [bhp].[HopSchedMstr] HSM 
		Inner Join [di].SessionMstr S 
		On (HSM.fk_DeployInfo = S.fk_DeployInfo And (HSM.fk_CreatedBy=S.fk_CustID OR HSM.fk_CreatedBy = @admid))
		Left Join (
			Select fk_HopSchedMstrID, Count(*) As Cnt
			From [bhp].RecipeHopSchedBinder
			Group By fk_HopSchedMstrID
		) As XX
		On (HSM.RowID = XX.fk_HopSchedMstrID)
		Where (HSM.RowID > 0 And S.SessID = @SessID)
		Order By HSM.[Name];
	End
	Else -- zero session...take all row(s)!!!
	Begin

		Insert Into #tmpListn (
			RowID, 
			Name, 
			fk_CreatedBy, 
			CreatedBy, 
			TotRecipes, 
			Comments, 
			UnBind, 
			DeployID,
			SharingMask,
			SharingMaskAsCSV,
			TotBoilTime,
			fk_TotBoilTimeUOM
		)
		SELECT 
			HSM.[RowID]
			,HSM.[Name]
			,Case HSM.[fk_CreatedBy] 
				When 0 then 
					ISNULL(
						(
							Select Top (1) convert(bigint,VarVal) 
							from [bhp].Environment 
							Where (VarNm = 'Admin UID')
						)
						,0
					)
				else HSM.[fk_CreatedBy] 
			End
			,HSM.CreatedBy
			,ISNULL(XX.Cnt,0) As TotRecipes
			,ISNULL(HSM.[Comments],N'not set') As [Comments]
			,Convert(bit, 0) As UnBind
			,ISNULL(HSM.fk_DeployInfo,0)
			,ISNULL(HSM.SharingMask,0)
			,HSM.SharingMaskAsCSV
			,ISNULL(HSM.TotBoilTime,60)
			,ISNULL(HSM.fk_TotBoilTimeUOM, [bhp].fn_GetUOMIDByNm('min'))
		FROM [bhp].[HopSchedMstr] HSM 
		--Inner Join [di].CustMstr C On (HSM.fk_CreatedBy = C.RowID)
		--Inner Join [di].SessionMstr S On (HSM.fk_DeployInfo = S.fk_DeployInfo)
		Left Join (
			Select fk_HopSchedMstrID, Count(*) As Cnt
			From [bhp].RecipeHopSchedBinder
			Group By fk_HopSchedMstrID
		) As XX
		On (HSM.RowID = XX.fk_HopSchedMstrID)
		Where (HSM.RowID > 0)
		And (ISNULL(HSM.SharingMask,0) != bhp.fn_GetSharingBitValByNm('private'))
		Order By HSM.[Name];
	End

	Select RowID, Name, fk_CreatedBy, CreatedBy, TotRecipes, Comments, UnBind, DeployID, SharingMask, SharingMaskAsCSV, TotBoilTime, fk_TotBoilTimeUOM
	From #tmpListn 
	--Where (FakeRow > (case ISNULL(@HideZeroRow,0) when 1 then 0 else -1 end))
	Order By FakeRow;

	Return 0;
end
go

print 'Proc:: [bhp].GetHopSchedMstrRecs created...';
go

/*
exec [bhp].GetHopSchedMstrRecs @SessID='5B61034A-15CD-49D9-8A74-7DD6DF224BA8',@HideZeroRow=0;
*/

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddHopSchedMstrRec (
	@SessID varchar(256),
	@Name nvarchar(200),
	@fk_CreatedBy bigint,
	@Comment nvarchar(4000) = N'no comment given...',
	@SharingMask int = 0,
	@TotBoilTime numeric(9,2) = 60,
	@fk_TotBoilTimeUOM int = null,
	@BCastMode bit = 1,
	@RowID int output
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @admuid bigint;
	Declare @xml xml;
	--Declare @isCloud varchar(20);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'HopSched';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End	

	exec [di].[GetEnv] @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

	set @fk_TotBoilTimeUOM = case ISNULL(@fk_TotBoilTimeUOM,0) when 0 then [bhp].fn_GetUOMIdByNm('min') else @fk_TotBoilTimeUOM end;

	if (@admuid = 0)
		raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].[GetEnv] @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!

	set @fk_CreatedBy = case @fk_CreatedBy when 0 then @admuid else @fk_CreatedBy end;
	
	If Not Exists (Select * from [di].CustMstr Where RowID = @fk_CreatedBy)
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66018; -- this nbr represents a non-existant customer id!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_TotBoilTimeUOM And AllowedAsTimeMeasure=1)
	Begin
		-- should write and audit record here...foreign key is not a 'time' measure!!!
		Set @rc = 66048; -- this nbr represents a non-existant customer id!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	Insert Into [bhp].HopSchedMstr (
		[Name]
		,[fk_CreatedBy]
		,[Comments]
		,[fk_DeployInfo]
		,SharingMask
		,TotBoilTime
		,fk_TotBoilTimeUOM
	)
	Select
		rtrim(ltrim(@Name)),
		@fk_CreatedBy,
		ISNULL(@Comment,N'no comments given...'),
		ISNULL(
			(Select Top (1) S.fk_DeployInfo From [di].SessionMstr S Where (S.SessID = @SessID)), 
		-1),
		ISNULL(@SharingMask,0),
		ISNULL(@TotBoilTime,60),
		@fk_TotBoilTimeUOM;
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Exec @rc = [bhp].GenBurpHopSchedMstrMesg @id=@RowID, @evnttype='add', @SessID=@SessID, @InfoNodeOnly=0, @Mesg=@xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddHopSchedMstrRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelHopSchedMstrRec (
	@SessID varchar(256),
	@Unbind bit = 0,
	@RowID int,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @unvs varchar(20);
	Declare @xml xml;
	Declare @stepFrag xml;
	Declare @stepDoc xml;
	Declare @currow int;
	Declare @isCloud varchar(20);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'HopSched';

	set @Unbind = ISNULL(@Unbind,0);

	set @unvs = convert(varchar,@Unbind);

	

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].RecipeHopSchedBinder Where (fk_HopSchedMstrID = @RowID And @Unbind = 0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66023; -- this means hop schedule is used by some customer recipe(s)!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].[GetEnv] @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec @rc = [bhp].GenBurpHopSchedMstrMesg @id=@RowID, @evnttype='del', @SessID=@SessID, @InfoNodeOnly=0, @Mesg=@xml output;
	
	-- unbinding a recipe means setting its associated hop sched to '0'...
	If Exists (Select 1 from [bhp].RecipeHopSchedBinder Where fk_HopSchedMstrID=@RowID)
	Begin
		Update [bhp].RecipeHopSchedBinder 
			Set fk_HopSchedMstrID = 0
		Where (fk_HopSchedMstrID = @RowID);

		Set @rc = @@Rowcount;
		Raiserror(N'[%d] recipe''s using this schedule have been ''reset'', or defined as NOT having a schedule now!!!',0,1,@rc);
	End

	/*
	** walk thru any child rec(s) and gen a burp belch msg for ea. and stuff into this burp belch mesg...
	*/
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Set @currow = 0;
		While Exists (Select * from [bhp].HopSchedDetails Where (RowID > @currow) And (fk_HopSchedMstrID = @RowID))
		Begin
			Select Top (1) @currow = RowID
			From [bhp].HopSchedDetails 
			Where (RowID > @currow) And (fk_HopSchedMstrID = @RowID)
			Order By RowID;

			Exec [bhp].GenBurpHopSchedStepMesg @id=@currow, @evnttype='del', @SessID=@SessID, @Mesg = @stepDoc output;

			with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
			select @stepFrag = @stepDoc.query('(/Burp_Belch/Payload/HopSched_Evnt/Step_Info)');

			set @xml.modify('
				declare namespace b="http://burp.net/recipe/evnts";
				insert sql:variable("@stepFrag") as last into (/b:Burp_Belch/b:Payload/b:HopSched_Evnt)[1]
			');

		End
	End

	Delete [bhp].HopSchedDetails Where (fk_HopSchedMstrID = @RowID);
	
	Delete Top (1) [bhp].HopSchedMstr Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelHopSchedMstrRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgHopSchedMstrRec (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(200),
	@fk_CreatedBy bigint,
	@Comment nvarchar(4000) = Null,
	@SharingMask int,
	@TotBoilTime numeric(9,2) = 60,
	@fk_TotBoilTimeUOM int = null,
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table ([Name] nvarchar(200));
	Declare @old nvarchar(200);
	--Declare @isCloud varchar(50);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'HopSched';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	set @fk_TotBoilTimeUOM = case ISNULL(@fk_TotBoilTimeUOM,0) when 0 then [bhp].fn_GetUOMIdByNm('min') else @fk_TotBoilTimeUOM end;
	
	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If (Not Exists (Select * from [bhp].HopSchedMstr Where RowID = @RowID And RowID > 0))
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66020; -- this nbr represents an uknown hop schedule id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@RowID);
		Return @rc;
	End
	
	If ((@fk_CreatedBy Is Not Null) And (Not Exists (Select * from [di].vw_CustomerMstr Where RowID = @fk_CreatedBy)))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66018; -- this nbr represents a non-existant customer id!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_TotBoilTimeUOM And AllowedAsTimeMeasure=1)
	Begin
		-- should write and audit record here...foreign key is not a 'time' measure!!!
		Set @rc = 66048; -- this nbr represents a non-existant customer id!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].[GetEnv] @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!
		
	Update Top (1) [bhp].HopSchedMstr
	Set
		[Name]=@Name,
		[fk_CreatedBy]=ISNULL(@fk_CreatedBy,0),
		[Comments]=ISNULL(@Comment,'Not Set'),
		SharingMask = ISNULL(@SharingMask,0),
		TotBoilTime = ISNULL(@TotBoilTime,60),
		fk_TotBoilTimeUOM = @fk_TotBoilTimeUOM
	Output deleted.Name into @oldinfo([Name])
	Where (RowID=@RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Select @old = [Name] From @oldinfo;

		Exec @rc = [bhp].GenBurpHopSchedMstrMesg @id=@RowID, @evnttype='chg', @SessID=@SessID, @InfoNodeOnly=0, @Mesg=@xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:HopSched_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	end
	
	Return @rc;
End
go

Print 'Proc:: [bhp].ChgHopSchedMstrRec created...';
go

--/*
--** use this guid for testing...
--** '00000000-0000-0000-0000-000000000000'
--*/
--create proc [bhp].EstablishRecipeHopSched (
--	@SessID varchar(256),
--	@RecipeID int,
--	@SchedID int,
--	@force bit = 1, -- if recipe already bound to a hop sched...this'll wack that and then perform the insert...
--	@NuBinderID int output
--)
--with encryption
--as
--begin
--	--Set Nocount on;
	
--	Declare @rc int;
--	Declare @mesg nvarchar(2000);
	
--	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
--	Begin
--		-- should write and audit record here...someone trying to read data w/o logging in!?
--		Set @rc = 66006; -- this nbr represents users is not logged in.
--		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
--		Raiserror(@Mesg,16,1);
--		Return @rc;
--	End

--	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where (RowID = @RecipeID))
--	Begin
--		-- should write and audit record here...
--		Set @rc = 66007; -- non-existant recipe!?
--		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
--		Raiserror(@Mesg,16,1);
--		Return @rc;
--	End

--	Set @Force = ISNULL(@Force,1);

--	if Exists (Select 1 from [bhp].RecipeHopSchedBinder WHere (fk_RecipeJrnlMstrID = @RecipeID) And (@force = 1))
--	Begin
--		Delete Top (1) [bhp].RecipeHopSchedBinder Where (fk_RecipeJrnlMstrID = @RecipeID);
--	End
--	Else
--	Begin
--		If Exists (Select 1 from [bhp].RecipeHopSchedBinder WHere (fk_RecipeJrnlMstrID = @RecipeID))
--		Begin
--			-- should write and audit record here...
--			Set @rc = 66076; -- non-existant recipe!?
--			Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
--			Raiserror(@Mesg,16,1);
--			Return @rc;
--		End
--	End

--	Insert into [bhp].RecipeHopSchedBinder (fk_RecipeJrnlMstrID, fk_HopSchedMstrID)
--	Values (@RecipeID, @SchedID);

--	Set @NuBinderID = SCOPE_IDENTITY();

--	REturn @@ERROR;
--End
--Go

--print 'Proc: [bhp].EstablishRecipeHopSched created...'
--go

--revoke execute on [bhp].GetHopSchedMstrRecs to [Public];
--revoke execute on [bhp].AddHopSchedMstrRec to [Public];
--revoke execute on [bhp].DelHopSchedMstrRec to [Public];
--revoke execute on [bhp].ChgHopSchedMstrRec to [Public];
--go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].CloneHopSched (
	@SessID varchar(256),
	@SchedID int, -- schedule we want to clone
	@NuName nvarchar(200) = null, -- new schedule name...
	@NuRowID int output, -- new id of schedule
	@BCastMode bit = 1,
	@KeepSharingMode bit = 0 -- if we should keep the sharing flag settings 
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @isCloud varchar(50);
	Declare @xml xml;
	Declare @nuRow Table (NuID int);
	Declare @currow int;
	Declare @stepDoc xml;
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'HopSched';
	
	If (@SchedID Is Null)
	Begin
		Raiserror('Parameter:[@SchedID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (Not Exists (Select * from [bhp].HopSchedMstr Where RowID = @SchedID And RowID > 0))
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66020; -- this nbr represents an uknown hop schedule id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@SchedID);
		Return @rc;
	End

	set @NuName = [di].[fn_IsNull](@NuName);
	-- make sure name isn't already in use for this deployment!!!
	If (@NuName IS NOT NULL)
	begin
		If Exists (
			Select 1 
			from [bhp].HopSchedMstr M1
			inner join [bhp].HopSchedMstr M2 On (M1.fk_DeployInfo = M2.fk_DeployInfo And M1.RowID = @SchedID)
			Where M2.Name = @NuName
		)
		Begin
			-- should write and audit record here...someone trying to change an unknown hop type!?
			Set @rc = 66104; -- duplicate hop sched name for deployment
			Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
			Raiserror(@Mesg,16,1,@NuName);
			Return @rc;
		End
	end

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].[GetEnv] @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!

	if (@NuName is null)
	begin
		Declare @ts varchar(50);
		set @ts = parsename(convert(varchar(50),convert(numeric(15,10),getdate())),1);
		Select @NuName = [Name] + '-clone[' + @ts + ']' From [bhp].HopSchedMstr Where RowID=@SchedID;
	end

	Insert into [bhp].HopSchedMstr (Name, fk_CreatedBy, TotRecipes, Comments, fk_DeployInfo, SharingMask, TotBoilTime, fk_TotBoilTimeUOM)
	Output Inserted.RowID Into @nuRow(NuID)
	Select 
		@NuName, 
		fk_CreatedBy, 
		0, 
		N'schedule cloned from:[' + Name + '] on:[' + convert(varchar,getdate()) +']...',
		fk_DeployInfo,
		case ISNULL(@KeepSharingMode,0) when 0 then bhp.fn_GetSharingBitValByNm('private') else SharingMask end,
		TotBoilTime,
		fk_TotBoilTimeUOM
	From [bhp].HopSchedMstr
	Where (RowID = @SchedID);

	Select @NuRowID = NuID From @nuRow;

	Insert Into [bhp].HopSchedDetails(
		fk_HopSchedMstrID, 
		fk_HopTypID, 
		QtyOrAmount, 
		fk_HopUOM, 
		fk_Stage, 
		TimeAmt, 
		fk_TimeUOM, 
		Comment, 
		CostAmt, 
		fk_CostUOM,
		StepName
	)
	Select 
		@NuRowID, 
		fk_HopTypID, 
		ISNULL(QtyOrAmount, 0.00),
		case ISNULL(fk_HopUOM,0) When 0 THen [bhp].fn_getUOMIdByNm('oz') Else fk_HopUOM End, 
		case ISNULL(fk_Stage,0) WHen 0 Then [bhp].fn_GetStageIDByNm('boil') Else fk_Stage End, 
		TimeAmt, 
		case ISNULL(fk_TimeUOM,0) When 0 THen [bhp].fn_GetUOMIdByNm('min') Else fk_TimeUOM End, 
		Comment, 
		ISNULL(CostAmt,0.00), 
		case ISNULL(fk_CostUOM,0) When 0 then [bhp].fn_GetUOMIdByNm('$') Else fk_CostUOM End,
		StepName
	From [bhp].HopSchedDetails
	Where (fk_HopSchedMstrID = @SchedID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin

		Exec @rc = [bhp].GenBurpHopSchedMstrMesg @id=@NuRowID, @evnttype='add', @SessID=@SessID, @InfoNodeOnly=0, @Mesg=@xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;

		-- now send out ea. cloned step...
		set @currow = 0;
		while exists (Select * from [bhp].HopSchedDetails Where fk_HopSchedMstrID=@NuRowID And RowID>@currow)
		begin
			select Top (1) @currow=RowID
			from [bhp].HopSchedDetails WHere (fk_HopSchedMstrID=@NuRowID And RowID > @currow)
			Order By RowID;

			Exec [bhp].GenBurpHopSchedStepMesg @id=@currow, @evnttype='add', @SessID=@SessID, @Mesg=@stepDoc output;
			exec [bhp].[PostToBWPRouter] @inMsg=@stepDoc, @msgNm=@evntNm;
		end

	end

	return @@ERROR;
End
go

checkpoint