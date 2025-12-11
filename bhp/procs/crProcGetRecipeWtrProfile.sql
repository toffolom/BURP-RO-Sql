USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetRecipeWaterProfile]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetRecipeWaterProfile]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetRecipeWaterProfile];
Print 'Proc:: [bhp].GetRecipeWaterProfile dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddRecipeWaterProfile]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddRecipeWaterProfile]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddRecipeWaterProfile];
Print 'Proc:: [bhp].AddRecipeWaterProfile dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgRecipeWaterProfile]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgRecipeWaterProfile]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgRecipeWaterProfile];
Print 'Proc:: [bhp].ChgRecipeWaterProfile dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgRecipeWaterProfile]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelRecipeWaterProfile]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelRecipeWaterProfile];
Print 'Proc:: [bhp].DelRecipeWaterProfile dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeWaterProfile (
	@SessID varchar(256),
	@RecipeID int
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
		[RowID]
		,[fk_RecipeJrnlMstrID]
		,ISNULL([Calcium],0) As Calcium
		,ISNULL([fk_CalciumUOM], [bhp].fn_GetUOMIdByNm('ppm')) As [fk_CalciumUOM]
		,ISNULL([Magnesium],0) As Magnesium
		,ISNULL([fk_MagnesiumUOM], [bhp].fn_GetUOMIdByNm('ppm')) As [fk_MagnesiumUOM]
		,ISNULL([Sodium],0) As Sodium
		,ISNULL([fk_SodiumUOM], [bhp].fn_GetUOMIdByNm('ppm')) As [fk_SodiumUOM]
		,ISNULL([Sulfate],0) As Sulfate
		,ISNULL([fk_SulfateUOM], [bhp].fn_GetUOMIdByNm('ppm')) As [fk_SulfateUOM]
		,ISNULL([Chloride],0) As Chloride
		,ISNULL([fk_ChlorideUOM], [bhp].fn_GetUOMIdByNm('ppm')) As [fk_ChlorideUOM]
		,ISNULL([Bicarbonate],0) As Bicarbonate
		,ISNULL([fk_BicarbonateUOM], [bhp].fn_GetUOMIdByNm('ppm')) As [fk_BicarbonateUOM]
		,ISNULL([Ph],0) As [Ph]
		,ISNULL([fk_PhUOM], [bhp].fn_GetUOMIdByNm('ph')) As [fk_PhUOM]
		,ISNULL([fk_InitilizedByFamousWtrID],0) As [fk_InitilizedByFamousWtrID]
		,ISNULL([Comments],'no comments given..') As Comments
	FROM [bhp].[RecipeWaterProfile] P
	Where (P.fk_RecipeJrnlMstrID = @RecipeID); -- And ISNULL(P.Hide,0) = 1);
	
	Return 0;
end
go

