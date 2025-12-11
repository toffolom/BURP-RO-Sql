USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_HopTypeWUOM]    Script Date: 2/27/2020 4:37:49 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_HopTypeWUOM]'))
DROP VIEW [bhp].[vw_HopTypeWUOM]
GO

/****** Object:  View [bhp].[vw_HopPurposeTypes]    Script Date: 2/27/2020 4:37:49 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_HopPurposeTypes]'))
DROP VIEW [bhp].[vw_HopPurposeTypes]
GO

/****** Object:  View [bhp].[vw_HopManufs]    Script Date: 2/27/2020 4:37:49 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_HopManufs]'))
DROP VIEW [bhp].[vw_HopManufs]
GO

/****** Object:  View [bhp].[vw_FamousWaterProfiles]    Script Date: 2/27/2020 4:37:49 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_FamousWaterProfiles]'))
DROP VIEW [bhp].[vw_FamousWaterProfiles]
GO

/****** Object:  View [bhp].[vw_FamousWaterProfiles]    Script Date: 2/27/2020 4:37:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE View [bhp].[vw_FamousWaterProfiles]
as
Select [RowID]
      ,[Name]
      ,[Country_State] As [Origin]
      ,[Calcium]
      ,[fk_CalciumUOM]
      ,[Magnesium]
      ,[fk_MagnesiumUOM]
      ,[Sodium]
      ,[fk_SodiumUOM]
      ,[Sulfate]
      ,[fk_SulfateUOM]
      ,[Chloride]
      ,[fk_ChlorideUOM]
      ,[Bicarbonate]
      ,[fk_BicarbonateUOM]
      ,[Ph]
      ,[fk_PhUOM]
      ,ISNULL([Notes],'No notes...') As [Notes]
	  ,ISNULL(isDfltForNu, 0) As IsDefault4Nu
  FROM [bhp].[FamousWaterProfiles];
GO

/****** Object:  View [bhp].[vw_HopManufs]    Script Date: 2/27/2020 4:37:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [bhp].[vw_HopManufs] (RowID, Name, W3C, VolDiscountSize, MinOrderQty, VolDiscountUOMID, VolDiscountUOMNm, fk_Country, CountryName)
with schemabinding
as

	Select H.RowID, H.Name, H.W3C, H.VolDiscSz, H.MinOrderQty, H.fk_VolDiscUOM, H.UOMDescr, H.fk_Country, C.Name
	From [bhp].HopManufacturers H
	Inner Join [di].Countries C on (ISNULL(H.fk_Country,0) = C.RowID);
	--Where (RowID > 0);


GO

/****** Object:  View [bhp].[vw_HopPurposeTypes]    Script Date: 2/27/2020 4:37:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [bhp].[vw_HopPurposeTypes]
as
	select BitVal, Descr, Notes
	from [bhp].HopPurposeTypes;
GO

/****** Object:  View [bhp].[vw_HopTypeWUOM]    Script Date: 2/27/2020 4:37:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [bhp].[vw_HopTypeWUOM] (
	RowID, Name, AKA, AlphaAcidLow, AlphaAcidHigh, BetaAcidLow, BetaAcidHigh, Pellet, Flower, RowSize, HomeGrown, Cost, Markup, 
	Retail, UOM, Lang, IBU, Commentary, isOil, isExtract, NbrOfRecipesUsedIn, MfrID, MfrNm, PSub1ID, PSub2ID, PSub3ID, PSub4ID, PSub5ID
)
 
as
select 
	H.RowID, H.Name, ISNULL(H.AKA,'not set'), H.AlphaAcidLow, H.AlphaAcidHigh, H.BetaAcidLow, H.BetaAcidHigh, H.Pellet, H.Flower, H.Rowsz, H.HomeGrwn, 
	ISNULL([H].OpCost,0.00),
	'%',
	0.00,
	--U.UOM,
	H.OpCostUOM,
	ISNULL(H.Lang, 'en_us'),
	H.IBU,
	ISNULL(H.Commentary,'n/a'),
	ISNULL(H.isOil,0),
	ISNULL(H.isExtract,0),
	ISNULL(H.NbrOfRecipesUsedIn,0),
	fk_HopMfrID, HopMfrNm,
	PSub1,PSub2,PSub3,PSub4,PSub5
FROM [bhp].[HopTypesV2] H; --Where (H.RowID > 0);
--inner join BHP1.[bhp].UOMTypes U
--on (H.fk_OpCostUOM = U.RowID And H.RowID > 0);



GO


