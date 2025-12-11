USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_YeastManufs]    Script Date: 2/28/2020 11:33:38 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_YeastManufs]'))
DROP VIEW [bhp].[vw_YeastManufs]
GO

/****** Object:  View [bhp].[vw_YeastManufs]    Script Date: 2/28/2020 11:33:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [bhp].[vw_YeastManufs] (RowID, Name, Phylum, W3C, Lang, fk_Country, CountryName)
with schemabinding
as
Select Top 100 Percent
	Y.[RowID]
	,Y.[Name]
	,Y.[Phylum]
	,Y.[W3C]
	,Y.[Lang]
	,Y.fk_Country
	,C.Name
From [bhp].YeastManufacturers Y
Inner Join [di].Countries C On (Y.fk_Country = C.RowID)
Order By Y.Name;
   
GO


