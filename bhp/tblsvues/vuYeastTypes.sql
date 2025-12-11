USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_YeastTypes]    Script Date: 2/28/2020 11:32:10 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_YeastTypes]'))
DROP VIEW [bhp].[vw_YeastTypes]
GO

/****** Object:  View [bhp].[vw_YeastTypes]    Script Date: 2/28/2020 11:32:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create view [bhp].[vw_YeastTypes] (RowID, Name, Phylum, Lang)
--with encryption
as
Select Top 100 Percent
	[RowID]
	,[Name]
	,[Phylum]
	,[Lang]
From [bhp].YeastTypes
Order By Name;
   
GO


