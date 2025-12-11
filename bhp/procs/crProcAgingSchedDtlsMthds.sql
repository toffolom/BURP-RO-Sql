USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetAgingSchedDetails]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetAgingSchedDetails]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetAgingSchedDetails];
Print 'Proc:: [bhp].GetAgingSchedDetails dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddAgingSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddAgingSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddAgingSchedDetailRec];
Print 'Proc:: [bhp].AddAgingSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgAgingSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgAgingSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgAgingSchedDetailRec];
Print 'Proc:: [bhp].ChgAgingSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[DelAgingSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelAgingSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelAgingSchedDetailRec];
Print 'Proc:: [bhp].DelAgingSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[DelAgingSchedDetails]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelAgingSchedDetails]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].DelAgingSchedDetails;
Print 'Proc:: [bhp].DelAgingSchedDetails dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetAgingSchedDetails (
	@SessID varchar(256),
	@fk_AgingSchedMstrID int
)
with encryption
as
begin

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
	
	SELECT
		[RowID]
		,[fk_AgingSchedMstrID]
		,ISNULL([StepName],'not set') As StepName
		,[fk_Stage]
		,[StageName]
		,ISNULL([Duration],0.00) As Duration
		,[fk_DurationUOM]
		,[DurationUOM]
		,ISNULL(BegTempRange,0) As BegTempRange
		,ISNULL(EndTempRange,0) As EndTempRange
		,ISNULL(fk_TempRangeUOM,0) As fk_TempRangeUOM
		,TempRangeUOM
		,ISNULL([Comment],'not set...') As Comment
	FROM [bhp].[AgingSchedDetails]
	Where (fk_AgingSchedMstrID = @fk_AgingSchedMstrID And RowID > 0);
	
	Return @@Error;
end
go

