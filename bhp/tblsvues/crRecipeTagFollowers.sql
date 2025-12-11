USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CHK_RecipeTagFollowers_Fk_DeployID]') AND parent_object_id = OBJECT_ID(N'[bhp].[Recipe_Tag_Followers]'))
ALTER TABLE [bhp].[Recipe_Tag_Followers] DROP CONSTRAINT [CHK_RecipeTagFollowers_Fk_DeployID]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CHK_RecipeTagFollowers_Fk_CustID]') AND parent_object_id = OBJECT_ID(N'[bhp].[Recipe_Tag_Followers]'))
ALTER TABLE [bhp].[Recipe_Tag_Followers] DROP CONSTRAINT [CHK_RecipeTagFollowers_Fk_CustID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeTagFollowers_Fk_TagID]') AND parent_object_id = OBJECT_ID(N'[bhp].[Recipe_Tag_Followers]'))
ALTER TABLE [bhp].[Recipe_Tag_Followers] DROP CONSTRAINT [FK_RecipeTagFollowers_Fk_TagID]
GO

/****** Object:  Table [bhp].[Recipe_Tag_Followers]    Script Date: 3/3/2020 1:14:24 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[Recipe_Tag_Followers]') AND type in (N'U'))
DROP TABLE [bhp].[Recipe_Tag_Followers]
GO

/****** Object:  Table [bhp].[Recipe_Tag_Followers]    Script Date: 3/3/2020 1:14:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[Recipe_Tag_Followers](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_TagID] [bigint] NOT NULL,
	[fk_CustID] [bigint] NOT NULL,
	[fk_Cust_DeployID] [int] NOT NULL,
	[fk_Follow_Props] [int] NOT NULL,
 CONSTRAINT [PK_RecipeTagFollowers_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[Recipe_Tag_Followers]  WITH CHECK ADD  CONSTRAINT [FK_RecipeTagFollowers_Fk_TagID] FOREIGN KEY([fk_TagID])
REFERENCES [bhp].[BHPTagWords] ([RowID])
GO

ALTER TABLE [bhp].[Recipe_Tag_Followers] CHECK CONSTRAINT [FK_RecipeTagFollowers_Fk_TagID]
GO

ALTER TABLE [bhp].[Recipe_Tag_Followers]  WITH CHECK ADD  CONSTRAINT [FK_RecipeTagFollowers_Fk_CustID] 
Foreign Key([fk_CustID]) References [di].[CustMstr] (RowID);
GO

ALTER TABLE [bhp].[Recipe_Tag_Followers] CHECK CONSTRAINT [FK_RecipeTagFollowers_Fk_CustID]
GO

ALTER TABLE [bhp].[Recipe_Tag_Followers]  WITH CHECK ADD  CONSTRAINT [FK_RecipeTagFollowers_Fk_DeployID] 
Foreign Key ([fk_Cust_DeployID]) References [di].[Deployments] (RowID);
GO

ALTER TABLE [bhp].[Recipe_Tag_Followers] CHECK CONSTRAINT [FK_RecipeTagFollowers_Fk_DeployID]
GO


