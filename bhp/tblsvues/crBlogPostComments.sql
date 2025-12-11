USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CK_BlogPostComments_CreatedBy]') AND parent_object_id = OBJECT_ID(N'[bhp].[BlogPostComments]'))
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [CK_BlogPostComments_CreatedBy]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_BlogPostComments_Fk_RplyComment]') AND parent_object_id = OBJECT_ID(N'[bhp].[BlogPostComments]'))
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [FK_BlogPostComments_Fk_RplyComment]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_BlogPostComments_Fk_BlogPostID]') AND parent_object_id = OBJECT_ID(N'[bhp].[BlogPostComments]'))
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [FK_BlogPostComments_Fk_BlogPostID]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostComments_DeployInfo]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [DF_BlogPostComments_DeployInfo]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostComments_TotCommentIndiffs]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [DF_BlogPostComments_TotCommentIndiffs]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostComments_TotCommentDisLikes]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [DF_BlogPostComments_TotCommentDisLikes]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostComments_TotCommentLikes]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [DF_BlogPostComments_TotCommentLikes]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostComments_IndiffToBlog]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [DF_BlogPostComments_IndiffToBlog]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostComments_DontLikeBlog]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [DF_BlogPostComments_DontLikeBlog]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostComments_LikeBlog]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostComments] DROP CONSTRAINT [DF_BlogPostComments_LikeBlog]
END
GO

