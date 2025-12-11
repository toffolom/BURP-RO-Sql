USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetYeastMasterRecs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetYeastMasterRecs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetYeastMasterRecs];
Print 'Proc:: [bhp].GetYeastMasterRecs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddYeastMasterRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddYeastMasterRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddYeastMasterRec];
Print 'Proc:: [bhp].AddYeastMasterRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgYeastMasterRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgYeastMasterRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgYeastMasterRec];
Print 'Proc:: [bhp].ChgYeastMasterRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgYeastMasterRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelYeastMasterRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelYeastMasterRec];
Print 'Proc:: [bhp].DelYeastMasterRec dropped!!!';
END
GO

/*
** use this guid for testing...
** Exec bhp.GetYeastMasterRecs '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetYeastMasterRecs (
	@SessID varchar(256)
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	SELECT 
		[RowID]
		,[Name]
		,ISNULL([fk_YeastMfr],0) As fk_YeastMfr
		--,[MfrNm]
		,ISNULL([fk_YeastType],0) As fk_YeastType
		--,[YeastTypName]
		,ISNULL([fk_YeastPkgTyp],0) As fk_YeastPkgTyp
		--,[PkgDescr]
		,ISNULL([Attenuation],'not set') As Attenuation
		,ISNULL([FermTempBeg],0) As FermTempBeg
		,ISNULL([FermTempEnd],0) As FermTempEnd
		,ISNULL([fk_FermTempUOM], [bhp].[fn_GetUomIDByNm]('F')) As fk_FermTempUOM
		--,[FermTempUOM]
		,ISNULL([di].[fn_IsNull]([KnownAs1]), 'not set') As KnownAs1
		,ISNULL([di].[fn_IsNull]([KnownAs2]), 'not set') As KnownAs2
		,ISNULL([di].[fn_IsNull]([KnownAs3]), 'not set') As KnownAs3
		,ISNULL([NbrOfRecipesUsedIn],0) As NbrOfRecipesUsedIn
		,ISNULL([PSub1],0) As PSub1
		--,[PSubNm1]
		,ISNULL([PSub2],0) As PSub2
		--,[PSubNm2]
		,ISNULL([Notes],'no comment given...') As Notes
		,[EnteredOn]
		,[EnteredBy]
		,ISNULL(Lang, N'en_us') As Lang
		,ISNULL(fk_CountryID,0) As fk_CountryID
		,ISNULL(fk_FlocculationType,0) As fk_FlocculationType
	FROM [bhp].YeastMstr
	WHERE (RowID > 0)
	ORDER BY Name;
	
	Return @@Error;
end
go

print 'Proc:: [bhp].GetYeastMasterRecs created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddYeastMasterRec (
	@SessID varchar(256),
	@Name nvarchar(256), -- name of yeast master record
	@MfrID int = 0, -- id of manufacturer for this yeast
	@TypID int = 0, -- id of yeast type
	@PkgID int = 0, -- id of yeast packaging id
	@Attenuation varchar(50) = Null,
	@BegFermTemp tinyint = 0,
	@EndFermTemp tinyint = 0,
	@TempUOMID int = 0,
	@AKA1 nvarchar(256) = null, -- also known as - 1
	@AKA2 nvarchar(256) = null, -- also known as - 2
	@AKA3 nvarchar(256) = null, -- also known as - 3
	@PSub1 int = 0, -- possible substitute id value (from master info itself)
	@PSub2 int = 0, -- possible substitute id value (from master info itself)
	@Notes nvarchar(2000) = Null, -- any notes you want to add w/record
	@Lang nvarchar(20) = Null, -- language...dflt is 'en_us'
	@fk_CountryID int,
	@fk_FlocculationType int,
	@RowID int output, -- generated rowid value
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @status bit;
	Declare @evntNm nvarchar(100) = N'Yeast';
	
	Set @RowID = -1;
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select 1 from [bhp].YeastMstr Where ([Name] = @Name))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66097; -- yeast name is already in use
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Not Exists (Select * from [bhp].YeastMstr Where RowID = ISNULL(@PSub1,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66044; -- this nbr represents non-existant yeast substitute id.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].YeastMstr Where RowID = ISNULL(@PSub2,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66044; -- this nbr represents non-existant yeast substitute id.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].YeastManufacturers Where RowID = ISNULL(@MfrID,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66036; -- this nbr represents non-existant yeast manufacturer id.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].YeastPackagingTypes Where RowID = ISNULL(@PkgID,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66038; -- this nbr represents non-existant yeast packaging id value.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].YeastTypes Where RowID = ISNULL(@TypID,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66040; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select 1 from [bhp].YeastFlocculationTypes Where RowID = ISNULL(@fk_FlocculationType,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66103; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@fk_FlocculationType);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_TemperatureUOM Where RowID = ISNULL(@TempUOMID,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66043; -- this nbr represents a non-temperature foreign key value.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If ([di].fn_IsNull(@Lang) Is Null)
		Select @Lang = Lang from [di].[SessionMstr] Where SessID = convert(uniqueidentifier,@SessID);
	
	Insert Into [bhp].YeastMstr (
		[Name]
		,[fk_YeastMfr]
		,[fk_YeastType]
		,[fk_YeastPkgTyp]
		,[Attenuation]
		,[FermTempBeg]
		,[FermTempEnd]
		,[fk_FermTempUOM]
		,[KnownAs1]
		,[KnownAs2]
		,[KnownAs3]
		,[PSub1]
		,[PSub2]
		,[Notes]
		,[Lang]
		,[fk_CountryID]
		,[fk_FlocculationType]
	)
	Select
		[di].fn_IsNull(@Name),
		ISNULL(@MfrID,0),
		ISNULL(@TypID,0),
		ISNULL(@PkgID,0),
		Case When @Attenuation = 'not set' Then Null Else RTRIM(LTRIM(@Attenuation)) End,
		ISNULL(@BegFermTemp,0),
		ISNULL(@EndFermTemp,0),
		ISNULL(@TempUOMID,0),
		Case When @AKA1 = 'not set' Then Null Else RTRIM(LTRIM(@AKA1)) End,
		Case When @AKA2 = 'not set' Then Null Else RTRIM(LTRIM(@AKA2)) End,
		Case When @AKA3 = 'not set' Then Null Else RTRIM(LTRIM(@AKA3)) End,
		ISNULL(@PSub1,0),
		ISNULL(@PSub2,0),
		ISNULL(Case When @Notes = 'pls enter a comment...' Then Null Else RTRIM(LTRIM(@Notes)) End, 'no comment given...'),
		ISNULL(@Lang,N'en_us'),
		ISNULL(@fk_CountryID, 0),
		ISNULL(@fk_FlocculationType,0);

	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Exec @rc = [bhp].GenBurpYeastMstrMesg @id=@RowID, @evnttype='add', @SessID = @SessID, @mesg = @xml output;
		Exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End

	Return @@Error;
End
go

Print 'Proc:: [bhp].AddYeastMasterRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelYeastMasterRec (
	@SessID varchar(256),
	@RowID int, -- unique identifier of row to delete (primary key value).
	@WipeSubRefs bit = 0, -- if (1) then we'll find all PSUB1/PSub2 values and set them to zero...since we're wiping this master record and the psubs would be dangling references...
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @evntNm nvarchar(100) = N'Yeast';
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].vw_RecipeYeastBinder Where (YeastID= @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66042; -- this nbr represents that yeast is used in a recipe and cannot be removed!!!
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec @rc = [bhp].GenBurpYeastMstrMesg @id=@RowID, @evnttype='del', @SessID = @SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].YeastMstr Where (RowID = @RowID);

	If (@WipeSubRefs = 1)
	Begin
		Update [bhp].YeastMstr
			Set PSub1 = 0
		Where (PSub1 = @RowID);

		Update [bhp].YeastMstr
				Set PSub2 = 0
		Where (PSub2 = @RowID);
	End

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;

	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelYeastMasterRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgYeastMasterRec (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(256), -- name of yeast master record
	@MfrID int, -- id of manufacturer for this yeast
	@TypID int, -- id of yeast type
	@PkgID int, -- id of yeast packaging id
	@Attenuation varchar(50) = Null,
	@BegFermTemp tinyint = Null,
	@EndFermTemp tinyint = Null,
	@TempUOMID int = Null,
	@AKA1 nvarchar(256) = null, -- also known as - 1
	@AKA2 nvarchar(256) = null, -- also known as - 2
	@AKA3 nvarchar(256) = null, -- also known as - 3
	@PSub1 int = Null, -- possible substitute id value (from master info itself)
	@PSub2 int = Null, -- possible substitute id value (from master info itself)
	@Notes nvarchar(2000) = N'no comments given...', -- any notes you want to add w/record
	@Lang nvarchar(20) = 'en_us', -- language...dflt is 'en_us'
	@fk_CountryID int,
	@fk_FlocculationType int,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @old Table ([Name] nvarchar(256), mfrID int);
	Declare @oldNm nvarchar(256);
	Declare @oldMfrNm nvarchar(300);
	Declare @evntNm nvarchar(100) = N'Yeast';

		
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If Not Exists (Select * from [bhp].YeastMstr Where (RowID = ISNULL(@RowID,0) And RowID > 0))
	Begin
		-- should write and audit record here...someone trying to change an unknown Yeast type!?
		Set @rc = 66045; -- this nbr represents an unknown Yeast Mstr id
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select 1 from [bhp].YeastMstr Where ([Name] = @Name And RowID != @RowID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66097; -- changing yeast name to a name already in use!!!
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select 1 from [bhp].YeastFlocculationTypes Where RowID = ISNULL(@fk_FlocculationType,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66103; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@fk_FlocculationType);
		Return @rc;
	End
	
	/*
	** launch the actual update now....
	*/
	Update Top (1) [bhp].YeastMstr
		Set
			[Name] = @Name,
			fk_YeastMfr = ISNULL(@MfrID,0),
			fk_YeastType = ISNULL(@TypID,0),
			fk_YeastPkgTyp = ISNULL(@PkgID,0),
			Attenuation = ISNULL(@Attenuation, (Select Top (1) Attenuation from [bhp].YeastMstr Where (RowID = @RowID))),
			FermTempBeg = ISNULL(@BegFermTemp, (Select Top (1) FermTempBeg from [bhp].YeastMstr Where (RowID = @RowID))),
			FermTempEnd = ISNULL(@EndFermTemp, (Select Top (1) FermTempEnd from [bhp].YeastMstr Where (RowID = @RowID))),
			fk_FermTempUOM = ISNULL(@TempUOMID, (Select Top (1) fk_FermTempUOM from [bhp].YeastMstr Where (RowID = @RowID))),
			KnownAs1 = ISNULL(@AKA1, (Select Top (1) KnownAs1 from [bhp].YeastMstr Where (RowID = @RowID))),
			KnownAs2 = ISNULL(@AKA2, (Select Top (1) KnownAs2 from [bhp].YeastMstr Where (RowID = @RowID))),
			KnownAs3 = ISNULL(@AKA3, (Select Top (1) KnownAs3 from [bhp].YeastMstr Where (RowID = @RowID))),
			PSub1 = ISNULL(@PSub1, (Select Top (1) PSub1 from [bhp].YeastMstr Where (RowID = @RowID))),
			PSub2 = ISNULL(@PSub2, (Select Top (1) PSub2 from [bhp].YeastMstr Where (RowID = @RowID))),
			Notes = ISNULL(@Notes,(select top (1) Notes from [bhp].YeastMstr Where (RowID=@RowID))),
			Lang = ISNULL(@Lang,(select top (1) Lang from [bhp].YeastMstr Where (RowID=@RowID))),
			fk_CountryID = ISNULL(@fk_CountryID, 0),
			fk_FlocculationType = ISNULL(@fk_FlocculationType,0)
	Output Deleted.Name, ISNULL(Deleted.fk_YeastMfr,0) into @old(Name, mfrID)
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @oldNm = O.[Name], @oldMfrNm=M.[Name]
		From @old O Inner Join [bhp].YeastManufacturers M On (O.mfrID = M.RowID)
	
		Exec @rc = [bhp].GenBurpYeastMstrMesg @id=@RowID, @evnttype='chg', @SessID = @SessID, @mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:Mstr_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldMfrNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:Yeast_Evnt/b:MfrInfo)[1]
		');

		Exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgYeastMasterRec created...';
go

checkpoint
go

