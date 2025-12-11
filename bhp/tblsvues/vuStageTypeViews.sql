USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_StageTypesAllowedInYeast]    Script Date: 3/4/2020 1:46:10 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_StageTypesAllowedInYeast]'))
DROP VIEW [bhp].[vw_StageTypesAllowedInYeast]
GO

/****** Object:  View [bhp].[vw_StageTypesAllowedInMash]    Script Date: 3/4/2020 1:46:10 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_StageTypesAllowedInMash]'))
DROP VIEW [bhp].[vw_StageTypesAllowedInMash]
GO

/****** Object:  View [bhp].[vw_StageTypesAllowedInHop]    Script Date: 3/4/2020 1:46:10 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_StageTypesAllowedInHop]'))
DROP VIEW [bhp].[vw_StageTypesAllowedInHop]
GO

/****** Object:  View [bhp].[vw_StageTypesAllowedInAging]    Script Date: 3/4/2020 1:46:10 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_StageTypesAllowedInAging]'))
DROP VIEW [bhp].[vw_StageTypesAllowedInAging]
GO

/****** Object:  View [bhp].[vw_StageTypes]    Script Date: 3/4/2020 1:46:10 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_StageTypes]'))
DROP VIEW [bhp].[vw_StageTypes]
GO

/****** Object:  View [bhp].[vw_StageTypes]    Script Date: 3/4/2020 1:46:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [bhp].[vw_StageTypes] (
	RowID, [Name], Lang, 
	AllowedInHopSched, AllowedInYeastSched, AllowedInMashSched, AllowedInAgingSched, 
	AKA1, AKA2, AKA3, CreatedOn,
	Comment
)
with schemabinding
as
SELECT 
	[RowID]
	,[Name]
	,ISNULL([Lang],N'en_us')
	,[AllowedInHopSched]
	,[AllowedInYeastSched]
	,[AllowedInMashSched]
	,[AllowedInAgingSched]
	,[AKA1]
	,[AKA2]
	,[AKA3]
	,[EnteredOn]
	,ISNULL(Comment,'no comment given...')
  FROM [bhp].[StageTypes];

GO

/****** Object:  View [bhp].[vw_StageTypesAllowedInAging]    Script Date: 3/4/2020 1:46:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [bhp].[vw_StageTypesAllowedInAging]
--with encryption
as
SELECT *
  FROM [bhp].[StageTypes] where AllowedInAgingSched = 1;
GO

/****** Object:  View [bhp].[vw_StageTypesAllowedInHop]    Script Date: 3/4/2020 1:46:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [bhp].[vw_StageTypesAllowedInHop]
--with encryption
as
SELECT *
  FROM [bhp].[StageTypes] where AllowedInHopSched = 1;
GO

/****** Object:  View [bhp].[vw_StageTypesAllowedInMash]    Script Date: 3/4/2020 1:46:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
create view [bhp].[vw_StageTypesAllowedInMash]
--with encryption
as
SELECT *
  FROM [bhp].[StageTypes] where AllowedInMashSched = 1;
GO

/****** Object:  View [bhp].[vw_StageTypesAllowedInYeast]    Script Date: 3/4/2020 1:46:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [bhp].[vw_StageTypesAllowedInYeast]
--with encryption
as
SELECT *
  FROM [bhp].[StageTypes] where AllowedInYeastSched = 1;
GO


