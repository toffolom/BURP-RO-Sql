USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetMashSchedMstrRecs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetMashSchedMstrRecs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetMashSchedMstrRecs];
Print 'Proc:: [bhp].GetMashSchedMstrRecs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddMashSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddMashSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddMashSchedMstrRec];
Print 'Proc:: [bhp].AddMashSchedMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgMashSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgMashSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgMashSchedMstrRec];
Print 'Proc:: [bhp].ChgMashSchedMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgMashSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelMashSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelMashSchedMstrRec];
Print 'Proc:: [bhp].DelMashSchedMstrRec dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetMashSchedMstrRecs (
	@SessID varchar(256),
	@HideZeroRow bit = 0 -- if we should or should NOT return the 'pls select...' row aka: zero row!!!
)
with encryption
as
begin
	--Set Nocount on;

	if (1=0)
	Begin
		Select
			Cast(Null as int) as RowID,
			Cast(Null as nvarchar(200)) as Name,
			Cast(Null as bigint) as fk_CreatedBy,
			Cast(Null as int) as fk_MashTypeID,
			Cast(Null as int) as TotRecipesUsedIn,
			Cast(Null as numeric(3,2)) as WtrToGrainRatio,
			Cast(Null as int) as fk_WtrToGrainRatioUOM,
			Cast(Null as int) as fk_SpargeType,
			Cast(Null as nvarchar(4000)) as [Comments],
			Cast(Null as bit) as UnBind,
			Cast(Null as bit) as Is4Nu,
			Cast(Null as int) as DeployID,
			Cast(Null As int) as SharingMask,
			Cast(Null as varchar(200)) as SharingMaskAsCSV
		Set FmtOnly Off;
		Return;
	End
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @SessRowID bigint;
	Declare @admid bigint;
	Declare @SessStatus bit;
	
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

	exec [di].getEnv @varNm='Admin UID', @varVal=@admid output;
	set @admid = ISNULL(@admid,0);

	Begin Try
		Drop Table #tmpList;
	End Try
	Begin Catch
	End Catch

	Create Table #tmpList (
		[RowID] int,
		[Name] nvarchar(200),
		fk_CreatedBy bigint,
		fk_MashTypeID int,
		TotRecipesUsedIn int,
		WtrToGrainRatio numeric(3,2),
		fk_WtrToGrainRatioUOM int,
		fk_SpargeType int,
		[Comments] nvarchar(4000),
		UnBind bit,
		Is4Nu bit,
		DeployID int,
		SharingMask int,
		SharingMaskAsCSV varchar(200),
		FakeRow int identity(0,1)
	);

	Insert into #tmpList (
		RowID, 
		Name, 
		fk_CreatedBy, 
		fk_MashTypeID, 
		TotRecipesUsedIn, 
		WtrToGrainRatio, 
		fk_WtrToGrainRatioUOM, 
		fk_SpargeType, 
		Comments, 
		UnBind, 
		Is4Nu,
		DeployID,
		SharingMask,
		SharingMaskAsCSV
	)
	Values(0,'pls select...',0,0,0,1.5,0,0,'pls enter comment...',0,0,0,0,'Private');

	if (@SessRowID > 0)
	Begin


		Insert into #tmpList (
			RowID, 
			Name, 
			fk_CreatedBy, 
			fk_MashTypeID, 
			TotRecipesUsedIn, 
			WtrToGrainRatio, 
			fk_WtrToGrainRatioUOM, 
			fk_SpargeType, 
			Comments, 
			UnBind, 
			Is4Nu, 
			DeployID,
			SharingMask,
			SharingMaskAsCSV
		)
		SELECT 
			MSM.[RowID]
			,MSM.[Name]
			,MSM.fk_CreatedBy
			,ISNULL(MSM.fk_MashTypeID, 0) As fk_MashTypeID
			,ISNULL(XX.Cnt,0) As TotRecipesUsedIn
			,ISNULL(MSM.WtrToGrainRatio,1.5) As WtrToGrainRatio
			,ISNULL(MSM.[fk_WtrToGrainRatioUOM], [bhp].fn_GetUOMIdByNm('qt/lb')) As fk_WtrToGrainRatioUOM
			,ISNULL(MSM.fk_SpargeType, (select top (1) RowID from [bhp].SpargeTypes Where (left([Name],3)='bat'))) As fk_SpargeType
			,ISNULL(MSM.[Comments],N'not set') As [Comments]
			,Convert(bit, 0) As [Unbind]
			,ISNULL(MSM.isDfltForNu,0) As [Is4Nu]
			,ISNULL(MSM.fk_DeployInfo,0)
			,ISNULL(MSM.SharingMask,0)
			,MSM.SharingMaskAsCSV
		FROM [bhp].[MashSchedMstr] MSM
		Inner Join [di].SessionMstr S 
		On (MSM.fk_DeployInfo = S.fk_DeployInfo And (MSM.fk_CreatedBy=S.fk_CustID OR MSM.fk_CreatedBy= @admid))
		Left Join (
			Select fk_MashSchedMstrID, Count(*) As Cnt
			From [bhp].RecipeMashSchedBinder
			Group By fk_MashSchedMstrID
		) As XX
		On (MSM.RowID = XX.fk_MashSchedMstrID)
		Where (MSM.RowID > 0 And S.SessID = @SessID)
		Order By MSM.[Name];
	End
	Else
	Begin
		Insert into #tmpList (
			RowID, 
			Name, 
			fk_CreatedBy, 
			fk_MashTypeID, 
			TotRecipesUsedIn, 
			WtrToGrainRatio, 
			fk_WtrToGrainRatioUOM, 
			fk_SpargeType, 
			Comments, 
			UnBind, 
			Is4Nu, 
			DeployID,
			SharingMask,
			SharingMaskAsCSV
		)
		SELECT 
			MSM.[RowID]
			,MSM.[Name]
			,Case MSM.[fk_CreatedBy] 
				When 0 then 
					ISNULL(
						(
							Select Top (1) convert(bigint,VarVal) 
							from [di].Environment 
							Where (VarNm = 'Admin UID')
						)
						,0
					)
				else MSM.[fk_CreatedBy] 
			End
			,ISNULL(MSM.fk_MashTypeID, 0) As fk_MashTypeID
			,ISNULL(XX.Cnt,0) As TotRecipesUsedIn
			,ISNULL(MSM.WtrToGrainRatio,1.5) As WtrToGrainRatio
			,ISNULL(MSM.[fk_WtrToGrainRatioUOM], [bhp].fn_GetUOMIdByNm('qt/lb')) As fk_WtrToGrainRatioUOM
			,ISNULL(MSM.fk_SpargeType, (select top (1) RowID from [bhp].SpargeTypes Where (left([Name],3)='bat'))) As fk_SpargeType
			,ISNULL(MSM.[Comments],N'not set') As [Comments]
			,Convert(bit, 0) As [Unbind]
			,ISNULL(MSM.isDfltForNu,0) As [Is4Nu]
			,ISNULL(MSM.fk_DeployInfo,0)
			,ISNULL(MSM.SharingMask,0)
			,MSM.SharingMaskAsCSV
		FROM [bhp].[MashSchedMstr] MSM
		Left Join (
			Select fk_MashSchedMstrID, Count(*) As Cnt
			From [bhp].RecipeMashSchedBinder
			Group By fk_MashSchedMstrID
		) As XX
		On (MSM.RowID = XX.fk_MashSchedMstrID)
		Where (MSM.RowID > 0)
		Order By MSM.[Name];
	End

	Select 
		RowID, Name, fk_CreatedBy, fk_MashTypeID, 
		TotRecipesUsedIn, WtrToGrainRatio, fk_WtrToGrainRatioUOM, 
		fk_SpargeType, Comments, UnBind, Is4Nu, DeployID, SharingMask, SharingMaskAsCSV
	From #tmpList
	Where (FakeRow > (case ISNULL(@HideZeroRow,0) when 1 then 0 else -1 end))
	Order By FakeRow;
	
	Return @@ERROR;
