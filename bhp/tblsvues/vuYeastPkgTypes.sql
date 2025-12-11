USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_YeastPkgInfo]    Script Date: 2/28/2020 11:32:53 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_YeastPkgInfo]'))
DROP VIEW [bhp].[vw_YeastPkgInfo]
GO

/****** Object:  View [bhp].[vw_YeastPkgInfo]    Script Date: 2/28/2020 11:32:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create view [bhp].[vw_YeastPkgInfo] (RowID, Name, Lang, Notes)
--with encryption
as
Select Top 100 Percent
	[RowID]
	,[Name]
	,[Lang]
	,ISNULL(Notes,'not set') As Notes
From [bhp].YeastPackagingTypes
Order By Name;
   
GO


