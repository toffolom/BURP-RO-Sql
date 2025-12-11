USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_RecipeYeastBinder]    Script Date: 3/10/2020 8:58:18 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeYeastBinder]'))
DROP VIEW [bhp].[vw_RecipeYeastBinder]
GO

/****** Object:  View [bhp].[vw_RecipeYeastBinder]    Script Date: 3/10/2020 8:58:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE View [bhp].[vw_RecipeYeastBinder] (
	RecipeID, RecipeName, YeastID, YeastName, YeastManufID, YeastManuf, YeastTypeID, YeastTypeName, YeastPkgID, YeastPkgName
)
 
as

	SELECT TOP 100 PERCENT
	RY.fk_RecipeJrnlMstrID, RM.Name, YM.RowID, YM.Name, YM.fk_YeastMfr, MFR.Name, YM.fk_YeastType, YT.Name, YM.fk_YeastPkgTyp, PKG.Name
	FROM [bhp].RecipeYeasts AS RY 
	Inner Join [bhp].YeastMstr YM On (RY.fk_YeastMstrID = YM.RowID)
	Inner Join [bhp].RecipeJrnlMstr RM On (RY.fk_RecipeJrnlMstrID = RM.RowID)
	Inner Join [bhp].YeastManufacturers MFR On (YM.fk_YeastMfr = MFR.RowID)
	Inner Join [bhp].YeastTypes YT On (YM.fk_YeastType = YT.RowID)
	Inner Join [bhp].YeastPackagingTypes PKG On (YM.fk_YeastPkgTyp = PKG.RowID)
	Where (RY.RowID > 0)
	ORDER BY RM.Name;
GO


