USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetHopTypesV2ByPurpose]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetHopTypesV2ByPurpose]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetHopTypesV2ByPurpose];
Print 'Proc:: [bhp].GetHopTypesV2ByPurpose dropped!!!';
END
GO


/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetHopTypesV2ByPurpose (
	@SessID varchar(256),
	@purposeID int -- purpose id value
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
		ISNULL(HT.AKA,'not set') AKA, 
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
	WHERE  (HT.RowID > 0 And HT.fk_HopPurposeID = @purposeID)
	ORDER BY HT.Name;
	
	Return 0;
end
go

print 'Proc:: [bhp].GetHopTypesV2ByPurpose created...';
go


revoke execute on [bhp].GetHopTypesV2ByPurpose to [Public];
go

--If Exists (Select * from sys.certificates where name = 'RecipeRepoCert')
--Begin
--	Begin Try
--		ADD SIGNATURE TO OBJECT::GetHopTypesV2ByPurpose
--		BY CERTIFICATE [RecipeRepoCert]
--		WITH PASSWORD = 'eye4got@@';

--		print 'signature added to proc using cert:[RecipeRepoCert]...';
--	End Try
--	Begin Catch
--		declare @e nvarchar(1028)
--		set @e = ERROR_MESSAGE();
--		raiserror('%s',0,1,@e);
--	End Catch
--End
--go

checkpoint