print 'Proc:: [bhp].GetRecipeWaterProfile created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
**
** NOTE: the foreign key to the famous water profile is ment to used as a inheritance mechanism.  The
**		gui will populate the wtr elements from the profile...then its passed in here and used as a 
**		reference point back to where it was derived from.
** Ideally i'd have made all the wtr elements nullable and made the famous profile manditory. then upon addition
** i'd have inserted the recipe wtr profile from the famous first, then updated any non-null wtr elements.
*/
Create Proc [bhp].AddRecipeWaterProfile (
	@SessID varchar(256),
	@RecipeID int,
	@Calcium numeric(4,1),
	@fk_CalciumUOM int,
	@Magnesium numeric(4,1),
	@fk_MagnesiumUOM int,
	@Sodium numeric(4,1),
	@fk_SodiumUOM int,
	@Sulfate numeric(4,1),
	@fk_SulfateUOM int,
	@Chloride numeric(4,1),
	@fk_ChlorideUOM int,
	@Bicarbonate numeric(4,1),
	@fk_BicarbonateUOM int,
	@Ph numeric(3,1),
	@fk_PhUOM int,
	@fk_FamousWtrProfileID int = 0,
	@Comments nvarchar(2000) = N'no comments given...',
	@NuRowID int output, -- generated rowid value
	@BCastMode bit = 1
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @evntNm nvarchar(100) = 'WtrProfile';
	
	Set @rc = 0;

	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where RowID = @RecipeID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66007; -- unkwn recipe id value...wtf!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_CalciumUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_MagnesiumUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_SodiumUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_SulfateUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_ChlorideUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_BicarbonateUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_PhUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--TODO: post mesg into Que regarding a new posting for the given category...so subscribers can recv
	-- notification(s) of a posting in a category their interested in...
	Insert into [bhp].RecipeWaterProfile (
		fk_RecipeJrnlMstrID,
		Calcium, 
		fk_CalciumUOM,
		Magnesium, 
		fk_MagnesiumUOM,
		Sodium, 
		fk_SodiumUOM,
		Sulfate, 
		fk_SulfateUOM,
		Chloride, 
		fk_ChlorideUOM,
		Bicarbonate, 
		fk_BicarbonateUOM,
		Ph, 
		fk_PhUOM,
		fk_InitilizedByFamousWtrID,
		Comments
	)
	Values 
	(
		@RecipeID,
		@Calcium, 
		ISNULL(case when @fk_CalciumUOM = 0 then null else @fk_CalciumUOM end, [bhp].fn_GetUOMIdByNm('ppm')),
		ISNULL(@Magnesium, 0),
		ISNULL(case when @fk_MagnesiumUOM = 0 then null else @fk_MagnesiumUOM end, [bhp].fn_GetUOMIdByNm('ppm')),
		ISNULL(@Sodium, 0),
		ISNULL(case when @fk_SodiumUOM = 0 then null else @fk_SodiumUOM end, [bhp].fn_GetUOMIdByNm('ppm')),
		ISNULL(@Sulfate, 0),
		ISNULL(case when @fk_SulfateUOM = 0 then null else @fk_SulfateUOM end, [bhp].fn_GetUOMIdByNm('ppm')),
		ISNULL(@Chloride, 0),
		ISNULL(case when @fk_ChlorideUOM = 0 then null else @fk_ChlorideUOM end , [bhp].fn_GetUOMIdByNm('ppm')),
		ISNULL(@Bicarbonate, 0),
		ISNULL(case when @fk_BicarbonateUOM = 0 then null else @fk_BicarbonateUOM end , [bhp].fn_GetUOMIdByNm('ppm')),
		ISNULL(@Ph, 0),
		ISNULL(case when @fk_PhUOM = 0 then null else @fk_PhUOM end, [bhp].fn_GetUOMIdByNm('ph')),
		ISNULL(@fk_FamousWtrProfileID, 0),
		ISNULL(@Comments, 'no comments given...')
	);
	
	Set @NuRowID = Scope_Identity();

	if (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec [bhp].GenRecipeWaterProfileMesg @rid=@RecipeID, @evnttype='add', @SessID=@SessID, @mesg=@xml output;
		exec [bhp].PostToBWPRouter @inMsg=@xml, @msgNm=@evntNm;
	end

	Return @@Error;
End
go

Print 'Proc:: [bhp].AddRecipeWaterProfile created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelRecipeWaterProfile (
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
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	--if (@BCastMode = 1)
	--begin
	--	Declare @rid int;
	--	Select @rid = fk_RecipeJrnlMstrID from [bhp].RecipeWaterProfile Where (RowID=@RowID);
	--	exec [bhp].GenRecipeWaterProfileMesg @rid=@rid, @evnttype='del', @SessID=@SessID, @mesg=@xml output;
	--end

	Delete Top (1) [bhp].RecipeWaterProfile Where (RowID = @RowID);

	--if (@BCastMode = 1)
	--begin
	--	exec [bhp].SendBurpRecipeMesg @Msg=@xml;
	--end
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelRecipeWaterProfile created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgRecipeWaterProfile (
	@SessID varchar(256),
	@RowID int,
	@Calcium numeric(4,1),
	@fk_CalciumUOM int,
	@Magnesium numeric(4,1),
	@fk_MagnesiumUOM int,
	@Sodium numeric(4,1),
	@fk_SodiumUOM int,
	@Sulfate numeric(4,1),
	@fk_SulfateUOM int,
	@Chloride numeric(4,1),
	@fk_ChlorideUOM int,
	@Bicarbonate numeric(4,1),
	@fk_BicarbonateUOM int,
	@Ph numeric(3,1),
	@fk_PhUOM int,
	@fk_FamousWtrProfileID int = 0,
	@Comments nvarchar(2000) = N'no comments given...',
	@BCastMode bit = 1
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @RecipeID int;
	Declare @xml xml;
	Declare @oldinfo Table (
		calcium numeric(4,1),
		calciumUOM int,
		magnesium numeric(4,1),
		magnesiumUOM int,
		sodium numeric(4,1),
		sodiumUOM int,
		sulfate numeric(4,1),
		sulfateUOM int,
		chloride numeric(4,1),
		chlorideUOM int,
		bicarb numeric(4,1),
		bicarbUOM int,
		ph numeric(3,1),
		phUOM int,
		famousID int
	);
	Declare @oldcalc numeric(4,1);
	Declare @oldcalcUOM varchar(50);
	Declare @oldmag numeric(4,1);
	Declare @oldmagUOM varchar(50);
	Declare @oldsod numeric(4,1);
	Declare @oldsodUOM varchar(50);
	Declare @oldsulf numeric(4,1);
	Declare @oldsulfUOM varchar(50);
	Declare @oldchlor numeric(4,1);
	Declare @oldchlorUOM varchar(50);
	Declare @oldbicarb numeric(4,1);
	Declare @oldbicarbUOM varchar(50);
	Declare @oldPh numeric(3,1);
	Declare @oldPhUOM varchar(50);
	Declare @oldFamNm varchar(200);
	Declare @evntNm nvarchar(100) = 'WtrProfile';
	
	Set @rc = 0;
	
	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_CalciumUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_MagnesiumUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_SodiumUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_SulfateUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_ChlorideUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_BicarbonateUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].UOMTypes Where RowID = @fk_PhUOM and (AllowedAsVolumnMeasure=1 or AllowedAsWeightMeasure=1))
	Begin
		-- should write and audit record here...
		Set @rc = 66055; -- uom key not setup to measure (volume)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @RecipeID = fk_RecipeJrnlMstrID from [bhp].RecipeWaterProfile Where (RowID=@RowID);

	Update [bhp].RecipeWaterProfile
		Set
			Calcium = Coalesce(@Calcium, 0),
			fk_CalciumUOM = Coalesce(@fk_CalciumUOM, [bhp].fn_GetUOMIdByNm('ppm')),
			Magnesium = Coalesce(@Magnesium, 0),
			fk_MagnesiumUOM = Coalesce(@fk_MagnesiumUOM, [bhp].fn_GetUOMIdByNm('ppm')),
			Sodium = Coalesce(@Sodium, 0),
			fk_SodiumUOM = Coalesce(@fk_SodiumUOM, [bhp].fn_GetUOMIdByNm('ppm')),
			Sulfate = Coalesce(@Sulfate, 0),
			fk_SulfateUOM = Coalesce(@fk_SulfateUOM, [bhp].fn_GetUOMIdByNm('ppm')),
			Chloride = Coalesce(@Chloride, 0),
			fk_ChlorideUOM = Coalesce(@fk_ChlorideUOM, [bhp].fn_GetUOMIdByNm('ppm')),
			Bicarbonate = Coalesce(@Bicarbonate, 0),
			fk_BicarbonateUOM = Coalesce(@fk_BicarbonateUOM, [bhp].fn_GetUOMIdByNm('ppm')),
			Ph = Coalesce(@Ph, 0),
			fk_PhUOM = Coalesce(@fk_PhUOM, [bhp].fn_GetUOMIdByNm('ph')),
			Comments = Coalesce(@Comments, 'no comments given...'),
			fk_InitilizedByFamousWtrID = Coalesce(@fk_FamousWtrProfileID, 0)
	Output -- preserve our 'old' values for outbound xml below...
		Deleted.Calcium, Deleted.fk_CalciumUOM,
		Deleted.Magnesium, Deleted.fk_MagnesiumUOM,
		Deleted.Sodium, Deleted.fk_SodiumUOM,
		Deleted.Sulfate, Deleted.fk_SulfateUOM,
		Deleted.Chloride, Deleted.fk_ChlorideUOM,
		Deleted.Bicarbonate, Deleted.fk_BicarbonateUOM,
		Deleted.Ph, Deleted.fk_PhUOM,
		Deleted.fk_InitilizedByFamousWtrID
	Into @oldinfo (
		calcium, calciumUOM,
		magnesium, magnesiumUOM,
		sodium, sodiumUOM,
		sulfate, sulfateUOM,
		chloride, chlorideUOM,
		bicarb, bicarbUOM,
		ph, phUOM,
		famousID
	)
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec [bhp].GenRecipeWaterProfileMesg @rid=@RecipeID, @evnttype='chg', @SessID=@SessID, @mesg=@xml output;

		-- pull out from table the vals we need to stuff into outbound xml below...
		select 
			@oldcalc=I.calcium, @oldcalcUOM=U1.[UOM],
			@oldmag=I.magnesium, @oldmagUOM=U2.[UOM],
			@oldsod=I.sodium, @oldsodUOM=U3.[UOM],
			@oldsulf=I.sulfate, @oldsulfUOM=U4.[UOM],
			@oldchlor=I.chloride, @oldchlorUOM=U5.[UOM],
			@oldbicarb=I.bicarb, @oldbicarbUOM=U6.[UOM],
			@oldPh=I.ph, @oldPhUOM=U7.[UOM],
			@oldFamNm=F.[Name]
		from @oldinfo I
		inner join [bhp].UOMTypes U1 On (I.calciumUOM = U1.RowID)
		inner join [bhp].UOMTypes U2 On (I.magnesiumUOM = U2.RowID)
		inner join [bhp].UOMTypes U3 On (I.sodiumUOM = U3.RowID)
		inner join [bhp].UOMTypes U4 On (I.sulfateUOM = U4.RowID)
		inner join [bhp].UOMTypes U5 On (I.chlorideUOM = U5.RowID)
		inner join [bhp].UOMTypes U6 On (I.bicarbUOM = U6.RowID)
		inner join [bhp].UOMTypes U7 On (I.phUOM = U7.RowID)
		inner join [bhp].FamousWaterProfiles F On (I.famousID = F.RowID);
		
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldcalcUOM")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Calcium/b:UOM)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldcalc")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Calcium/b:Amt)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldmagUOM")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Magnesium/b:UOM)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldmag")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Magnesium/b:Amt)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldsodUOM")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Sodium/b:UOM)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldsod")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Sodium/b:Amt)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldsulfUOM")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Sulfate/b:UOM)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldsulf")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Sulfate/b:Amt)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldchlorUOM")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Chloride/b:UOM)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldchlor")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Chloride/b:Amt)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldBicarbUOM")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Bicarbonate/b:UOM)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldbicarb")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Bicarbonate/b:Amt)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldPhUOM")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Ph/b:UOM)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldPh")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Ph/b:Amt)[1]
		');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@oldFamNm")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info/b:Initialized_From/b:Name)[1]
		');

		exec [bhp].PostToBWPRouter @inMsg=@xml, @msgNm=@evntNm;
	end

	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgRecipeWaterProfile created...';
go

checkpoint
go