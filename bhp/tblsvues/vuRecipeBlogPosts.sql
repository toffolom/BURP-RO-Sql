USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_RecipeBlogs]    Script Date: 3/24/2020 4:49:55 PM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[bhp].[vw_RecipeBlogs]'))
DROP VIEW [bhp].[vw_RecipeBlogs]
GO

/****** Object:  View [bhp].[vw_RecipeBlogs]    Script Date: 3/24/2020 4:49:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










CREATE view [bhp].[vw_RecipeBlogs] (
	RecipeID, RecipeName, BlogId, BlogName, BlogPostID, Post, 
	CreatedBy, CreatedOn, TotalLikes, TotalDislikes, TotalIndifferent, IsHidden,
	isBrewerComment
)
--WITH ENCRYPTION, SCHEMABINDING
as
	select
		RJM.RowID,
		RJM.Name,
		RBM.RowID, 
		RBM.Name, 
		RBP.RowID,
		RBP.BlogPost, 
		Case 
			When CM.DisplayAs IS NULL Then CM.[Name]
			When CM.Name != ISNULL(CM.DisplayAs,CM.Name) Then CM.DisplayAs
			Else CM.DisplayAs 
		End,
		RBP.EnteredOn,
		RBP.TotLikeIt,
		RBP.TotDontLike,
		RBP.TotIndiff,
		ISNULL(RBP.Hide,0),
		[di].fn_ISBrewer(RBP.fk_PostedByID)
	from 
	bhp.RecipeJrnlMstr RJM
	Inner Join bhp.RecipeBlogMstr RBM On (RJM.RowID = RBM.fk_RecipeJrnlMstrID)
	Inner Join bhp.RecipeBlogPosts RBP On (RBM.RowID = RBP.fk_RecipeBlogMstrID)
	Inner Join [di].vw_CustomerMstr CM On (RBP.fk_PostedByID = CM.RowID);

GO


