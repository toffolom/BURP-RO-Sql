USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetMashSchedDetails]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetMashSchedDetails]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetMashSchedDetails];
Print 'Proc:: [bhp].GetMashSchedDetails dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddMashSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddMashSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddMashSchedDetailRec];
Print 'Proc:: [bhp].AddMashSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgMashSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgMashSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgMashSchedDetailRec];
Print 'Proc:: [bhp].ChgMashSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[DelMashSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelMashSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelMashSchedDetailRec];
Print 'Proc:: [bhp].DelMashSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[DelMashSchedDetails]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelMashSchedDetails]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].DelMashSchedDetails;
Print 'Proc:: [bhp].DelMashSchedDetails dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetMashSchedDetails (
	@SessID varchar(256),
	@fk_MashSchedMstrID int
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
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
	
	--If Not Exists (Select * from [bhp].MashSchedMstr Where (RowID = @fk_MashSchedMstrID))
	--Begin
	--	-- should write and audit record here...someone trying to read data w/o logging in!?
	--	Set @rc = 66020; -- this nbr represents non-existant Mash schedule master id.
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1);
	--	Return @rc
	--End
	
	SELECT
		[RowID]
		,[fk_MashSchedMstrID]
		,[StepName]
		,[Pos]
		,ISNULL(fk_StageTypID, 0) As fk_StageTypeID
		,ISNULL(StrikeTempAmt, 0.00) As StrikeTempAmt
		,ISNULL(fk_StrikeTempUOM, 0) As fk_StrikeTempUOMID
		,ISNULL(BegTargetTempAmt, 0.00) As BegTargetTempAmt
		,ISNULL(EndTargetTempAmt, 0.00) As EndTargetTempAmt
		,ISNULL(fk_TargetTempsUOM, 0) As fk_TargetTempsUOMID
		,ISNULL(BegTimeAmt, 0.00) As BegTimeAmt
		,ISNULL(EndTimeAmt, 0.00) As EndTimeAmt
		,ISNULL(fk_TimeUOM, 0) As fk_TimeUOMID
		,ISNULL(WaterAmt, 0.00) As WaterAmt
		,ISNULL(fk_WaterUOM, 0) As fk_WaterUOMID
		,ISNULL(GrainAmt, 0.00) As GrainAmt
		,ISNULL(fk_GrainUOM, 0) As fk_GrainAmtUOMID
		,ISNULL(Comments,'not set...') As Comments
	FROM [bhp].[MashSchedDetails]
	Where (fk_MashSchedMstrID = @fk_MashSchedMstrID And RowID > 0)
	Order By [Pos];
	
	Return 0;
end
go

