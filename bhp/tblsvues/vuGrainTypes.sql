USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_GrainTypes]    Script Date: 2/28/2020 11:37:13 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_GrainTypes]'))
DROP VIEW [bhp].[vw_GrainTypes]
GO

/****** Object:  View [bhp].[vw_GrainTypes]    Script Date: 2/28/2020 11:37:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE view [bhp].[vw_GrainTypes] (
	RowID, [Name], Lang, EnteredBy, EnteredOn
)
with schemabinding
as
select
	GT.RowID,
	GT.[Name],
	ISNULL(GT.Lang,'en_us'),
	GT.EnteredBy,
	GT.EnteredOn
from [bhp].GrainTypes GT;
GO


