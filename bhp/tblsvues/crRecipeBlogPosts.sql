USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CK_RecipeBlogPosts_PostedByID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeBlogPosts]'))
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [CK_RecipeBlogPosts_PostedByID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeBlogPosts_Fk_BlogMstrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeBlogPosts]'))
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [FK_RecipeBlogPosts_Fk_BlogMstrID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeBlogPosts_BlogPostCategory]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeBlogPosts]'))
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [FK_RecipeBlogPosts_BlogPostCategory]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeBlogPosts_Title]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF_RecipeBlogPosts_Title]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeBlogPosts_DeployInfo]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF_RecipeBlogPosts_DeployInfo]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPosts_Hide]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPosts_Hide]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPosts__HasSpam]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPosts__HasSpam]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPosts_TotInDiff]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPosts_TotInDiff]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPosts_TotDisLike]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPosts_TotDisLike]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPosts_TotLikeIt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPosts_TotLikeIt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPosts_HasEmbeddedLink]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPosts_HasEmbeddedLink]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPosts_fk_PostedByID]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPosts_fk_PostedByID]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPosts_BlogPost]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPosts_BlogPost]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeBlogPosts_EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF_RecipeBlogPosts_EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogPost_fk_RecipeJrnlMstrID]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogPosts] DROP CONSTRAINT [DF__RecipeBlogPost_fk_RecipeJrnlMstrID]
END
GO

/****** Object:  Index [IX_RecipeBlogPosts_RecipeID_EnteredOn]    Script Date: 2/28/2020 10:51:57 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[RecipeBlogPosts]') AND name = N'IX_RecipeBlogPosts_RecipeID_EnteredOn')
DROP INDEX [IX_RecipeBlogPosts_RecipeID_EnteredOn] ON [bhp].[RecipeBlogPosts] WITH ( ONLINE = OFF )
GO

/****** Object:  Table [bhp].[RecipeBlogPosts]    Script Date: 2/28/2020 10:51:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeBlogPosts]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeBlogPosts]
GO

/****** Object:  Table [bhp].[RecipeBlogPosts]    Script Date: 2/28/2020 10:51:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[RecipeBlogPosts](
	[RowID] [bigint] IDENTITY(1,1) NOT NULL,
	[fk_RecipeBlogMstrID] [int] NOT NULL,
	[EnteredOn] [datetime] NOT NULL,
	[BlogPost] [nvarchar](4000) NULL,
	[fk_PostedByID] [bigint] NULL,
	[HasEmbeddedLinks] [bit] NULL,
	[TotLikeIt] [int] NULL,
	[TotDontLike] [int] NULL,
	[TotIndiff] [int] NULL,
	[HasSpam] [bit] NULL,
	[Hide] [bit] NULL,
	[LastRevisedOn] [datetime] NULL,
	[LastRevisedBy] [bigint] NULL,
	[fk_BlogPostCategory] [int] NULL,
	[fk_DeployInfo] [int] NULL,
	[Title] [varchar](200) NOT NULL,
 CONSTRAINT [PK_RecipeBlogPosts_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IX_RecipeBlogPosts_RecipeID_EnteredOn]    Script Date: 2/28/2020 10:51:57 AM ******/
CREATE CLUSTERED INDEX [IX_RecipeBlogPosts_RecipeID_EnteredOn] ON [bhp].[RecipeBlogPosts]
(
	[EnteredOn] ASC,
	[fk_RecipeBlogMstrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPost_fk_RecipeJrnlMstrID]  DEFAULT ((0)) FOR [fk_RecipeBlogMstrID]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF_RecipeBlogPosts_EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF_RecipeBlogPosts_LastRevisedOn]  DEFAULT (0) FOR [LastRevisedOn];
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF_RecipeBlogPosts_LastRevisedBy]  DEFAULT (0) FOR [LastRevisedBy];
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPosts_BlogPost]  DEFAULT ('n/a') FOR [BlogPost]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPosts_fk_PostedByID]  DEFAULT ((0)) FOR [fk_PostedByID]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPosts_HasEmbeddedLink]  DEFAULT ((0)) FOR [HasEmbeddedLinks]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPosts_TotLikeIt]  DEFAULT ((0)) FOR [TotLikeIt]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPosts_TotDisLike]  DEFAULT ((0)) FOR [TotDontLike]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPosts_TotInDiff]  DEFAULT ((0)) FOR [TotIndiff]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPosts__HasSpam]  DEFAULT ((0)) FOR [HasSpam]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF__RecipeBlogPosts_Hide]  DEFAULT ((0)) FOR [Hide]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF_RecipeBlogPosts_DeployInfo]  DEFAULT ((0)) FOR [fk_DeployInfo]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF_RecipeBlogPosts_Title]  DEFAULT ('no title') FOR [Title]
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ADD  CONSTRAINT [DF_RecipeBlogPosts_BlogCategory]  DEFAULT (0) FOR [fk_BlogPostCategory];
GO

