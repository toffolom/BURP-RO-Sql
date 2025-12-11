USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_SharingBitMaskVals]    Script Date: 3/13/2020 11:52:52 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_SharingBitMaskVals]'))
DROP VIEW [bhp].[vw_SharingBitMaskVals]
GO

/****** Object:  View [bhp].[vw_SharingBitMaskVals]    Script Date: 3/13/2020 11:52:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [bhp].[vw_SharingBitMaskVals] (
	BitVal, Descr, Notes, AllowInSchedModes
)
with schemabinding
as
Select
	[BitVal]
	,[Descr]
	,ISNULL([Notes],N'No notes given...')
	,ISNULL(AllowInSchedModes,0)
FROM [bhp].[SharingTypes];
GO


