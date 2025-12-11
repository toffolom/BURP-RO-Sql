USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_CustomerRecipes]    Script Date: 3/4/2020 3:20:16 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_CustomerRecipes]'))
DROP VIEW [bhp].[vw_CustomerRecipes]
GO

/****** Object:  View [bhp].[vw_CustomerRecipes]    Script Date: 3/4/2020 3:20:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/******
** this view...
******/
CREATE view [bhp].[vw_CustomerRecipes] (
	RowID, Name, fk_AHABeerStyle, AHABeerStyle, CustomerChoosenBeerStyle, TargetBatchSize, fk_TargetBatchUOM, TargetBatchUOM,
	--ActualBatchSize, ActualUOM, 
	CustID, CustomerName,
	isUnderConstruction, TotalBatchesMade, CreatedOn, 
	BlogHeadName, TotalBlogs, TotalLikes, TotalDislikes, TotalIndifferents,
	--SessionId, 
	Notes, BoilSize, BoilUOM, 
	--Brewer, Assistant_Brewer,
	MashTypeID, MashTypeName,
	MashScheduleID, MashScheduleName,
	BlogHeadID
)
as
SELECT 
	RJM.[RowID],
	RJM.[Name],
	ISNULL(RJM.fk_BeerStyle,0) As fk_BeerStyle,
	RJM.BeerStyle,
	'n/a', -- cust can set their own beer style name...NOTE: Not used!!!
	ISNULL(RJM.[TargetQty], 5.0),
	case RJM.[fk_TargetUOM] when 0 then [bhp].fn_GetUOMIdByNm('gal') else RJM.[fk_TargetUOM] end,
	[bhp].fn_GetUOM(case RJM.[fk_TargetUOM] when 0 then [bhp].fn_GetUOMIdByNm('gal') else RJM.[fk_TargetUOM] end),
	--RJM.[BatchQty],
	--(Select top(1) [Name] From [bhp].UOMTypes Where (RowID = RJM.[fk_BatchUOM])),
	RJM.[fk_CreatedBy], -- aka: customer id
	(Select Case When isnull(DisplayAs,'n/a') = 'n/a' Then [Name] Else DisplayAs End From [di].CustMstr Where (RowID = RJM.[fk_CreatedBy])),
	ISNULL(RJM.[isDraft],1),
	ISNULL(RJM.[totBatchesMade],0),
	RJM.[EnteredOn],
	RBM.Name,
	isnull(RBM.TotPosts,0),
	(select top(1) ISNULL(TotLikeIt,0) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID)),
	(select top(1) ISNULL(TotDontLike,0) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID)),
	(select top(1) ISNULL(TotIndiff,0) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID)),
	--(select top(1) SessID from [bhp].SessionMstr Where (CR.fk_CustID = fk_CustID) And (CreatedOn < GETDATE() And YEAR(ClosedOn) = 1900)),
	isnull(RJM.Notes, 'no notes (yet)!!!'),
	RJM.TargetBoilSize,
	(Select top(1) [Name] From [bhp].UOMTypes Where (RowID = RJM.fk_BoilSizeUOM)),
	--(Select Case When isnull(DisplayAs,'n/a') = 'n/a' Then [Name] Else DisplayAs End From [bhp].vw_BreweryBrewers Where (RowiD = RJM.[fk_BrewerID])),
	--(Select Case When isnull(DisplayAs,'n/a') = 'n/a' Then [Name] Else DisplayAs End From [bhp].vw_BreweryBrewers Where (RowiD = RJM.[fk_AsstBrewerID])),
	ISNULL(MASHMSTR.fk_MashTypeID,0),
	ISNULL(MASHMSTR.MashTypeNm,'not set'),
	ISNULL(MASHMSTR.RowID,0),
	ISNULL(MASHMSTR.Name,'not set'),
	RBM.RowID As BlogHeadID
  FROM [di].CustMstr CM
  Inner Join [bhp].RecipeJrnlMstr AS RJM On (CM.RowID = RJM.fk_CreatedBy) -- And CR.fk_RecipeJrnlMstrID = RJM.RowID)
  Left Join [bhp].RecipeBlogMstr As RBM On (RBM.fk_RecipeJrnlMstrID = RJM.RowID)
  --Left Join [bhp].SessionMstr As SM On (CR.fk_CustID = SM.fk_CustID)
  Left Join [bhp].RecipeMashSchedBinder RMSB On (RJM.RowID = RMSB.fk_RecipeJrnlMstrID)
  Left Join [bhp].MashSchedMstr MASHMSTR On (MASHMSTR.RowID = RMSB.fk_MashSchedMstrID And MASHMSTR.RowID > 0)
  Where (RJM.RowID > 0);
  
 

















GO


