USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_RecipeMashScheduleBinder]    Script Date: 3/4/2020 1:42:22 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeMashScheduleBinder]'))
DROP VIEW [bhp].[vw_RecipeMashScheduleBinder]
GO

/****** Object:  View [bhp].[vw_RecipeHopScheduleBinder]    Script Date: 3/4/2020 1:42:22 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeHopScheduleBinder]'))
DROP VIEW [bhp].[vw_RecipeHopScheduleBinder]
GO

/****** Object:  View [bhp].[vw_RecipeAgingScheduleBinder]    Script Date: 3/4/2020 1:42:22 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeAgingScheduleBinder]'))
DROP VIEW [bhp].[vw_RecipeAgingScheduleBinder]
GO

/****** Object:  View [bhp].[vw_RecipeAgingScheduleBinder]    Script Date: 3/4/2020 1:42:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE View [bhp].[vw_RecipeAgingScheduleBinder] (
	RowID, RecipeID, RecipeName, SchedID, SchedName, fk_CreatedBy, CustName
)
As
Select 0,0,'pls select...',0,'pls select...',0,'no cust'
Union
Select 
	RASB.RowID, 
	RASB.fk_RecipeJrnlMstrID, 
	RASB.[RecipeName], 
	RASB.Fk_AgingSchedMstrID, 
	ASM.[Name], 
	RJM.fk_CreatedBy,
	Case 
		When CM.DisplayAs IS NULL Then CM.[Name]
		When CM.Name != ISNULL(CM.DisplayAs,CM.Name) Then CM.DisplayAs
		Else CM.DisplayAs 
	End
From [bhp].RecipeAgingSchedBinder RASB
Inner join [bhp].RecipeJrnlMstr RJM On (RASB.fk_RecipeJrnlMstrID = RJM.RowID)
Inner Join [bhp].AgingSchedMstr ASM On (RASB.fk_AgingSchedMstrID = ASM.RowID)
Inner Join [di].CustMstr CM On (RJM.fk_CreatedBy = CM.RowID)
Where (RASB.RowID > 0);
GO

/****** Object:  View [bhp].[vw_RecipeHopScheduleBinder]    Script Date: 3/4/2020 1:42:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE View [bhp].[vw_RecipeHopScheduleBinder] (
	RowID, RecipeID, RecipeName, SchedID, SchedName, CreatedByCustID, CustName, TotHopsInSched
)
As
Select 0,0,'pls select...',0,'pls select...',0,'no cust',0
union
Select 
	RHSB.RowID, 
	RHSB.fk_RecipeJrnlMstrID, 
	RJM.Name [RecipeName], 
	RHSB.Fk_HopSchedMstrID, 
	HSM.Name [HopScheduleName], 
	RJM.fk_CreatedBy,
	Case 
		When CM.DisplayAs IS NULL Then CM.[Name]
		When CM.Name != ISNULL(CM.DisplayAs,CM.Name) Then CM.DisplayAs
		Else CM.DisplayAs 
	End,
	(	
		Case fk_HopSchedMstrID
		When 0 Then 0
		Else
			(Select ISNULL(Count(*),0) From [bhp].HopSchedDetails WHere (fk_HopSchedMstrID = RHSB.fk_HopSchedMstrID And fk_HopSchedMstrID > 0))
		End
	)
From [bhp].RecipeHopSchedBinder RHSB
Inner join [bhp].RecipeJrnlMstr RJM On (RHSB.fk_RecipeJrnlMstrID = RJM.RowID)
Inner Join [bhp].HopSchedMstr HSM On (RHSB.fk_HopSchedMstrID = HSM.RowID)
Inner Join [di].CustMstr CM On (RJM.fk_CreatedBy = CM.RowID);
GO

/****** Object:  View [bhp].[vw_RecipeMashScheduleBinder]    Script Date: 3/4/2020 1:42:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE View [bhp].[vw_RecipeMashScheduleBinder] (
	RowID, RecipeID, RecipeName, SchedID, SchedName, CreatedByCustID, CustName
)
As
Select 0,0,'pls select...',0,'pls select...',0,'no cust'
union
Select 
	RMSB.RowID, 
	RMSB.fk_RecipeJrnlMstrID, 
	RMSB.[RecipeName], 
	RMSB.fk_MashSchedMstrID, 
	MSM.Name As [SchedName], 
	RJM.fk_CreatedBy,
	Case 
		When CM.DisplayAs IS NULL Then CM.[Name]
		When CM.Name != ISNULL(CM.DisplayAs,CM.Name) Then CM.DisplayAs
		Else CM.DisplayAs 
	End
From [bhp].RecipeMashSchedBinder RMSB
Inner join [bhp].RecipeJrnlMstr RJM On (RMSB.fk_RecipeJrnlMstrID = RJM.RowID)
Inner Join [bhp].MashSchedMstr MSM On (RMSB.fk_MashSchedMstrID = MSM.RowID)
Inner Join [di].CustMstr CM On (RJM.fk_CreatedBy = CM.RowID)
Where (RMSB.RowID > 0);


GO


