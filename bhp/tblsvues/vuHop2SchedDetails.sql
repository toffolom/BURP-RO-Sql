USE [BHP1-RO]
GO
drop view [bhp].[vw_HopSchedDetails];
go

/****** Object:  View [dbo].[vw_HopSchedDetails]    Script Date: 3/25/2020 3:47:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [bhp].[vw_HopSchedDetails] (
fk_HopSchedMstrID, SchedName, fk_HopTypID, HopName
)
as
select HSD.fk_HopSchedMstrID, HSM.Name As SchedName, H.RowID, H.Name As HopName
from bhp.HopSchedDetails HSD
inner join bhp.HopTypesV2 H On (HSD.fk_HopTypID = H.RowID And H.RowID > 0)
inner join bhp.HopSchedMstr HSM On (HSD.fk_HopSchedMstrID = HSM.RowID)
Group By HSD.fk_HopSchedMstrID, HSM.Name, H.RowID, H.Name;
GO

