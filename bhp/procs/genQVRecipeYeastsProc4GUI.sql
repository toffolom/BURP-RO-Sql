USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[genQVRecipeYeasts]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[genQVRecipeYeasts]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].genQVRecipeYeasts;
Print 'Proc:: [bhp].genQVRecipeYeasts dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].genQVRecipeYeasts (
	@SessID varchar(256),
	@rid int -- recipe id value
)
with encryption
as
begin
	--set nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @SessStatus bit;
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @AutoClose=1, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		Raiserror(@Mesg,0,1);
		Return @rc;
	End
	
	SELECT 
		Y.[RowID]
		,Y.[Name]
		,ISNULL(Y.[fk_YeastMfr],0) As fk_YeastMfr
		--,[MfrNm]
		,ISNULL(Y.[fk_YeastType],0) As fk_YeastType
		--,[YeastTypName]
		,ISNULL(Y.[fk_YeastPkgTyp],0) As fk_YeastPkgTyp
		--,[PkgDescr]
		,ISNULL(Y.[Attenuation],'not set') As Attenuation
		,ISNULL(Y.[FermTempBeg],0) As FermTempBeg
		,ISNULL(Y.[FermTempEnd],0) As FermTempEnd
		,ISNULL(Y.[fk_FermTempUOM],(Select Top (1) RowID from [bhp].[vw_TemperatureUOM] Where LEFT(UOM,1) = 'F')) As fk_FermTempUOM
		--,[FermTempUOM]
		,ISNULL(Y.[KnownAs1], 'not set') As KnownAs1
		,ISNULL(Y.[KnownAs2], 'not set') As KnownAs2
		,ISNULL(Y.[KnownAs3], 'not set') As KnownAs3
		,ISNULL(Y.[NbrOfRecipesUsedIn],0) As NbrOfRecipesUsedIn
		,ISNULL(Y.[PSub1],0) As PSub1
		--,[PSubNm1]
		,ISNULL(Y.[PSub2],0) As PSub2
		--,[PSubNm2]
		,ISNULL(Y.[Notes],'no comment given...') As Notes
		,Y.[EnteredOn]
		,Y.[EnteredBy]
		,ISNULL(Y.[Lang], N'en_us') As Lang
		,ISNULL(fk_CountryID,0) As fk_CountryID
		,ISNULL(fk_FlocculationType,0) As fk_FlocculationType
	FROM [bhp].YeastMstr Y
	Inner Join [bhp].RecipeYeasts RY On (Y.RowID = RY.fk_YeastMstrID)
	--Inner Join [bhp].YeastManufacturers YM On (YM.RowID = Y.fk_YeastMfr)
	Where (RY.fk_RecipeJrnlMstrID = @rid)
	ORDER BY Name;
	
	Return @@Error;
end
go

print 'Proc:: [bhp].genQVRecipeYeasts created...';
go


revoke execute on [bhp].genQVRecipeYeasts to [Public];
go


checkpoint
