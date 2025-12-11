USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetHopSchedDetails]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetHopSchedDetails]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetHopSchedDetails];
Print 'Proc:: [bhp].GetHopSchedDetails dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddHopSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddHopSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddHopSchedDetailRec];
Print 'Proc:: [bhp].AddHopSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgHopSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgHopSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgHopSchedDetailRec];
Print 'Proc:: [bhp].ChgHopSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[DelHopSchedDetailRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelHopSchedDetailRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelHopSchedDetailRec];
Print 'Proc:: [bhp].DelHopSchedDetailRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[DelHopSchedDetails]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelHopSchedDetails]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].DelHopSchedDetails;
Print 'Proc:: [bhp].DelHopSchedDetails dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetHopSchedDetails (
	@SessID varchar(256),
	@fk_HopSchedMstrID int
)
with encryption
as
begin
	--Set NoCount On;
	
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
	
	--If Not Exists (Select * from [bhp].HopSchedMstr Where (RowID = @fk_HopSchedMstrID))
	--Begin
	--	-- should write and audit record here...someone trying to read data w/o logging in!?
	--	Set @rc = 66020; -- this nbr represents non-existant hop schedule master id.
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1);
	--	Return @rc
	--End
	
	SELECT
		HSD.[RowID]
		,HSD.[fk_HopSchedMstrID]
		,HSD.StepName
		,HSD.[fk_HopTypID]
		--,[HopName]
		,HSD.[QtyOrAmount]
		,HSD.[fk_HopUOM]
		--,[HopUOM]
		,HSD.[fk_Stage]
		--,[StageName]
		,HSD.[TimeAmt]
		,HSD.[fk_TimeUOM]
		--,[TimeUOM]
		,ISNULL(HSD.[Comment],N'no comment yet...') As [Comment]
		,ISNULL(HSD.[CostAmt],0.00) As [CostAmt]
		,ISNULL(HSD.[fk_CostUOM],0) As [fk_CostUOM]
		,HT.[fk_HopMfrID]
		--,[costUOM]
	FROM [bhp].[HopSchedDetails] HSD 
	Inner Join [bhp].HopTypesV2 HT On (HSD.[fk_HopTypID] = HT.RowID)
	Where (HSD.fk_HopSchedMstrID = @fk_HopSchedMstrID)
	Order By HSD.TimeAmt DESC;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetHopSchedDetails created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddHopSchedDetailRec (
	@SessID varchar(256),
	@fk_HopSchedMstrID int,
	@StepName varchar(50),
	@fk_HopID int,
	@HopQtyOrAmt numeric(14,2),
	@fk_HopQtyUOMID int,
	@fk_StageID int,
	@TimeAmt numeric(14,2),
	@fk_TimeUOMID int,
	@Comment nvarchar(4000) = Null,
	@HopCost numeric(6,2) = 0.00,
	@fk_CostUOMID int = 0,
	@RowID int output, -- the rowid gen'd after the insert.
	@BCastMode bit = 1
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
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
	
	If Not Exists (Select * from [bhp].HopSchedMstr Where (RowID = @fk_HopSchedMstrID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66020; -- this nbr represents non-existant hop schedule master id.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@fk_HopSchedMstrID);
		Return @rc
	End
	
	If Not Exists (Select * from [bhp].HopTypesV2 Where (RowID = @fk_HopID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66014; -- this nbr represents non-existant hop schedule master id.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc
	End
	
	If Not Exists (Select * from [bhp].vw_StageTypesAllowedInHop Where (RowID = @fk_StageID))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_StageTypesAllowedInHop;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66022; -- this represents a bad stage type for a hop schedule.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].[GetEnv] @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!
	
	Insert Into [bhp].HopSchedDetails (
		[fk_HopSchedMstrID]
		,[StepName]
		,[fk_HopTypID]
		,[QtyOrAmount]
		,[fk_HopUOM]
		,[fk_Stage]
		,[TimeAmt]
		,[fk_TimeUOM]
		,[Comment]
		,[CostAmt]
		,[fk_CostUOM]
	)
	Select
		@fk_HopSchedMstrID,
		@StepName,
		@fk_HopID,
		@HopQtyOrAmt,
		case ISNULL(@fk_HopQtyUOMID,0) When 0 THen [bhp].fn_getUOMIdByNm('oz') Else @fk_HopQtyUOMID End,
		case ISNULL(@fk_StageID,0) WHen 0 Then [bhp].fn_GetStageIDByNm('boil') Else @fk_StageID End,
		@TimeAmt,
		case ISNULL(@fk_TimeUOMID,0) When 0 THen [bhp].fn_GetUOMIdByNm('min') Else @fk_TimeUOMID End,
		ISNULL(@Comment,N'No comment provided...'),
		ISNULL(@HopCost,0.00),
		case ISNULL(@fk_CostUOMID,0) When 0 then [bhp].fn_GetUOMIdByNm('$') Else @fk_CostUOMID End
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec @rc = [bhp].GenBurpHopSchedStepMesg @id=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddHopSchedDetailRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelHopSchedDetailRec (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set NoCount On;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	--Declare @isCloud varchar(20);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'HopSched';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)	--Raiserror(N'proc::[bhp].DelHopSchedDetailRec -> @RowID:[%d]...',0,1,@RowID);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].[GetEnv] @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpHopSchedStepMesg @id=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].HopSchedDetails Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelHopSchedDetailsRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelHopSchedDetails (
	@SessID varchar(256),
	@fk_HopSchedMstrID int
)
with encryption
as
begin
	--Set NoCount On;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @xml xml;
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
	
	Delete [bhp].HopSchedDetails Where (fk_HopSchedMstrID = @fk_HopSchedMstrID);
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelHopSchedDetails created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgHopSchedDetailRec (
	@SessID varchar(256),
	@fk_HopSchedMstrID int, -- primary key
	@StepName varchar(50),
	@RowID int, -- primary key
	@fk_HopID int = null,
	@HopQtyOrAmt numeric(14,2) = null,
	@fk_HopQtyUOMID int = null,
	@fk_StageID int = null,
	@TimeAmt numeric(14,2) = null,
	@fk_TimeUOMID int = null,
	@Comment nvarchar(4000) = Null,
	@HopCost numeric(6,2) = 0.00, -- not really using these two...just here for now to ease the DataSet generator
	@fk_CostUOMID int = 0,
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set NoCount On;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table ([Name] varchar(50), [fk_HopID] int);
	Declare @oldStepNm varchar(50);
	--Declare @isCloud varchar(20);
	Declare @oldHopNm nvarchar(100);
	Declare @oldHopMfrNm nvarchar(300);
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

	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If Not Exists (Select * from [bhp].HopSchedMstr Where RowID = @fk_HopSchedMstrID)
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66020; -- this nbr represents an uknown schedule id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@fk_HopSchedMstrID);
		Return @rc;
	End
	

	
	If ((@fk_StageID Is Not Null) And (Not Exists (Select * from [bhp].vw_StageTypesAllowedInHop Where (RowID = @fk_StageID))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + rtrim(ltrim([Name])) from [bhp].vw_StageTypesAllowedInHop;
		/*
		** NEED TO FIX THIS SO I CaN PASS PARAMS INTO I18N Retrieved MESG CAT REC!!!!
		*/
		Set @rc = 66022; -- this represents a bad stage type for a hop schedule.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Select @Mesg = isnull(@Mesg,'') + char(10) + 'Allowed stage types are:[' + @buff + ']...';
		Raiserror(@Mesg,16,1);
		Return @rc
	End

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].[GetEnv] @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!
	
	Update Top (1) [bhp].HopSchedDetails
	Set
		StepName=@StepName,
		fk_HopTypID=ISNULL(@fk_HopID,0),
		QtyOrAmount=ISNULL(@HopQtyOrAmt,0),
		fk_HopUOM=case ISNULL(@fk_HopQtyUOMID,0) when 0 then [bhp].fn_GetUOMIdByNm('oz') Else @fk_HopQtyUOMID ENd,
		fk_Stage=case ISNULL(@fk_StageID,0) when 0 then [bhp].fn_GetStageIDByNm('boil') Else @fk_StageID End,
		TimeAmt=ISNULL(@TimeAmt,0),
		fk_TimeUOM=case ISNULL(@fk_TimeUOMID,0) when 0 then [bhp].fn_GetUOMIdByNm('min') Else @fk_TimeUOMID End,
		Comment=ISNULL(@Comment,'Not Set'),
		CostAmt=ISNULL(@HopCost,0),
		fk_CostUOM=case ISNULL(@fk_CostUOMID,0) when 0 then [bhp].fn_GetUOMIdByNm('$') Else @fk_CostUOMID End
	Output Deleted.StepName, Deleted.fk_HopTypID
	Into @oldinfo([Name], [fk_HopID])
	Where (fk_HopSchedMstrID=@fk_HopSchedMstrID And RowID=@RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin

		Select @oldStepNm = [O].[Name], @oldHopNm=H.[Name], @oldHopMfrNm=M.[Name]
		From @oldinfo As [O]
		Inner Join [bhp].HopTypesV2 H On (H.RowID = O.fk_HopID)
		Inner Join [bhp].HopManufacturers M On (M.RowID = H.fk_HopMfrID)
	
		exec @rc = [bhp].GenBurpHopSchedStepMesg @id=@RowID, @evnttype='chg', @SessID=@SessID, @mesg=@xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldStepNm")}
			into (/b:Burp_Belch/b:Payload/b:HopSched_Evnt/b:Step_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldHopNm")}
			into (/b:Burp_Belch/b:Payload/b:HopSched_Evnt/b:Step_Info/b:Hop_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldHopMfrNm")}
			into (/b:Burp_Belch/b:Payload/b:HopSched_Evnt/b:Step_Info/b:Hop_Info/b:MfrInfo)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	end
	
	Set @Rc = @@Error;
	
	Return @rc;
End
go

Print 'Proc:: [bhp].ChgHopSchedDetailRec created...';
go

checkpoint