ALTER TABLE [bhp].[RecipeBlogPosts]  WITH CHECK ADD  CONSTRAINT [FK_RecipeBlogPosts_BlogPostCategory] FOREIGN KEY([fk_BlogPostCategory])
REFERENCES [bhp].[BlogPostCategories] ([RowID])
GO

ALTER TABLE [bhp].[RecipeBlogPosts] CHECK CONSTRAINT [FK_RecipeBlogPosts_BlogPostCategory]
GO

ALTER TABLE [bhp].[RecipeBlogPosts]  WITH CHECK ADD  CONSTRAINT [FK_RecipeBlogPosts_Fk_BlogMstrID] FOREIGN KEY([fk_RecipeBlogMstrID])
REFERENCES [bhp].[RecipeBlogMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeBlogPosts] CHECK CONSTRAINT [FK_RecipeBlogPosts_Fk_BlogMstrID]
GO

ALTER TABLE [bhp].[RecipeBlogPosts]  WITH CHECK ADD  CONSTRAINT [Fk_RecipeBlogPosts_PostedByID] 
Foreign Key ([fk_PostedByID]) References [di].[CustMstr](RowID);
GO

ALTER TABLE [bhp].[RecipeBlogPosts] CHECK CONSTRAINT [Fk_RecipeBlogPosts_PostedByID]
GO

ALTER TABLE [bhp].[RecipeBlogPosts]  WITH CHECK ADD  CONSTRAINT [Fk_RecipeBlogPosts_LastRevisedBy] 
Foreign Key ([LastRevisedBy]) References [di].[CustMstr](RowID);
GO

Set Identity_Insert [bhp].[RecipeBlogPosts] on;
insert into [bhp].[RecipeBlogPosts](RowID,EnteredOn,Hide) values (0,0,1);
Set Identity_Insert [bhp].[RecipeBlogPosts] off;
go

/****** Object:  Trigger [bhp].[RecipeBlogPosts_Trig_Del_1]    Script Date: 2/28/2020 10:52:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[RecipeBlogPosts_Trig_Del_1] on [bhp].[RecipeBlogPosts] 
for delete
as
begin
	Set NoCount On;
	Update [bhp].RecipeBlogMstr
		Set TotPosts = (ISNULL(M.TotPosts,1) - 1)
	From [bhp].RecipeBlogMstr M
	Inner Join deleted d On (M.RowID = d.fk_RecipeBlogMstrID);
end
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ENABLE TRIGGER [RecipeBlogPosts_Trig_Del_1]
GO

/****** Object:  Trigger [bhp].[RecipeBlogPosts_Trig_Del_99]    Script Date: 2/28/2020 10:52:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create trigger [bhp].[RecipeBlogPosts_Trig_Del_99] on [bhp].[RecipeBlogPosts]
for delete
as
begin
	If Exists (Select * from deleted where (RowID = 0))
	Begin
		Raiserror('Blog Post Record ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction
	End
end
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ENABLE TRIGGER [RecipeBlogPosts_Trig_Del_99]
GO

/****** Object:  Trigger [bhp].[RecipeBlogPosts_Trig_Ins_1]    Script Date: 2/28/2020 10:52:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[RecipeBlogPosts_Trig_Ins_1] on [bhp].[RecipeBlogPosts] 
for insert
as
begin
	Set NoCount On;
	Update [bhp].RecipeBlogMstr
		Set TotPosts = isnull(M.TotPosts,0) + 1
	From [bhp].RecipeBlogMstr M
	Inner Join Inserted I On (M.RowID = I.fk_RecipeBlogMstrID);
end
GO

ALTER TABLE [bhp].[RecipeBlogPosts] ENABLE TRIGGER [RecipeBlogPosts_Trig_Ins_1]
GO


