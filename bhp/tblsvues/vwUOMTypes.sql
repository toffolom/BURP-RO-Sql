USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_UOMTypes]    Script Date: 3/9/2020 4:00:33 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_UOMTypes]'))
DROP VIEW [bhp].[vw_UOMTypes]
GO

/****** Object:  View [bhp].[vw_UOMTypes]    Script Date: 3/9/2020 4:00:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE view [bhp].[vw_UOMTypes] (
	RowID, Name, UOM, Lang, IsTime, IsVolumn, IsTemperature, 
	IsContainer, IsColor, IsBitterness, IsWeight, IsMonetary, 
	Comment, 
	MinVal, 
	MaxVal
)
with schemabinding
as
	Select
		RowID, 
		[Name],
		ISNULL(UOM,[Name]),
		isnull(Lang, 'en_us'),
		isnull(AllowedAsTimeMeasure,0), 
		isnull(AllowedAsVolumnMeasure,0), 
		isnull(AllowedAsTemperature,0),
		isnull(AllowedAsContainer,0), 
		isnull(AllowedAsColorMeasure,0), 
		isnull(AllowedAsBitterMeasure,0), 
		isnull(AllowedAsWeightMeasure,0),
		ISNULL(AllowedAsMonetary,0),
		ISNULL([Comment],'no comment...'),
		ISNULL(MinVal,'n/a'),
		ISNULL(MaxVal,'n/a')
	From [bhp].UOMTypes;
	--Where (RowID > 0);

GO


