USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetHopTypesV2]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetHopTypesV2]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetHopTypesV2];
Print 'Proc:: [bhp].GetHopTypesV2 dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddHopTypeV2]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddHopTypeV2]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddHopTypeV2];
Print 'Proc:: [bhp].AddHopTypeV2 dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgHopTypeV2]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgHopTypeV2]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgHopTypeV2];
Print 'Proc:: [bhp].ChgHopTypeV2 dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[DelHopTypeV2]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelHopTypeV2]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelHopTypeV2];
Print 'Proc:: [bhp].DelHopTypeV2 dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetHopTypesV2 (
	@SessID varchar(256)
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	SELECT 
		HT.RowID, 
		HT.Name, 
		ISNULL(di.fn_IsNull(HT.AKA),'not set') AKA, 
		HT.AlphaAcidLow, 
		HT.AlphaAcidHigh, 
		HT.BetaAcidLow, 
		HT.BetaAcidHigh, 
		--HT.IBU, 
		HT.Pellet, 
		HT.Flower, 
		--HT.RowSz, 
		HT.HomeGrwn, 
		--HT.OpCost,
		--HT.fk_OpCostUOM, HT.OpCostUOM AS CostUOM, 
		HT.isOil, 
		HT.isExtract, 
		HT.NbrOfRecipesUsedIn, 
		ISNULL(PSub1,0) As PSub1,
		ISNULL(PSub2,0) As PSub2,
		ISNULL(PSub3,0) As PSub3,
		ISNULL(PSub4,0) As PSub4,
		ISNULL(PSub5,0) As PSub5,
		ISNULL(HT.fk_HopMfrID, 0) As fk_HopMfrID,
		ISNULL(HM.[Name],'not set') AS ManufName, 
		--Case ISNULL(HM.fk_VolDiscUOM, 0) When 0 Then [bhp].fn_GetUOMIdByNm('lb') Else HM.fk_VolDiscUOM End As fk_VolDiscUOM, 
		--Case ISNULL(HM.fk_VolDiscUOM, 0) When 0 Then [bhp].fn_GetUOM([bhp].fn_GetUOMIdByNm('lb')) Else HM.UOMDescr End As VolDiscUOMDescr,
		--Convert(Int, Case ISNULL(HM.MinOrderQty,0) When 0 Then -99 Else HM.MinOrderQty End) As VolDiscMinOrder,
		ISNULL(HT.Commentary, 'no comment given...') As Commentary,
		HT.EnteredOn, 
		ISNULL(HT.Lang,'en_us') As Lang,
		ISNULL(fk_CountryID, 0) As fk_CountryID,
		ISNULL(HT.fk_HopPurposeID, 0) As fk_HopPurposeID
	FROM [bhp].HopTypesV2 AS HT 
	LEFT JOIN [bhp].HopManufacturers AS HM ON (ISNULL(HT.fk_HopMfrID,0) = HM.RowID)
	--INNER JOIN [bhp].UOMTypes AS U1 ON (HT.fk_OpCostUOM = U1.RowID)
	--INNER JOIN [bhp].UOMTypes AS U2 ON (HM.fk_VolDiscUOM = U2.RowID)
	WHERE  (HT.RowID > 0)
	ORDER BY HT.Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetHopTypesV2 created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddHopTypeV2 (
	@SessID varchar(256),
	@Name nvarchar(100),
	@Aka nvarchar(100) = null,
	@AlphaAcidLow numeric(5,2) = 0.0,
	@AlphaAcidHigh numeric(5,2) = 0.0,
	@BetaAcidLow numeric(5,2) = 0.0,
	@BetaAcidHigh numeric(5,2) = 0.0,
	--@IBU numeric(5,2) = 0.0,
	--@Cost money = 0.0,
	--@CostUOMID int = 0,
	@MfrID int = 0,
	@Notes nvarchar(2000) = null,
	@IsPellet bit = 0,
	@IsFlower bit = 0,
	@IsHomeGrwn bit = 0,
	@IsOil bit = 0,
	@IsExtract bit = 0,
	@PSub1ID int = 0,
	@PSub2ID int = 0,
	@PSub3ID int = 0,
	@PSub4ID int = 0,
	@PSub5ID int = 0,
	@Lang varchar(20) = null,
	@fk_CountryID int,
	@fk_HopPurposeID int,
	@RowID int output,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @EvntNm nvarchar(100) = N'Hop';
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	--If ((@CostUOMID > 0) And (Not Exists (Select * from [bhp].vw_MonetaryUOM Where RowID = @CostUomID)))
	--Begin
	--	-- should write and audit record here...someone trying use a non-monetary uom value
	--	Set @rc = 66010; -- this nbr represents a non-monetary uom error.
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1);
	--	Return @rc;
	--End
	
	If (@Lang Is Null)
		Select @Lang = Lang from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID);
	
	Insert Into [bhp].HopTypesV2 (
		[Name]
		,[AKA]
		,[AlphaAcidLow],[AlphaAcidHigh]
		,[BetaAcidLow],[BetaAcidHigh]
		--,[IBU]
		,[Pellet]
		,[Flower]
		,[HomeGrwn]
		,[OpCost]
		,[fk_OpCostUOM]
		,[Lang]
		,[Commentary]
		,[isOil]
		,[isExtract]
		,[fk_HopMfrID]
		,[PSub1],[PSub2],[PSub3],[PSub4],[PSub5],
		[fk_CountryID],
		[fk_HopPurposeID]
	)
	Select
		@Name,
		di.fn_IsNull(@Aka),
		ISNULL(@AlphaAcidLow,0), ISNULL(@AlphaAcidHigh,0),
		ISNULL(@BetaAcidLow,0), ISNULL(@BetaAcidHigh,0),
		--ISNULL(@IBU, 0.0),
		ISNULL(@IsPellet,0),
		ISNULL(@IsFlower,0),
		ISNULL(@IsHomeGrwn,0),
		0.00,
		[bhp].fn_getUOMIDbyNm('$'),
		ISNULL(@Lang,'en_us'),
		ISNULL(Case When @Notes = 'pls enter a comment...' Then Null Else RTRIM(LTRIM(@Notes)) End, 'no comment given...'),
		ISNULL(@IsOil,0),
		ISNULL(@IsExtract,0),
		ISNULL(@MfrID,0),
		ISNULL(@PSub1ID,0),
		ISNULL(@PSub2ID,0),
		ISNULL(@PSub3ID,0),
		ISNULL(@PSub4ID,0),
		ISNULL(@PSub5ID,0),
		ISNULL(@fk_CountryID, 0),
		ISNULL(@fk_HopPurposeID, 0);

	Select @RowID = SCOPE_IDENTITY();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Exec @rc = [bhp].GenBurpHopMstrMesg @id = @RowID, @evnttype='add', @SessID = @SessID, @mesg = @xml output;
		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddHopTypeV2 created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelHopTypeV2 (
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
	Declare @EvntNm nvarchar(100) = N'Hop';
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Exists (Select * from [bhp].HopSchedDetails Where (fk_HopTypID = @RowID))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66011; -- this nbr represents a non-monetary uom error.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec @rc = [bhp].GenBurpHopMstrMesg @id = @RowID, @evnttype='del', @SessID = @SessID, @mesg = @xml output;
	
	Delete From [bhp].HopTypesV2 Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelHopTypeV2 created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgHopTypeV2 (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(100),
	@Aka nvarchar(100) = Null,
	@AlphaAcidLow numeric(5,2) = 0.00,
	@AlphaAcidHigh numeric(5,2) = 0.00,
	@BetaAcidLow numeric(5,2) = 0.00,
	@BetaAcidHigh numeric(5,2) = 0.00,
	--@IBU numeric(5,2) = Null,
	--@Cost money = Null,
	--@CostUomID int = Null,
	@MfrID int,
	@Notes nvarchar(2000) = Null,
	@IsPellet bit = 1,
	@IsFlower bit = 0,
	@IsHomeGrwn bit = 0,
	@IsOil bit = 0,
	@IsExtract bit = 0,
	@PSub1ID int = null,
	@PSub2ID int = null,
	@PSub3ID int = null,
	@PSub4ID int = null,
	@PSub5ID int = null,
	@Lang varchar(20) = 'en_us',
	@fk_CountryID int = 0,
	@fk_HopPurposeID int = 0,
	@BCastMode bit = 1
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table (
		[Name] nvarchar(100), 
		mfrid int,
		sub1hopid int,
		sub2hopid int,
		sub3hopid int,
		sub4hopid int,
		sub5hopid int
	);
	Declare @old nvarchar(100);
	Declare @oldSub1HopNm nvarchar(100);
	Declare @oldSub2HopNm nvarchar(100);
	Declare @oldSub3HopNm nvarchar(100);
	Declare @oldSub4HopNm nvarchar(100);
	Declare @oldSub5HopNm nvarchar(100);
	Declare @oldMfrNm nvarchar(300);
	Declare @OldSub1MfrNm nvarchar(300);
	Declare @OldSub2MfrNm nvarchar(300);
	Declare @OldSub3MfrNm nvarchar(300);
	Declare @OldSub4MfrNm nvarchar(300);
	Declare @OldSub5MfrNm nvarchar(300);
	Declare @EvntNm nvarchar(100) = N'Hop';
	
	Set @rc = 0;
	
	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If ((@RowID Is Not Null) And (Not Exists (Select * from [bhp].HopTypesV2 Where RowID = @RowID And RowID > 0)))
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66014; -- this nbr represents an uknown hop type id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	--If ((@CostUOMID Is Not Null) And (Not Exists (Select * from [bhp].vw_MonetaryUOM Where RowID = @CostUomID)))
	--Begin
	--	-- should write and audit record here...someone trying use a non-monetary uom value
	--	Set @rc = 66010; -- this nbr represents a non-monetary uom error.
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1);
	--	Return @rc;
	--End

	If ((@MfrID Is Not Null) And (Not Exists (Select * from [bhp].vw_HopManufs Where RowID = @MfrID)))
	Begin
		-- should write and audit record here...someone trying to change to an unknown hop manuf id
		Set @rc = 66013; -- this nbr represents a non-existant manuf id.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	Update Top (1) [bhp].HopTypesV2
		Set
			Name=@Name,
			AKA=di.fn_IsNull(@Aka),
			AlphaAcidLow=ISNULL(@AlphaAcidLow,0.00),
			AlphaAcidHigh=ISNULL(@AlphaAcidHigh,0.00),
			BetaAcidLow=ISNULL(@BetaAcidLow,0.00),
			BetaAcidHigh=ISNULL(@BetaAcidHigh,0.00),
			--IBU=ISNULL(@IBU, (Select top (1) IBU from [bhp].HopTypesV2 Where RowID=@RowID)),
			--OpCost=ISNULL(@Cost, (Select top (1) OpCost from [bhp].HopTypesV2 Where RowID=@RowID)),
			--fk_OpCostUOM=ISNULL(@CostUomID, (Select top (1) fk_OpCostUOM from [bhp].HopTypesV2 Where RowID=@RowID)),
			fk_HopMfrID=@MfrID,
			Commentary=ISNULL(Case When @Notes = 'pls enter a comment...' Then Null Else RTRIM(LTRIM(@Notes)) End, 'no comment given...'),
			Pellet=ISNULL(@IsPellet,0),
			Flower=ISNULL(@IsFlower, 0),
			HomeGrwn=ISNULL(@IsHomeGrwn, 0),
			IsOil=ISNULL(@IsOil, 0),
			IsExtract=ISNULL(@IsExtract, 0),
			PSub1=ISNULL(@PSub1ID, 0),
			PSub2=ISNULL(@PSub2ID, 0),
			PSub3=ISNULL(@PSub3ID, 0),
			PSub4=ISNULL(@PSub4ID, 0),
			PSub5=ISNULL(@PSub5ID, 0),
			Lang=ISNULL(@Lang, N'en_us'),
			fk_CountryID = ISNULL(@fk_CountryID, 0),
			fk_HopPurposeID = ISNULL(@fk_HopPurposeID, 0)
	Output 
		Deleted.[Name], 
		Deleted.fk_HopMfrID,
		ISNULL(Deleted.PSub1,0), 
		ISNULL(Deleted.PSub2,0),
		ISNULL(Deleted.PSub3,0),
		ISNULL(Deleted.PSub4,0),
		ISNULL(Deleted.PSub5,0)
	Into @oldinfo([Name],mfrid,sub1hopid,sub2hopid,sub3hopid,sub4hopid,sub5hopid)
	Where (RowID=@RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Select 
			@old = I.[Name], @oldMfrNm=M.[Name],
			@OldSub1MfrNm=case M1.RowID when 0 then SPACE(0) Else M1.[Name] End,
			@OldSub2MfrNm=case M2.RowID when 0 then SPACE(0) Else M2.[Name] End,
			@OldSub3MfrNm=case M3.RowID when 0 then SPACE(0) Else M3.[Name] End,
			@OldSub4MfrNm=case M4.RowID when 0 then SPACE(0) Else M4.[Name] End,
			@OldSub5MfrNm=case M5.RowID when 0 then SPACE(0) Else M5.[Name] End,
			@oldSub1HopNm=case I.sub1hopid When 0 Then SPACE(0) Else H1.[Name] End,
			@oldSub2HopNm=case I.sub2hopid When 0 Then SPACE(0) Else H2.[Name] End,
			@oldSub3HopNm=case I.sub3hopid When 0 Then SPACE(0) Else H3.[Name] End,
			@oldSub4HopNm=case I.sub4hopid When 0 Then SPACE(0) Else H4.[Name] End,
			@oldSub5HopNm=case I.sub5hopid When 0 Then SPACE(0) Else H5.[Name] End
		from @oldinfo I
		Inner Join [bhp].HopManufacturers M On (I.mfrid = M.RowID)
		Inner Join [bhp].HopTypesV2 H1 On (I.sub1hopid = H1.RowID)
		Inner Join [bhp].HopTypesV2 H2 On (I.sub2hopid = H2.RowID)
		Inner Join [bhp].HopTypesV2 H3 On (I.sub3hopid = H3.RowID)
		Inner Join [bhp].HopTypesV2 H4 On (I.sub4hopid = H4.RowID)
		Inner Join [bhp].HopTypesV2 H5 On (I.sub5hopid = H5.RowID)
		Inner Join [bhp].HopManufacturers M1 On (H1.fk_HopMfrID = M1.RowID)
		Inner Join [bhp].HopManufacturers M2 On (H2.fk_HopMfrID = M2.RowID)
		Inner Join [bhp].HopManufacturers M3 On (H3.fk_HopMfrID = M3.RowID)
		Inner Join [bhp].HopManufacturers M4 On (H4.fk_HopMfrID = M4.RowID)
		Inner Join [bhp].HopManufacturers M5 On (H5.fk_HopMfrID = M5.RowID);

		Exec @rc = [bhp].GenBurpHopMstrMesg @id = @RowID, @evnttype='chg', @SessID = @SessID, @mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@old")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldmfrnm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:MfrInfo)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldSub1HopNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute1/b:Mstr_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@OldSub1MfrNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute1/b:Mstr_Info/b:MfrInfo)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldSub2HopNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute2/b:Mstr_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@OldSub2MfrNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute2/b:Mstr_Info/b:MfrInfo)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldSub3HopNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute3/b:Mstr_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@OldSub3MfrNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute3/b:Mstr_Info/b:MfrInfo)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldSub4HopNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute4/b:Mstr_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@OldSub4MfrNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute4/b:Mstr_Info/b:MfrInfo)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@oldSub5HopNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute5/b:Mstr_Info/b:Name)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				attribute old {sql:variable("@OldSub5MfrNm")}
			)
			into (/b:Burp_Belch/b:Payload/b:HopInfo_Evnt/b:Mstr_Info/b:Substitute5/b:Mstr_Info/b:MfrInfo)[1]
		');

		Exec [bhp].[PostToBWPRouter] @inmsg = @xml, @msgNm=@EvntNm;
	end
	
	Return @rc;
End
go

Print 'Proc:: [bhp].ChgHopTypeV2 created...';
go


checkpoint
go