/****** Object:  Table [bhp].[BlogPostComments]    Script Date: 2/28/2020 10:28:54 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[BlogPostComments]') AND type in (N'U'))
DROP TABLE [bhp].[BlogPostComments]
GO

/****** Object:  Table [bhp].[BlogPostComments]    Script Date: 2/28/2020 10:28:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[BlogPostComments](
	[CommentID] [bigint] IDENTITY(1,1) NOT NULL,
	[PostedOn] [datetime] NULL,
	[fk_CreatedBy] [bigint] NULL,
	[fk_BlogPostID] [bigint] NULL,
	[fk_ReplyCommentID] [bigint] NULL,
	[LikeBlog] [bit] NULL,
	[DontLikeBlog] [bit] NULL,
	[IndiffToBlog] [bit] NULL,
	[TotCommentLikes] [smallint] NULL,
	[TotCommentDisLikes] [smallint] NULL,
	[TotCommentIndiffs] [smallint] NULL,
	[Comment] [nvarchar](1000) NULL,
	[fk_DeployInfo] [int] NULL,
 CONSTRAINT [PK_BlogPostComments_CommentID] PRIMARY KEY NONCLUSTERED 
(
	[CommentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[BlogPostComments] ADD  CONSTRAINT [DF_BlogPostComments_LikeBlog]  DEFAULT ((0)) FOR [LikeBlog]
GO

ALTER TABLE [bhp].[BlogPostComments] ADD  CONSTRAINT [DF_BlogPostComments_DontLikeBlog]  DEFAULT ((0)) FOR [DontLikeBlog]
GO

ALTER TABLE [bhp].[BlogPostComments] ADD  CONSTRAINT [DF_BlogPostComments_IndiffToBlog]  DEFAULT ((0)) FOR [IndiffToBlog]
GO

ALTER TABLE [bhp].[BlogPostComments] ADD  CONSTRAINT [DF_BlogPostComments_TotCommentLikes]  DEFAULT ((0)) FOR [TotCommentLikes]
GO

ALTER TABLE [bhp].[BlogPostComments] ADD  CONSTRAINT [DF_BlogPostComments_TotCommentDisLikes]  DEFAULT ((0)) FOR [TotCommentDisLikes]
GO

ALTER TABLE [bhp].[BlogPostComments] ADD  CONSTRAINT [DF_BlogPostComments_TotCommentIndiffs]  DEFAULT ((0)) FOR [TotCommentIndiffs]
GO

alter table [bhp].[BlogPostComments] Add Constraint [DF_BlogPostComments_Fk_ReplyCommentID] default(0) for [fk_ReplyCommentID];
go

ALTER TABLE [bhp].[BlogPostComments] ADD  CONSTRAINT [DF_BlogPostComments_DeployInfo]  DEFAULT ((0)) FOR [fk_DeployInfo]
GO

Alter table [bhp].[BLogPostComments] Add Constraint [DF_BlogPostComments_PostedOn] Default(getdate()) for [PostedOn];
go

alter table [bhp].[BlogPostComments] Add Constraint [FK_BlogPostComments_Fk_DeployInfo]
foreign key (Fk_DeployInfo) References [di].[Deployments](RowID);

ALTER TABLE [bhp].[BlogPostComments]  WITH CHECK ADD  CONSTRAINT [FK_BlogPostComments_Fk_BlogPostID] FOREIGN KEY([fk_BlogPostID])
REFERENCES [bhp].[RecipeBlogPosts] ([RowID])
GO

ALTER TABLE [bhp].[BlogPostComments] CHECK CONSTRAINT [FK_BlogPostComments_Fk_BlogPostID]
GO

ALTER TABLE [bhp].[BlogPostComments]  WITH CHECK ADD  CONSTRAINT [FK_BlogPostComments_Fk_RplyComment] FOREIGN KEY([fk_ReplyCommentID])
REFERENCES [bhp].[BlogPostComments] ([CommentID])
GO

ALTER TABLE [bhp].[BlogPostComments] CHECK CONSTRAINT [FK_BlogPostComments_Fk_RplyComment]
GO

alter table [bhp].BlogPostComments add Constraint FK_BlogPostComments_Fk_CreatedBy
Foreign Key (fk_CreatedBy) References [di].CustMstr (RowID);
go

set identity_insert [bhp].BlogPostComments on;
insert [bhp].BlogPostComments (CommentID, PostedOn, fk_CreatedBy, fk_BlogPostID, Comment)
values (0,0,0,0,N'DO NOT REMOVE!!!');
set identity_insert [bhp].BlogPostComments off;
go

Create Trigger [bhp].BlogPostComments_Trig_Ins_01 on [bhp].BlogPostComments
for insert
as
begin
	Update [bhp].RecipeBlogPosts
		Set 
			TotLikeIt = (Convert(int,ISNULL(I.LikeBlog,0)) + ISNULL(B.TotLikeIt,0)),
			TotDontLike = (Convert(int,ISNULL(I.DontLikeBlog,0)) + ISNULL(B.TotDontLike,0)),
			TotIndiff = (Convert(int,ISNULL(I.TotCommentIndiffs,0)) + ISNULL(B.TotIndiff,0))
	From [bhp].RecipeBlogPosts B
	Inner Join Inserted I on (B.RowID = I.fk_BlogPostID);
end
go

Create Trigger [bhp].BlogPostComments_Trig_Del_01 on [bhp].BlogPostComments
for delete
as
begin
	Update [bhp].RecipeBlogPosts
		Set TotLikeIt = (ISNULL(B.TotLikeIt,1) - 1)
	From [bhp].RecipeBlogPosts B
	Inner Join deleted d on (B.RowID = d.fk_BlogPostID And ISNULL(d.LikeBlog,0) = 1);

	Update [bhp].RecipeBlogPosts
		Set TotDontLike = (ISNULL(B.TotDontLike,1) - 1)
	From [bhp].RecipeBlogPosts B
	Inner Join deleted d on (B.RowID = d.fk_BlogPostID And ISNULL(d.DontLikeBlog,0) = 1);

	Update [bhp].RecipeBlogPosts
		Set TotIndiff = (ISNULL(B.TotIndiff,1) - 1)
	From [bhp].RecipeBlogPosts B
	Inner Join deleted d on (B.RowID = d.fk_BlogPostID And ISNULL(d.IndiffToBlog,0) = 1);
end
go

Create trigger [bhp].BlogPostComments_Trig_Del_99 on [bhp].BlogPostComments
for delete
as
begin
	If Exists (Select * from deleted where (CommentID = 0))
	Begin
		Raiserror('Comment Record ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction
	End
end
go

checkpoint