print 'Proc:: [bhp].GetMashSchedDetails created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddMashSchedDetailRec (
	@SessID varchar(256),
	@fk_MashSchedMstrID int,
	@StepName varchar(50),
	@Position int,
	@fk_StageUOMID int,
	@StrikeTempAmt numeric(12,2) = 0.00,
	@fk_StrikeTempAmtUOMID int,
	@BegTargetTempAmt numeric(12,2) = 0.00,
	@EndTargetTempAmt numeric(12,2) = 0.00,
	@fk_TargetTempsAmtUOMID int,
	@BegTimeAmt numeric(12,2) = 0.00,
	@EndTimeAmt numeric(12,2) = 0.00,
	@fk_TimeAmtUOMID int,
	@WaterAmt numeric(12,2) = 0.00,
	@fk_WaterAmtUOMID int,
	@GrainAmt numeric(12,2) = 0.00,
	@fk_GrainAmtUOMID int,
	@Comment nvarchar(4000) = N'no comments given...',
	@BCastMode bit = 1,
	@RowID int output -- the rowid gen'd after the insert.
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @buff varchar(2000); -- general purpose buffer...
	Declare @xml xml;
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
	
	If Not Exists (Select * from [bhp].MashSchedMstr Where (RowID = @fk_MashSchedMstrID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66020; -- this nbr represents non-existant schedule master id.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@fk_MashSchedMstrID);
		Return @rc
	End
	

	If Not Exists (Select * from [bhp].vw_StageTypesAllowedInMash Where (RowID = @fk_StageUOMID))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_StageTypesAllowedInMash;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66054; -- stage id value is NOT defined in allowed in Mash schedule view
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TimeUOM Where (RowID = @fk_TimeAmtUOMID))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TimeUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in time uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TemperatureUOM Where (RowID = @fk_TargetTempsAmtUOMID))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TemperatureUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in temperature uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TemperatureUOM Where (RowID = @fk_StrikeTempAmtUOMID))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TemperatureUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in temperature uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_VolumnUOM Where (RowID = @fk_WaterAmtUOMID))
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

	If Not Exists (Select * from [bhp].vw_WeightUOM Where (RowID = @fk_GrainAmtUOMID))
	Begin
		Set @buff = null;

		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_WeightUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66056; -- duration foreign key value is NOT in weight uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End
	
	Insert Into [bhp].MashSchedDetails (
		[fk_MashSchedMstrID]
		,[StepName]
		,[Pos]
		,fk_StageTypID
		,StrikeTempAmt
		,fk_StrikeTempUOM
		,BegTargetTempAmt
		,EndTargetTempAmt
		,fk_TargetTempsUOM
		,BegTimeAmt
		,EndTimeAmt
		,fk_TimeUOM
		,WaterAmt
		,fk_WaterUOM
		,GrainAmt
		,fk_GrainUOM
		,[Comments]
	)
	Select
		@fk_MashSchedMstrID,
		@StepName,
		@Position,
		@fk_StageUOMID,
		@StrikeTempAmt,
		@fk_StrikeTempAmtUOMID,
		@BegTargetTempAmt,
		@EndTargetTempAmt,
		@fk_TargetTempsAmtUOMID,
		@BegTimeAmt,
		@EndTimeAmt,
		@fk_TimeAmtUOMID,
		@WaterAmt,
		@fk_WaterAmtUOMID,
		@GrainAmt,
		@fk_GrainAmtUOMID,
		ISNULL(@Comment,N'not set');
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpMashSchedStepMesg @id=@RowID, @evnttype='add', @SessID=@SessID, @Mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddMashSchedDetailRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelMashSchedDetailRec (
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

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpMashSchedStepMesg @id=@RowID, @evnttype='del', @SessID=@SessID, @Mesg = @xml output;
	
	Delete Top (1) [bhp].MashSchedDetails Where (RowID = @RowID And RowID > 0);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelMashSchedDetailsRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelMashSchedDetails (
	@SessID varchar(256),
	@fk_MashSchedMstrID int
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
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
	
	Delete [bhp].MashSchedDetails Where (fk_MashSchedMstrID = @fk_MashSchedMstrID And fk_MashSchedMstrID > 0);
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelMashSchedDetails created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgMashSchedDetailRec (
	@SessID varchar(256),
	@fk_MashSchedMstrID int, -- primary key
	@StepName varchar(50),
	@RowID int, -- primary key.
	@Position int,
	@fk_StageUOMID int,
	@StrikeTempAmt numeric(12,2) = 0.00,
	@fk_StrikeTempAmtUOMID int,
	@BegTargetTempAmt numeric(12,2) = 0.00,
	@EndTargetTempAmt numeric(12,2) = 0.00,
	@fk_TargetTempsAmtUOMID int,
	@BegTimeAmt numeric(12,2) = 0.00,
	@EndTimeAmt numeric(12,2) = 0.00,
	@fk_TimeAmtUOMID int,
	@WaterAmt numeric(12,2) = 0.00,
	@fk_WaterAmtUOMID int,
	@GrainAmt numeric(12,2) = 0.00,
	@fk_GrainAmtUOMID int,
	@Comment nvarchar(4000) = N'no comment given...',
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @buff varchar(2000); -- general purpose buffer...
	Declare @xml xml;
	Declare @oldinfo Table ([Step] varchar(50));
	Declare @old varchar(50);
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

	If (@fk_MashSchedMstrID is null)
	Begin
		Raiserror('Parameter:[@fk_MashSchedMstrID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If Not Exists (Select * from [bhp].MashSchedDetails Where fk_MashSchedMstrID = @fk_MashSchedMstrID And RowID = @RowID And RowID > 0)
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66057; -- this nbr represents an uknown mash schedule detail record
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Not Exists (Select * from [bhp].vw_StageTypesAllowedInMash Where (RowID = @fk_StageUOMID))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_StageTypesAllowedInMash;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66054; -- stage id value is NOT defined in allowed in Mash schedule view
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TimeUOM Where (RowID = @fk_TimeAmtUOMID))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TimeUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in time uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TemperatureUOM Where (RowID = @fk_TargetTempsAmtUOMID))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TemperatureUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in temperature uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TemperatureUOM Where (RowID = @fk_StrikeTempAmtUOMID))
	Begin
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TemperatureUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in temperature uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_VolumnUOM Where (RowID = @fk_WaterAmtUOMID))
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

	If Not Exists (Select * from [bhp].vw_WeightUOM Where (RowID = @fk_GrainAmtUOMID))
	Begin
		Set @buff = null;

		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_WeightUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66056; -- duration foreign key value is NOT in weight uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End
	
	Update Top (1) [bhp].MashSchedDetails
	Set
		StepName = @StepName,
		Pos = @Position,
		fk_StageTypID = @fk_StageUOMID,
		StrikeTempAmt = @StrikeTempAmt,
		fk_StrikeTempUOM = @fk_StrikeTempAmtUOMID,
		BegTargetTempAmt = @BegTargetTempAmt,
		EndTargetTempAmt = @EndTargetTempAmt,
		fk_TargetTempsUOM = @fk_TargetTempsAmtUOMID,
		BegTimeAmt = @BegTimeAmt,
		EndTimeAmt = @EndTimeAmt,
		fk_TimeUOM = @fk_TimeAmtUOMID,
		WaterAmt = @WaterAmt,
		fk_WaterUOM = @fk_WaterAmtUOMID,
		GrainAmt = @GrainAmt,
		fk_GrainUOM = @fk_GrainAmtUOMID,
		Comments=ISNULL(@Comment,'Not Set')
	Output Deleted.StepName into @oldinfo ([Step])
	Where (fk_MashSchedMstrID=@fk_MashSchedMstrID And RowID=@RowID And fk_MashSchedMstrID > 0);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @old = [Step] from @oldinfo;

		exec @rc = [bhp].GenBurpMashSchedStepMesg @id=@RowID, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:MashSched_Evnt/b:Step_Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End
	
	Set @Rc = @@Error;
	
	Return @rc;
End
go

Print 'Proc:: [bhp].ChgMashSchedDetailRec created...';
go

checkpoint