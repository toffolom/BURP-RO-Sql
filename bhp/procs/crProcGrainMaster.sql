USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetGrainMasterRecs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetGrainMasterRecs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetGrainMasterRecs];
Print 'Proc:: [bhp].GetGrainMasterRecs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddGrainMasterRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddGrainMasterRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddGrainMasterRec];
Print 'Proc:: [bhp].AddGrainMasterRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgGrainMasterRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgGrainMasterRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgGrainMasterRec];
Print 'Proc:: [bhp].ChgGrainMasterRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgGrainMasterRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelGrainMasterRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelGrainMasterRec];
Print 'Proc:: [bhp].DelGrainMasterRec dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetGrainMasterRecs (
	@SessID varchar(256)
)
with encryption
as
begin	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @cCtx bit;
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

	
	--Select @cCtx = [di].fn_ISTRUE(VarVal) from [bhp].Environment Where VarNm='cloud context mode';
	--Set @cCtx = ISNULL(@cCtx,0);

	--If Exists (Select * from [di].SessionMstr WHere SessID=@SessID And RowID=0) -- And @cCtx=1)
	--Begin
	--	-- should write and audit record here...someone trying to read data w/o logging in!?
	--	Set @rc = 66141; -- admin session trying to read data is not allowed on cloud
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1);
	--	Return @rc;	
	--End
	
	SELECT
		GM.[RowID]
		,GM.[Name]
		,GM.[degLStart]
		,GM.[degLEnd]
		,ISNULL(GM.[SRM],0.0) As SRM
		/*
		** degEBC is computed. Formula is: ((2.65)*[degLStart]-(1.2))
		** problem is that if degLStart is zero the outcome is -1.2...we can't drop the table at this point
		** too much bother...just fix it here...mjt 19Aug2014
		** to fix we'll compute it here when we pull out and fix the situation.
		*/
		,Case ISNULL(GM.degLStart,0)
			When 0 Then 0.0
			Else (((2.65) * GM.degLStart) - 1.2) 
		End As degEBC 
		,ISNULL(GM.[fk_GrainType],0) As fk_GrainType
		-- ,[GrainType]
		,ISNULL(GM.[RowSize],0) As RowSize
		,ISNULL([di].[fn_IsNull](GM.[KnownAs1]), 'not set') As KnownAs1
		,ISNULL([di].[fn_IsNull](GM.[KnownAs2]), 'not set') As KnownAs2
		,ISNULL([di].[fn_IsNull](GM.[KnownAs3]), 'not set') As KnownAs3
		,ISNULL(GM.[fk_GrainMfr],0) As fk_GrainMfr
		,ISNULL(GM.[NbrOfRecipesUsedIn],0) As NbrOfrecipesUsedIn
		,GM.fk_CountryID
		,ISNULL(GM.[isModified],1) As isModified
		,ISNULL(GM.[isUnderModified],0) As isUnderModified
		,GM.[EnteredOn]
		,GM.[EnteredBy]
		,ISNULL(GM.PotentialGravityBeg,0.00) As PotentialGravityBeg
		,ISNULL(GM.PotentialGravityEnd,0.00) As PotentialGravityEnd
		,ISNULL(GM.Comment,'not set') As Comment
 	FROM [bhp].[GrainMstr] GM
	Where (GM.RowID > 0); -- And GM.fk_DeployInfo = (Select Top (1) fk_DeployInfo from [di].SessionMstr WHere SessID=@SessID));
	
	Return 0;
end
go

