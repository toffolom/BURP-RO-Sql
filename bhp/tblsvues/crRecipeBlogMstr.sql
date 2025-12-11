USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeBlogMstr_RecipeJrnlMstrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeBlogMstr]'))
ALTER TABLE [bhp].[RecipeBlogMstr] DROP CONSTRAINT [FK_RecipeBlogMstr_RecipeJrnlMstrID]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogMstr__EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogMstr] DROP CONSTRAINT [DF__RecipeBlogMstr__EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogMstr_TotPosts]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogMstr] DROP CONSTRAINT [DF__RecipeBlogMstr_TotPosts]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeBlogMstr_fk_RecipeJrnlMstrID]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeBlogMstr] DROP CONSTRAINT [DF__RecipeBlogMstr_fk_RecipeJrnlMstrID]
END
GO

/****** Object:  Index [IDX_RecipeBlogMstr_Fk_RecipeID]    Script Date: 2/28/2020 10:47:02 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[RecipeBlogMstr]') AND name = N'IDX_RecipeBlogMstr_Fk_RecipeID')
DROP INDEX [IDX_RecipeBlogMstr_Fk_RecipeID] ON [bhp].[RecipeBlogMstr]
GO

/****** Object:  Table [bhp].[RecipeBlogMstr]    Script Date: 2/28/2020 10:47:02 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeBlogMstr]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeBlogMstr]
GO

/****** Object:  Table [bhp].[RecipeBlogMstr]    Script Date: 2/28/2020 10:47:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[RecipeBlogMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[fk_RecipeJrnlMstrID] [int] NOT NULL,
	[TotPosts] [int] NULL,
	[EnteredOn] [datetime] NULL,
 CONSTRAINT [PK_RecipeBlogMstr] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RecipeBlogMstr_Fk_RecipeID]    Script Date: 2/28/2020 10:47:03 AM ******/
CREATE NONCLUSTERED INDEX [IDX_RecipeBlogMstr_Fk_RecipeID] ON [bhp].[RecipeBlogMstr]
(
	[fk_RecipeJrnlMstrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[RecipeBlogMstr] ADD  CONSTRAINT [DF__RecipeBlogMstr_fk_RecipeJrnlMstrID]  DEFAULT ((0)) FOR [fk_RecipeJrnlMstrID]
GO

ALTER TABLE [bhp].[RecipeBlogMstr] ADD  CONSTRAINT [DF__RecipeBlogMstr_TotPosts]  DEFAULT ((0)) FOR [TotPosts]
GO

ALTER TABLE [bhp].[RecipeBlogMstr] ADD  CONSTRAINT [DF__RecipeBlogMstr__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[RecipeBlogMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeBlogMstr_RecipeJrnlMstrID] FOREIGN KEY([fk_RecipeJrnlMstrID])
REFERENCES [bhp].[RecipeJrnlMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeBlogMstr] CHECK CONSTRAINT [FK_RecipeBlogMstr_RecipeJrnlMstrID]
GO

set identity_insert [bhp].[RecipeBlogMstr] on;
insert into [bhp].[RecipeBlogMstr] (RowID, Name, EnteredOn) Values (0,'blog not setup...',0);
set identity_insert [bhp].[RecipeBlogMstr] off;
go


/****** Object:  Trigger [bhp].[RecipeBlogMstr_Del_99]    Script Date: 2/28/2020 10:49:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [bhp].[RecipeBlogMstr_Del_99] on [bhp].[RecipeBlogMstr]
for delete
as
begin
	If Exists (Select * from deleted where (RowID = 0))
	Begin
		Raiserror('Blog Master Record ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction
	End
end
GO

ALTER TABLE [bhp].[RecipeBlogMstr] ENABLE TRIGGER [RecipeBlogMstr_Del_99]
GO