end
go

print 'Proc:: [bhp].GetMashSchedMstrRecs created...';
go

/*
exec [bhp].GetMashSchedMstrRecs @SessID='FE5ADA79-49CF-4B6A-9FB1-4A412E9F81A7',@HideZeroRow=1;
exec [bhp].GetMashSchedMstrRecs @SessID='00000000-0000-0000-0000-000000000000',@HideZeroRow=1;
*/

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddMashSchedMstrRec (
	@SessID varchar(256),
	@Name nvarchar(200),
	@fk_CreatedBy bigint,
	@fk_MashTypeID int,
	@WtrToGrainRatio numeric(3,2),
	@fk_WtrToGrainRatioUOM int,
	@fk_SpargeType int,
	@Comment nvarchar(4000) = Null,
	@is4Nu bit = 0,
	@SharingMask int = 0,
	@BCastMode bit = 1,
	@RowID int output
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @buff nvarchar(2000);
	Declare @chgs Table ([RowID] int);
	Declare @curr int;
	Declare @old nvarchar(200);
	Declare @admuid bigint;
	Declare @xml xml;
	--Declare @cloudCtx varchar(30);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = N'MashSched';
	
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

	if (@admuid = 0)
		raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

	set @fk_CreatedBy = case @fk_CreatedBy when 0 then @admuid else @fk_CreatedBy end;
	

	
	/*
	** NOTE: Need to check the role mask of this user/session and verify that they can, indeed, create a Mash schedule!!! Oct22-2014
	*/
	If Not Exists (Select * from [di].CustMstr Where RowID = @fk_CreatedBy)
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66018; -- this nbr represents a non-existant customer id!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_VolumnUOM Where (RowID = @fk_WtrToGrainRatioUOM))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_VolumnUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66055; -- duration foreign key value is NOT in volumn uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].SpargeTypes Where (RowID = ISNULL(@fk_SpargeType,0)))
	Begin
		-- should write/audit record here!!!
		Set @rc = 66078; -- this nbr represents a non-existant sparge type!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Exec [di].[GetEnv] @VarNm='cloud context mode',@varval=@cloudCtx output, @DfltVal='no';
	--if ([di].[fn_ISTRUE](@cloudCtx) = 1)
	--	set @BCastMode = 0;
	
	Insert Into [bhp].MashSchedMstr (
		[Name]
		,[fk_CreatedBy]
		,[fk_MashTypeID]
		,[WtrToGrainRatio]
		,[fk_WtrToGrainRatioUOM]
		,[fk_SpargeType]
		,[Comments]
		,[isDfltForNu]
		,[fk_DeployInfo]
		,[SharingMask]
	)
	Select
		rtrim(ltrim(@Name)),
		@fk_CreatedBy,
		ISNULL(@fk_MashTypeID,0),
		ISNULL(@WtrToGrainRatio, 1.5),
		@fk_WtrToGrainRatioUOM,
		ISNULL(@fk_SpargeType, 0),
		ISNULL(@Comment,N'no comment given...'),
		ISNULL(@is4Nu, 0),
		ISNULL(
			(Select Top (1) S.fk_DeployInfo From [di].SessionMstr S Where (S.SessID = @SessID)), 
		-1),
		ISNULL(@SharingMask,0);
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpMashSchedMstrMesg @id=@RowID, @evnttype='add', @SessID=@SessID, @Mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End

	/*
	** before we're outta here...make sure only (1) row has the isDflt4Nu setting turned 'on'...
	*/
	if (@is4Nu = 1)
	begin
		update [bhp].MashSchedMstr
			set isDfltForNu = 0
		Output Deleted.RowID into @chgs(RowID)
		where (RowID != @RowID and isDfltForNu = 1);
		
		If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Begin
			-- if anything changed we need to broadcast this out...
			if exists (Select 1 from @chgs)
			begin
				set @curr = 0;
				while exists (select * from @chgs where RowID > @curr)
				begin
					select top (1) @curr = RowID from @chgs where RowID > @curr Order By RowID;
					select @old = [Name] from [bhp].MashSchedMstr Where RowID = @curr; -- it really hasn't changed...but we need to output in xml

					exec @rc = [bhp].GenBurpMashSchedMstrMesg @id=@curr, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

					set @xml.modify('
						declare namespace b="http://burp.net/recipe/evnts";
						insert attribute old {sql:variable("@old")}
						into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info/b:Name)[1]
					');

					exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
				end
			end
		End
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddMashSchedMstrRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelMashSchedMstrRec (
	@SessID varchar(256),
	@RowID int,
	@Unbind bit, -- will unbind a recipe from this schedule
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @vcun varchar(20);
	Declare @xml xml;
	Declare @stepFrag xml;
	Declare @stepDoc xml;
	Declare @currow int;
	--Declare @cloudCtx varchar(30);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = N'MashSched';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	set @Unbind = coalesce(@Unbind,0);

	Set @vcun = case @Unbind When 1 then 'true' else 'false' end;

	--Raiserror('[bhp].DelMashSchedMstrRec:: @RowID:[%d] @unbind:[%s]...',0,1,@RowID,@vcun);
	
	If Exists (Select * from [bhp].RecipeMashSchedBinder Where (fk_MashSchedMstrID = @RowID And @Unbind = 0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66053; -- this means Mash schedule is used by some customer recipe(s)!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Exec [di].[GetEnv] @VarNm='cloud context mode',@varval=@cloudCtx output, @DfltVal='no';
	--if ([di].[fn_ISTRUE](@cloudCtx) = 1)
	--	set @BCastMode = 0;
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpMashSchedMstrMesg @id=@RowID, @evnttype='del', @SessID=@SessID, @Mesg = @xml output;
	
	-- unbinding a recipe means setting its associated mash sched to '0'...
	Update [bhp].RecipeMashSchedBinder
		Set fk_MashSchedMstrID = 0
	Where (fk_MashSchedMstrID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		/*
		** walk thru any child rec(s) and gen a burp belch msg for ea. and stuff into this burp belch mesg...
		*/
		Set @currow = 0;
		While Exists (Select * from [bhp].MashSchedDetails Where (RowID > @currow) And (fk_MashSchedMstrID = @RowID))
		Begin
			Select Top (1) @currow = RowID
			From [bhp].MashSchedDetails 
			Where (RowID > @currow) And (fk_MashSchedMstrID = @RowID)
			Order By RowID;

			Exec [bhp].GenBurpMashSchedStepMesg @id=@currow, @evnttype='del', @SessID=@SessID, @Mesg = @stepDoc output;

			with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
			select @stepFrag = @stepDoc.query('(/Burp_Belch/Payload/MashSched_Evnt/Step_Info)');

			set @xml.modify('
				declare namespace b="http://burp.net/recipe/evnts";
				insert sql:variable("@stepFrag") as last into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt)[1]
			');

		End
	End
	
	Delete [bhp].MashSchedDetails Where (fk_MashSchedMstrID = @RowID);
	
	Delete [bhp].MashSchedMstr Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='MashSched';
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelMashSchedMstrRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgMashSchedMstrRec (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(200),
	@fk_CreatedBy bigint,
	@fk_MashTypeID int,
	@WtrToGrainRatio numeric(3,2),
	@fk_WtrToGrainRatioUOM int,
	@fk_SpargeType int,
	@is4Nu bit = 0,
	@Comment nvarchar(4000) = Null,
	@SharingMask int = 0,
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table ([Name] nvarchar(200));
	Declare @old nvarchar(200);
	Declare @chgs table ([RowID] int);
	Declare @curr int; -- current row;
	Declare @buff nvarchar(2000);
	--Declare @cloudCtx varchar(40);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = N'MashSched';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End

	Set @fk_CreatedBy = ISNULL(@fk_CreatedBy,0);
	
	If Not Exists (Select * from [bhp].MashSchedMstr Where RowID = @RowID And RowID > 0)
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66020; -- this nbr represents an uknown schedule id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@RowID);
		Return @rc;
	End
	
	If Not Exists (Select * from [di].CustMstr Where RowID = @fk_CreatedBy And RowID > 0)
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66018; -- this nbr represents a non-existant customer id!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_VolumnUOM Where (RowID = @fk_WtrToGrainRatioUOM))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_VolumnUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66055; -- duration foreign key value is NOT in volumn uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].SpargeTypes Where (RowID = ISNULL(@fk_SpargeType,0)))
	Begin
		-- should write/audit record here!!!
		Set @rc = 66078; -- this nbr represents a non-existant sparge type!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Exec [di].[GetEnv] @VarNm='cloud context mode',@varval=@cloudCtx output, @DfltVal='no';
	--if ([di].[fn_ISTRUE](@cloudCtx) = 1)
	--	set @BCastMode = 0;

	Update [bhp].MashSchedMstr
	Set
		[Name]=@Name,
		[fk_CreatedBy]=@fk_CreatedBy,
		[fk_MashTypeID]=ISNULL(@fk_MashTypeID,0),
		[WtrToGrainRatio] = @WtrToGrainRatio,
		[fk_WtrToGrainRatioUOM] = @fk_WtrToGrainRatioUOM,
		[fk_SpargeType] = ISNULL(@fk_SpargeType,0),
		[Comments]=ISNULL(@Comment,'Not Set'),
		isDfltForNu = ISNULL(@is4Nu,0),
		SharingMask = ISNULL(@SharingMask,0)
	Output deleted.Name into @oldinfo([Name])
	Where (RowID=@RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @old = [Name] From @oldinfo;
	
		exec @rc = [bhp].GenBurpMashSchedMstrMesg @id=@RowID, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End

	/*
	** before we're outta here...make sure only (1) row has the isDflt4Nu setting turned 'on'...
	*/
	if (@is4Nu = 1)
	begin
		update [bhp].MashSchedMstr
			set isDfltForNu = 0
		Output Deleted.RowID into @chgs(RowID)
		where (RowID != @RowID and isDfltForNu = 1);
		
		If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Begin
			-- if anything changed we need to broadcast this out...
			if exists (Select 1 from @chgs)
			begin
				set @curr = 0;
				while exists (select * from @chgs where RowID > @curr)
				begin
					select top (1) @curr = RowID from @chgs where RowID > @curr Order By RowID;
					select @old = [Name] from [bhp].MashSchedMstr Where RowID = @curr; -- it really hasn't changed...but we need to output in xml

					exec @rc = [bhp].GenBurpMashSchedMstrMesg @id=@curr, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

					set @xml.modify('
						declare namespace b="http://burp.net/recipe/evnts";
						insert attribute old {sql:variable("@old")}
						into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Info/b:Name)[1]
					');

					exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
				end
			end
		End
	end
	
	Return @rc;
End
go

Print 'Proc:: [bhp].ChgMashSchedMstrRec created...';
go

checkpoint