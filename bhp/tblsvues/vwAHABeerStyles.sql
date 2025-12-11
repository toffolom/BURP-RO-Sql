USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_AHABeerStyles]    Script Date: 3/16/2020 12:03:39 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_AHABeerStyles]'))
DROP VIEW [bhp].[vw_AHABeerStyles]
GO

/****** Object:  View [bhp].[vw_AHABeerStyles]    Script Date: 3/16/2020 12:03:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [bhp].[vw_AHABeerStyles] (
	RowID, Category, [Name], [Description], Lang
)
as
Select 0, 'pls select...', 'pls select...', 'this is for drop down selection...', 'en_us'
union
SELECT 
	[RowID],
	[CategoryName],
	[Name],
	case when [di].fn_IsNull([Descr]) is null Then 'n/a' Else Descr End,
	ISNULL(Lang,'en_us')
FROM [bhp].AHABeerStyle
Where (RowID > 0);

GO


