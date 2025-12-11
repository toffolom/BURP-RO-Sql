USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_MashSchedMstr]    Script Date: 3/4/2020 1:40:26 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_MashSchedMstr]'))
DROP VIEW [bhp].[vw_MashSchedMstr]
GO

/****** Object:  View [bhp].[vw_MashSchedMstr]    Script Date: 3/4/2020 1:40:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE View [bhp].[vw_MashSchedMstr]
with schemabinding
as
SELECT [RowID]
      ,[Name]
      ,[fk_CreatedBy]
      ,[CreatedBy]
      ,[fk_MashTypeID]
      ,[MashTypeNm]
      ,[TotRecipies]
      ,[WtrToGrainRatio]
      ,[fk_WtrToGrainRatioUOM]
      ,[WtrToGrainRatioUOM]
      ,[fk_SpargeType]
      ,[SpargeType]
      ,ISNULL([Comments],'no comment given...') As Comments
      ,ISNULL([isDfltForNu],0) As IsDfltForNu
	  ,fk_DeployInfo
	  ,ISNULL(SharingMask,0) As SharingMask
	  ,SharingMaskAsCSV
  FROM [bhp].[MashSchedMstr];
GO


