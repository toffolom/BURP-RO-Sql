USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_MashTypes]    Script Date: 3/13/2020 11:49:02 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_MashTypes]'))
DROP VIEW [bhp].[vw_MashTypes]
GO

/****** Object:  View [bhp].[vw_MashTypes]    Script Date: 3/13/2020 11:49:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/
create view [bhp].[vw_MashTypes] (
	RowID, Name, fk_TempUOM, TempUOM, BegTempAmt, EndTempAmt, Comments
)
with schemabinding
as
SELECT 
	[RowID]
	,[Name]
	,fk_TempUOM
	,TempUOM
	,BegTempAmt
	,EndTempAmt
	,isnull(Comments,N'not set')
  FROM [bhp].[MashTypeMstr]; --Where (RowID > 0);

GO


