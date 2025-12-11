USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_BoundMashTypes]    Script Date: 3/12/2020 1:49:46 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_BoundMashTypes]'))
DROP VIEW [bhp].[vw_BoundMashTypes]
GO

/****** Object:  View [bhp].[vw_BoundMashTypes]    Script Date: 3/12/2020 1:49:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [bhp].[vw_BoundMashTypes] (RowID, [Name], MashSchedID, ScheduleName, CreatedBy)
with schemabinding
as
	select 
		mt.RowID,
		mt.Name,
		mm.RowID,
		mm.Name,
		cm.BHPUid
	from [bhp].MashTypeMstr mt 
	inner join [bhp].MashSchedMstr mm on (mt.RowID = mm.fk_MashTypeID)
	inner join [di].CustMstr cm on (mm.fk_CreatedBy = cm.RowID)
	Where mt.RowID > 0;
GO


