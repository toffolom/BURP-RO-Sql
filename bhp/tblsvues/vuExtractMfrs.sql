USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_ExtractManufs]    Script Date: 3/9/2020 4:05:09 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_ExtractManufs]'))
DROP VIEW [bhp].[vw_ExtractManufs]
GO

/****** Object:  View [bhp].[vw_ExtractManufs]    Script Date: 3/9/2020 4:05:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE view [bhp].[vw_ExtractManufs] (
	[RowID]
	,[Name]
	,[fk_VolDiscUOM]
	,[VolDiscSz]
	,[MinOrderQty]
	,[W3C]
	,[EnteredOn]
	,[EnteredBy]
	,[Lang]
	,[fk_Country]
	,[CountryName]
)
--with schemabinding
as
	Select 
		G.[RowID]
		,RTRIM(LTRIM(G.[Name]))
		,ISNULL(G.[fk_VolDiscUOM],[bhp].[fn_GetUOMIdByNm]('lb'))
		,G.[VolDiscSz]
		,ISNULL(G.[MinOrderQty],-99)
		,ISNULL(G.[W3C],'http://')
		,G.[EnteredOn]
		,G.[EnteredBy]
		,ISNULL(G.[Lang],'en_us')
		,G.fk_Country
		,C.Name as CountryName
	FROM [bhp].[ExtractManufacturers] G
	Inner Join [di].Countries C On (G.fk_Country = C.RowID);





