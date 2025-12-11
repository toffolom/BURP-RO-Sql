USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_SpargeTypes]    Script Date: 3/4/2020 1:47:36 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_SpargeTypes]'))
DROP VIEW [bhp].[vw_SpargeTypes]
GO

/****** Object:  View [bhp].[vw_SpargeTypes]    Script Date: 3/4/2020 1:47:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [bhp].[vw_SpargeTypes] (RowID, Name, AKA, Comments)
with schemabinding
as
	Select Top 100 Percent [RowID]
		,[Name]
		,[AKA]
		,[Comment]
	FROM [bhp].[SpargeTypes]
	Order By RowID;
GO


