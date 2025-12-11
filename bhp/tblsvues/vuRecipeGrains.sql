USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_RecipeGrainBinder]    Script Date: 3/3/2020 12:40:57 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeGrainBinder]'))
DROP VIEW [bhp].[vw_RecipeGrainBinder]
GO

/****** Object:  View [bhp].[vw_RecipeGrainBinder]    Script Date: 3/3/2020 12:40:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE View [bhp].[vw_RecipeGrainBinder] (
	RecipeID, RecipeName, GrainID, GrainName, TotGrains, GrainMfrID, ManufName
)
 
as

	SELECT TOP 100 PERCENT
		RG.[fk_RecipeJrnlMstrID],RJ.Name, RG.[fk_GrainMstrID], RG.GrainName,
		(Select Count(*) From [bhp].RecipeGrains R Where (R.fk_RecipeJrnlMstrID = RG.fk_RecipeJrnlMstrID) Group By R.fk_RecipeJrnlMstrID),
		MFR.RowID, MFR.Name
	FROM [bhp].[RecipeGrains] RG 
	INNER JOIN [bhp].RecipeJrnlMstr RJ On (RG.fk_RecipeJrnlMstrID = RJ.RowID)
	INNER JOIN [bhp].GrainMstr GM ON (RG.fk_GrainMstrID = GM.RowID)
	INNER JOIN [bhp].GrainManufacturers MFR ON(GM.fk_GrainMfr = MFR.RowID)
	WHERE (RG.RowID > 0)
	ORDER BY RJ.Name;


GO