print 'Proc:: [bhp].GetAgingSchedDetails created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddAgingSchedDetailRec (
	@SessID varchar(256),
	@fk_AgingSchedMstrID int,
	@StepName varchar(50),
	@fk_StageID int,
	@Duration numeric(14,2),
	@fk_DurationUOMID int,
	@BegTempRange int,
	@EndTempRange int,
	@fk_TempRangeUOMID int,
	@Comment nvarchar(1000) = N'no comment given...',
	@BCastMode bit = 1,
	@RowID int output -- the rowid gen'd after the insert.
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @buff varchar(2000);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'AgingSched';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Not Exists (Select * from [bhp].AgingSchedMstr Where (RowID = @fk_AgingSchedMstrID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66020; -- this nbr represents non-existant hop schedule master id.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@fk_AgingSchedMstrID);
		Return @rc
	End
	

	If Not Exists (Select * from [bhp].vw_StageTypesAllowedInAging Where (RowID = @fk_StageID))
	Begin

		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_StageTypesAllowedInAging;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66047; -- stage id value is NOT defined in allowed in aging schedule view
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TimeUOM Where (RowID = @fk_DurationUOMID))
	Begin
		
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TimeUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in time uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed time types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TemperatureUOM Where (RowID = @fk_TempRangeUOMID))
	Begin
		
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TemperatureUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in time uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed temperature types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End
	
	Insert Into [bhp].AgingSchedDetails (
		[fk_AgingSchedMstrID]
		,StepName
		,fk_Stage
		,Duration
		,fk_DurationUOM
		,BegTempRange
		,EndTempRange
		,fk_TempRangeUOM
		,[Comment]
	)
	Select
		@fk_AgingSchedMstrID,
		@StepName,
		@fk_StageID,
		@Duration,
		@fk_DurationUOMID,
		@BegTempRange,
		@EndTempRange,
		@fk_TempRangeUOMID,
		ISNULL(@Comment,N'No comment provided...');
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpAgingSchedStepMesg @id=@RowID, @evnttype='add', @SessID=@SessID, @Mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddAgingSchedDetailRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelAgingSchedDetailRec (
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
	Declare @evntNm nvarchar(100) = 'AgingSched';

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
		exec @rc = [bhp].GenBurpAgingSchedStepMesg @id=@RowID, @evnttype='del', @SessID=@SessID, @Mesg = @xml output;
	
	Delete [bhp].AgingSchedDetails Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelAgingSchedDetailsRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelAgingSchedDetails (
	@SessID varchar(256),
	@fk_AgingSchedMstrID int
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @stepFrag xml;
	Declare @stepDoc xml;
	Declare @currow int;
	Declare @xml xml;
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

	exec @rc = [bhp].GenBurpAgingSchedMstrMesg @id=@fk_AgingSchedMstrID, @evnttype='del', @SessID=@SessID, @Mesg = @xml output;

	--/*
	--** walk thru any child rec(s) and gen a burp belch msg for ea. and stuff into this burp belch mesg...
	--*/
	Set @currow = 0;
	While Exists (Select * from [bhp].AgingSchedDetails Where (RowID > @currow) And (fk_AgingSchedMstrID = @fk_AgingSchedMstrID))
	Begin
		Select Top (1) @currow = RowID
		From [bhp].AgingSchedDetails 
		Where (RowID > @currow) And (fk_AgingSchedMstrID = @fk_AgingSchedMstrID)
		Order By RowID;

		Exec [bhp].GenBurpAgingSchedStepMesg @id=@currow, @evnttype='del', @SessID=@SessID, @Mesg = @stepDoc output;

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @stepFrag = @stepDoc.query('(/Burp_Belch/Payload/AgingSched_Evnt/Step_Info)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@stepFrag") as last into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt)[1]
		');

	End
	
	Delete [bhp].AgingSchedDetails Where (fk_AgingSchedMstrID = @fk_AgingSchedMstrID);

	exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='AgingSched';
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelAgingSchedDetails created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgAgingSchedDetailRec (
	@SessID varchar(256),
	@RowID int, -- primary key
	@StepName varchar(50),
	@fk_StageID int,
	@Duration numeric(14,2),
	@fk_DurationUOMID int,
	@BegTempRange int,
	@EndTempRange int,
	@fk_TempRangeUOMID int,
	@Comment nvarchar(1000) = N'no comments given...',
	@BCastMode bit = 1
)
with encryption --, execute as 'BHPAdm'
as
begin	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table ([Step] varchar(50));
	Declare @old varchar(50);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'AgingSched';

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
	
	If Not Exists (Select * from [bhp].AgingSchedDetails Where RowID = @RowID And RowID > 0)
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66049; -- this nbr represents an uknown hop schedule id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Not Exists (Select * from [bhp].vw_StageTypesAllowedInAging Where (RowID = @fk_StageID))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_StageTypesAllowedInAging;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66047; -- stage id value is NOT defined in allowed in aging schedule view
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TimeUOM Where (RowID = @fk_DurationUOMID))
	Begin
		Declare @bufff varchar(2000);
		Select @buff = isnull(@bufff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TimeUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in time uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @bufff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	If Not Exists (Select * from [bhp].vw_TemperatureUOM Where (RowID = @fk_TempRangeUOMID))
	Begin
		
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_TemperatureUOM;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66048; -- duration foreign key value is NOT in time uom view.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed temperature types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End
	
	Update Top (1) [bhp].AgingSchedDetails
	Set
		StepName = [di].[fn_IsNull](@StepName),
		fk_Stage = @fk_StageID,
		Duration = @Duration,
		fk_DurationUOM = @fk_DurationUOMID,
		BegTempRange = @BegTempRange,
		EndTempRange = @EndTempRange,
		fk_TempRangeUOM = @fk_TempRangeUOMID,
		Comment=ISNULL(@Comment,'Not Set')
	Output Deleted.StepName into @oldinfo (Step)
	Where (RowID=@RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @old = Step from @oldinfo;

		exec @rc = [bhp].GenBurpAgingSchedStepMesg @id=@RowID, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt/b:Step_Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End
	
	Set @Rc = @@Error;
	
	Return @rc;
End
go

Print 'Proc:: [bhp].ChgAgingSchedDetailRec created...';
go

checkpoint