print 'Proc:: [bhp].GetGrainMasterRecs created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddGrainMasterRec (
	@SessID varchar(256),
	@Name nvarchar(256), -- name of new grain master record. e.g: 'crystal 120'
	@loviBondStart numeric(8,2) = 0.0,
	@loviBondEnd numeric(8,2) = 0.0,
	@srm numeric(8,2) = 0.0,
	@fk_GrainTypeID int = 0,
	@rowsz int = 0,
	@aka1 varchar(256) = null,
	@aka2 varchar(256) = null,
	@aka3 varchar(256) = null,
	@fk_GrainMfrID int = 0,
	@fk_CountryID int,
	@isModified bit = 1,
	@isUnderModified bit = 0,
	@PotentialGravityBeg numeric(5,4) = 0.00,
	@PotentialGravityEnd numeric(5,4) = 0.00,
	@Comment nvarchar(1000) = null,
	@RowID int output, -- generated rowid value
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	--Declare @cCtx bit;
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'Grain';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Select @cCtx = [di].fn_ISTRUE(VarVal) from [bhp].Environment Where VarNm='cloud context mode';
	--Set @cCtx = ISNULL(@cCtx,0);

	--If Exists (Select * from [di].SessionMstr WHere SessID=@SessID And RowID=0 And @cCtx=1)
	--Begin
	--	-- should write and audit record here...someone trying to read data w/o logging in!?
	--	Set @rc = 66142; -- admin session trying to read data is not allowed on cloud
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1);
	--	Return @rc;	
	--End

	--If (@cCtx=1)
	--	Set @BCastMode=0;

	If Not Exists (Select * from [bhp].GrainTypes Where RowID = @fk_GrainTypeID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66030; -- represents an unknown grain type id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].GrainManufacturers Where RowID = @fk_GrainMfrID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66031; -- represents an unknown grain manuf id value
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select 1 from [bhp].GrainMstr Where (Name = @Name))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66098; -- grain name is already taken
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select 1 from [di].Countries Where (RowID = @fk_CountryID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66140; -- grain name is already taken
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@fk_CountryID);
		Return @rc;
	End
	
	Insert Into [bhp].GrainMstr (
		[Name]
		,[degLStart]
		,[degLEnd]
		,[SRM]
		,[fk_GrainType]
		,[RowSize]
		,[KnownAs1]
		,[KnownAs2]
		,[KnownAs3]
		,[fk_GrainMfr]
		,[fk_CountryID]
		,[isModified]
		,[isUnderModified]
		,[PotentialGravityBeg]
		,[PotentialGravityEnd]
		,[Comment]
	)
	Select
		[di].fn_IsNull(@Name), 
		ISNULL(@loviBondStart,0.0),
		ISNULL(@loviBondEnd,0.0),
		ISNULL(@srm,0.0),
		@fk_GrainTypeID,
		ISNULL(@rowsz,0),
		Case When @AKA1 = 'not set' Then Null Else [di].[fn_IsNull](@AKA1) End,
		Case When @AKA2 = 'not set' Then Null Else [di].[fn_IsNull](@AKA2) End,
		Case When @AKA3 = 'not set' Then Null Else [di].[fn_IsNull](@AKA3) End,
		@fk_GrainMfrID,
		ISNULL(@fk_CountryID,0),
		ISNULL(@isModified,1),
		ISNULL(@isUnderModified,0),
		ISNULL(@PotentialGravityBeg,0.00),
		ISNULL(@PotentialGravityEnd,0.00),
		ISNULL(@Comment,'no comment given...');


	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenBurpGrainMstrMesg @id = @RowID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	End
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddGrainMasterRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelGrainMasterRec (
	@SessID varchar(256),
	@RowID int, -- unique identifier of row to delete (primary key value).
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	--Declare @cCtx bit;
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'Grain';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Select @cCtx = [bhp].fn_ISTRUE(VarVal) from [bhp].Environment Where VarNm='cloud context mode';
	--Set @cCtx = ISNULL(@cCtx,0);
	--If (@cCtx=1)
	--	Set @BCastMode=0;

	--If Exists (Select * from [di].SessionMstr WHere SessID=@SessID And RowID=0 And @cCtx=1)
	--Begin
	--	-- should write and audit record here...someone trying to read data w/o logging in!?
	--	Set @rc = 66143; -- admin session trying to read data is not allowed on cloud
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1);
	--	Return @rc;	
	--End
	
	/*
	** NOTE: this is also enforced at the trigger level...
	*/
	If Exists (Select * from [bhp].RecipeGrains Where (fk_GrainMstrID = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66029; -- represents a Grain Master record is used in a recipe.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpGrainMstrMesg @id = @RowID, @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].GrainMstr Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelGrainMasterRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgGrainMasterRec (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(256), -- name of new grain master record. e.g: 'crystal 120'
	@loviBondStart numeric(8,2) = 0.0,
	@loviBondEnd numeric(8,2) = 0.0,
	@srm numeric(8,2) = 0.0,
	@fk_GrainTypeID int,
	@rowsz int = 0,
	@aka1 varchar(256) = null,
	@aka2 varchar(256) = null,
	@aka3 varchar(256) = null,
	@fk_GrainMfrID int,
	@fk_CountryID int,
	@isModified bit = 1,
	@isUnderModified bit = 0,
	@PotentialGravityBeg numeric(5,4) = 0.00,
	@PotentialGravityEnd numeric(5,4) = 0.00,
	@Comment nvarchar(1000) = null,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table ([Name] nvarchar(256), [MfrID] int);
	Declare @oldNm nvarchar(256);
	Declare @oldMfrNm nvarchar(300);
	--Declare @cCtx bit;
	Declare @SessStatus bit;
	Declare @EvntNm nvarchar(100) = N'Grain';
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End	

	If (ISNULL(@RowID,0) = 0)
	Begin
		Raiserror('Parameter:[@RowID] must be provided and cannot be ''zero''...aborting!!!',16,1);
		Return -1;
	End
	
	If Not Exists (Select * from [bhp].GrainMstr Where RowID = @RowID)
	Begin
		-- should write and audit record here...someone trying to change an unknown Grain type!?
		Set @rc = 66032; -- represents an unknown Grain Master Record ID
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].GrainTypes Where RowID = @fk_GrainTypeID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66030; -- represents an unknown grain type id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].GrainManufacturers Where RowID = @fk_GrainMfrID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66031; -- represents an unknown grain manuf id value
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select 1 from [bhp].GrainMstr Where (Name = @Name And RowID != @RowID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66098; -- grain name is already taken
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @fk_CountryID = ISNULL(@fk_CountryID,0);

	If Not Exists (Select 1 from [di].Countries Where (RowID = @fk_CountryID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66140; -- grain name is already taken
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@fk_CountryID);
		Return @rc;
	End
	
	/*
	** launch the actual update now....
	*/
	Update Top (1) [bhp].GrainMstr
		Set
		Name = @Name,
		degLStart = @loviBondStart,
		degLEnd = @loviBondEnd,
		SRM = @srm,
		fk_GrainType = @fk_GrainTypeID,
		RowSize = @rowsz,
		KnownAs1 = Case When @AKA1 = 'not set' Then Null Else [di].[fn_IsNull](@AKA1) End,
		KnownAs2 = Case When @AKA2 = 'not set' Then Null Else [di].[fn_IsNull](@AKA2) End,
		KnownAs3 = Case When @AKA3 = 'not set' Then Null Else [di].[fn_IsNull](@AKA3) End,
		fk_GrainMfr = @fk_GrainMfrID,
		--NbrOfRecipesUsedIn = 0,
		fk_CountryID = @fk_CountryID,
		isModified = @isModified,
		isUnderModified = @isUnderModified,
		PotentialGravityBeg = ISNULL(@PotentialGravityBeg, 0.00),
		PotentialGravityEnd = ISNULL(@PotentialGravityEnd,0.00),
		Comment = ISNULL(@Comment,'no comment given...')
	Output Deleted.Name, deleted.fk_GrainMfr into @oldinfo([Name],[MfrID])
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @oldNm = O.[Name], @oldMfrNm=M.[Name]
		From @oldinfo O Inner Join [bhp].GrainManufacturers M On (O.mfrID = M.RowID)
	
		exec @rc = [bhp].GenBurpGrainMstrMesg @id = @RowID, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:Grain_Evnt/b:Mstr_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldMfrNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:Grain_Evnt/b:MfrInfo)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @MsgNm=@EvntNm;
	End
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgGrainMasterRec created...';
go


checkpoint
