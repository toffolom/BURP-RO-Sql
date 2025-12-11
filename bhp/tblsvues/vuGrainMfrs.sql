USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_GrainManufs]    Script Date: 2/26/2020 12:26:17 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_GrainManufs]'))
DROP VIEW [bhp].[vw_GrainManufs]
GO

/****** Object:  View [bhp].[vw_GrainManufs]    Script Date: 2/26/2020 12:26:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [bhp].[vw_GrainManufs] (
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
		,ISNULL(G.[fk_VolDiscUOM],([bhp].[fn_GetUOMIdByNm]('lb')))
		,G.[VolDiscSz]
		,ISNULL(G.[MinOrderQty],-99)
		,ISNULL(G.[W3C],'http://')
		,G.[EnteredOn]
		,G.[EnteredBy]
		,ISNULL(G.[Lang],'en_us')
		,G.fk_Country
		,C.Name as CountryName
	FROM [bhp].[GrainManufacturers] G
	Inner Join [di].Countries C On (G.fk_Country = C.RowID);

GO


