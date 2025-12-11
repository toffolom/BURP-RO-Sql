USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_YeastMasterInfoDropDwnList]    Script Date: 3/11/2020 9:40:34 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_YeastMasterInfoDropDwnList]'))
DROP VIEW [bhp].[vw_YeastMasterInfoDropDwnList]
GO

/****** Object:  View [bhp].[vw_YeastMasterInfoDropDwnList]    Script Date: 3/11/2020 9:40:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [bhp].[vw_YeastMasterInfoDropDwnList] (
	RowID,Name,AKA1,AKA2,AKA3,fk_SubstitueID1,fk_SubstitueID2,Lang
)
with schemabinding
as
SELECT TOP 100 PERCENT [RowID]
      ,[Name]
      ,ISNULL([KnownAs1], 'n/a')
      ,ISNULL([KnownAs2], 'n/a')
      ,ISNULL([KnownAs3], 'n/a')
      ,ISNULL([PSub1],0)
      ,ISNULL([PSub2],0)
      ,ISNULL([Lang],N'en_us')
  FROM [bhp].[YeastMstr] ORDER BY [Name];
GO


