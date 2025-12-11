USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_RecipeExtractBinder]    Script Date: 3/9/2020 4:02:31 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeExtractBinder]'))
DROP VIEW [bhp].[vw_RecipeExtractBinder]
GO

/****** Object:  View [bhp].[vw_RecipeExtractBinder]    Script Date: 3/9/2020 4:02:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





Create View [bhp].[vw_RecipeExtractBinder] (
	RecipeID, RecipeName, ExtractID, ExtractName, ExtractManufID, ExtractManuf
)
 
as

	SELECT TOP 100 PERCENT
		RE.fk_RecipeJrnlMstrID, RM.Name, EM.RowID, EM.Name, EM.RowID, MFR.Name
	FROM [bhp].RecipeExtracts AS RE 
	Inner Join [bhp].ExtractMstr EM On (RE.fk_ExtractMstrID = EM.RowID)
	Inner Join [bhp].RecipeJrnlMstr RM On (RE.fk_RecipeJrnlMstrID = RM.RowID)
	Inner Join [bhp].ExtractManufacturers MFR On (EM.fk_ExtractMfrID = MFR.RowID)
	Where (RE.RowID > 0)
	ORDER BY RM.Name;



GO


