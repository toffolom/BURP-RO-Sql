USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CK_BlogPostCategories_CreatedBy]') AND parent_object_id = OBJECT_ID(N'[bhp].[BlogPostCategories]'))
ALTER TABLE [bhp].[BlogPostCategories] DROP CONSTRAINT [CK_BlogPostCategories_CreatedBy]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostCat_IsDflt4Nu]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostCategories] DROP CONSTRAINT [DF_BlogPostCat_IsDflt4Nu]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostCategories_DeployInfo]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostCategories] DROP CONSTRAINT [DF_BlogPostCategories_DeployInfo]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_BlogPostCat_CreatedOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[BlogPostCategories] DROP CONSTRAINT [DF_BlogPostCat_CreatedOn]
END
GO

/****** Object:  Table [bhp].[BlogPostCategories]    Script Date: 2/28/2020 10:37:55 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[BlogPostCategories]') AND type in (N'U'))
DROP TABLE [bhp].[BlogPostCategories]
GO

/****** Object:  Table [bhp].[BlogPostCategories]    Script Date: 2/28/2020 10:37:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[BlogPostCategories](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Descr] [nvarchar](1000) NULL,
	[CreatedBy] [bigint] NULL,
	[CreatedOn] [datetime] NULL,
	[AllowSubs] [bit] NULL,
	[fk_DeployInfo] [int] NULL,
	[IsDfltForNu] [bit] NOT NULL,
 CONSTRAINT [PK_BlogPostCategories] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[BlogPostCategories] ADD  CONSTRAINT [DF_BlogPostCat_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO

ALTER TABLE [bhp].[BlogPostCategories] ADD  CONSTRAINT [DF_BlogPostCategories_DeployInfo]  DEFAULT ((0)) FOR [fk_DeployInfo]
GO

ALTER TABLE [bhp].[BlogPostCategories] ADD  CONSTRAINT [DF_BlogPostCategories_CreatedBy]  DEFAULT ((0)) FOR [CreatedBy];
GO

ALTER TABLE [bhp].[BlogPostCategories] ADD  CONSTRAINT [DF_BlogPostCat_IsDflt4Nu]  DEFAULT ((0)) FOR [IsDfltForNu]
GO

ALTER TABLE [bhp].[BlogPostCategories] ADD  CONSTRAINT [DF_BlogPostCat_AllowSubs]  DEFAULT ((0)) FOR [AllowSubs];
GO

ALTER TABLE [bhp].[BlogPostCategories]  WITH CHECK ADD  CONSTRAINT [FK_BlogPostCategories_DeployInfo] 
Foreign Key (fk_DeployInfo) References [di].[Deployments](RowID);
GO

ALTER TABLE [bhp].[BlogPostCategories]  WITH CHECK ADD  CONSTRAINT [FK_BlogPostCategories_CreatedBy] 
Foreign Key (CreatedBy) References [di].[CustMstr](RowID);
GO

Create Trigger [bhp].BlogPostCategories_Del_99 on [bhp].BlogPostCategories
--with encryption
for delete
as
begin
	Raiserror(N'Blog Category Record(s) cannot be removed!!!',16,1);
	Rollback Transaction;
end
go

set identity_insert [bhp].BlogPostCategories On;
insert into [bhp].BlogPostCategories (RowID, [Name], [Descr], CreatedBy, CreatedOn, AllowSubs)
values (0,'pls select...','please select a category...',0,0,0);
set identity_insert [bhp].BlogPostCategories Off;
go

insert into [bhp].BlogPostCategories([Name],[Descr],CreatedBy,AllowSubs)
values ('Process Improvement','about improving the product production process',0,1),
('Bitching','just wanna bitch about something...',0,1),
('Praising','would like give praise to something...',0,1),
('Packaging','ideas about how to pkg product...',0,1),
('Undef','an undefined comment/post category!?',0,0),
('Informational','general informational post/comment...',0,1),
('Scheduling','comment(s)/posting about product scheduling, and/or, about release dates...',0,1),
('Tap Take-over','postings about a tap take over...',0,1),
('Shipping','comment/posting regarding product shipping issues/concerns...',0,1),
('Admin','administrative comments/postings...',0,0);
go


