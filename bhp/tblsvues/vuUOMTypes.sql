USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_WeightUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_WeightUOM]'))
DROP VIEW [bhp].[vw_WeightUOM]
GO

/****** Object:  View [bhp].[vw_VolumnUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_VolumnUOM]'))
DROP VIEW [bhp].[vw_VolumnUOM]
GO

/****** Object:  View [bhp].[vw_TimeUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_TimeUOM]'))
DROP VIEW [bhp].[vw_TimeUOM]
GO

/****** Object:  View [bhp].[vw_TemperatureUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_TemperatureUOM]'))
DROP VIEW [bhp].[vw_TemperatureUOM]
GO

/****** Object:  View [bhp].[vw_MonetaryUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_MonetaryUOM]'))
DROP VIEW [bhp].[vw_MonetaryUOM]
GO

/****** Object:  View [bhp].[vw_ContainerUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_ContainerUOM]'))
DROP VIEW [bhp].[vw_ContainerUOM]
GO

/****** Object:  View [bhp].[vw_ColorUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_ColorUOM]'))
DROP VIEW [bhp].[vw_ColorUOM]
GO

/****** Object:  View [bhp].[vw_BitternessUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_BitternessUOM]'))
DROP VIEW [bhp].[vw_BitternessUOM]
GO

/****** Object:  View [bhp].[vw_BitternessUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [bhp].[vw_BitternessUOM]
as
SELECT
	[RowID]
	,[UOM]
	,[Name]
	,[Lang]
	,[EnteredOn]
	,[AllowedAsTimeMeasure]
	,[AllowedAsVolumnMeasure]
	,[AllowedAsTemperature]
	,[AllowedAsContainer]
	,[AllowedAsColorMeasure]
	,[AllowedAsBitterMeasure]
	,[AllowedAsWeightMeasure]
	,[AllowedAsMonetary]
  FROM [bhp].[UOMTypes] where (AllowedAsBitterMeasure = 1);


GO

/****** Object:  View [bhp].[vw_ColorUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [bhp].[vw_ColorUOM]
as
SELECT
	[RowID]
	,[UOM]
	,[Name]
	,[Lang]
	,[EnteredOn]
	,[AllowedAsTimeMeasure]
	,[AllowedAsVolumnMeasure]
	,[AllowedAsTemperature]
	,[AllowedAsContainer]
	,[AllowedAsColorMeasure]
	,[AllowedAsBitterMeasure]
	,[AllowedAsWeightMeasure]
	,[AllowedAsMonetary]
  FROM [bhp].[UOMTypes] where AllowedAsColorMeasure = 1;


GO

/****** Object:  View [bhp].[vw_ContainerUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [bhp].[vw_ContainerUOM]
as
SELECT
	[RowID]
	,[UOM]
	,[Name]
	,[Lang]
	,[EnteredOn]
	,[AllowedAsTimeMeasure]
	,[AllowedAsVolumnMeasure]
	,[AllowedAsTemperature]
	,[AllowedAsContainer]
	,[AllowedAsColorMeasure]
	,[AllowedAsBitterMeasure]
	,[AllowedAsWeightMeasure]
	,[AllowedAsMonetary]
  FROM [bhp].[UOMTypes] where AllowedAsContainer = 1;


GO

/****** Object:  View [bhp].[vw_MonetaryUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
create view [bhp].[vw_MonetaryUOM]
as
SELECT [RowID]
      ,[UOM]
      ,[Name]
      ,[Lang]
      ,[EnteredOn]
      ,[AllowedAsTimeMeasure]
      ,[AllowedAsVolumnMeasure]
      ,[AllowedAsTemperature]
      ,[AllowedAsContainer]
      ,[AllowedAsColorMeasure]
      ,[AllowedAsBitterMeasure]
      ,[AllowedAsWeightMeasure]
      ,[AllowedAsMonetary]
  FROM [bhp].[UOMTypes] where [AllowedAsMonetary] = 1;

GO

/****** Object:  View [bhp].[vw_TemperatureUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [bhp].[vw_TemperatureUOM]
as
SELECT 
	[RowID]
	,[UOM]
	,[Name]
	,[Lang]
	,[EnteredOn]
	,[AllowedAsTimeMeasure]
	,[AllowedAsVolumnMeasure]
	,[AllowedAsTemperature]
	,[AllowedAsContainer]
	,[AllowedAsColorMeasure]
	,[AllowedAsBitterMeasure]
	,[AllowedAsWeightMeasure]
	,[AllowedAsMonetary]
  FROM [bhp].[UOMTypes] where AllowedAsTemperature = 1;

GO

/****** Object:  View [bhp].[vw_TimeUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [bhp].[vw_TimeUOM]
as
SELECT 
	[RowID]
	,[UOM]
	,[Name]
	,[Lang]
	,[EnteredOn]
	,[AllowedAsTimeMeasure]
	,[AllowedAsVolumnMeasure]
	,[AllowedAsTemperature]
	,[AllowedAsContainer]
	,[AllowedAsColorMeasure]
	,[AllowedAsBitterMeasure]
	,[AllowedAsWeightMeasure]
	,[AllowedAsMonetary]
  FROM [bhp].[UOMTypes] where AllowedAsTimeMeasure = 1;

GO

/****** Object:  View [bhp].[vw_VolumnUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [bhp].[vw_VolumnUOM]
with schemabinding
as
SELECT 	
	[RowID]
	,[UOM]
	,[Name]
	,[Lang]
	,[EnteredOn]
	,[AllowedAsTimeMeasure]
	,[AllowedAsVolumnMeasure]
	,[AllowedAsTemperature]
	,[AllowedAsContainer]
	,[AllowedAsColorMeasure]
	,[AllowedAsBitterMeasure]
	,[AllowedAsWeightMeasure]
	,[AllowedAsMonetary]
  FROM [bhp].[UOMTypes] where AllowedAsVolumnMeasure = 1;



GO

/****** Object:  View [bhp].[vw_WeightUOM]    Script Date: 2/28/2020 2:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [bhp].[vw_WeightUOM]
as
SELECT
	[RowID]
	,[UOM]
	,[Name]
	,[Lang]
	,[EnteredOn]
	,[AllowedAsTimeMeasure]
	,[AllowedAsVolumnMeasure]
	,[AllowedAsTemperature]
	,[AllowedAsContainer]
	,[AllowedAsColorMeasure]
	,[AllowedAsBitterMeasure]
	,[AllowedAsWeightMeasure]
	,[AllowedAsMonetary]
  FROM [bhp].[UOMTypes] where AllowedAsWeightMeasure = 1;

GO


