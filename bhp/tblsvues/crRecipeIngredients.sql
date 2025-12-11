USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeIngredients_Stage]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeIngredients]'))
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [FK_RecipeIngredients_Stage]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeIngredients_RecipeJrnlMstr]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeIngredients]'))
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [FK_RecipeIngredients_RecipeJrnlMstr]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeIngredients_IngredientUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeIngredients]'))
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [FK_RecipeIngredients_IngredientUOM]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeIngredients_Phrase]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [DF_RecipeIngredients_Phrase]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeIngredients_Comment]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [DF_RecipeIngredients_Comment]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeIngredients_fk_Stage]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [DF__RecipeIngredients_fk_Stage]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeIngredients_QtyOrAmount]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [DF_RecipeIngredients_QtyOrAmount]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeIngredients_fk_IngredientUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [DF__RecipeIngredients_fk_IngredientUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeIngredients_fk_RecipeJrnlMstr]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeIngredients] DROP CONSTRAINT [DF__RecipeIngredients_fk_RecipeJrnlMstr]
END
GO

/****** Object:  Table [bhp].[RecipeIngredients]    Script Date: 2/25/2020 2:35:31 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeIngredients]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeIngredients]
GO

/****** Object:  Table [bhp].[RecipeIngredients]    Script Date: 2/25/2020 2:35:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[RecipeIngredients](
	[RowID] [bigint] IDENTITY(1,1) NOT NULL,
	[fk_RecipeJrnlMstrID] [int] NOT NULL,
	[fk_IngredientUOM] [int] NOT NULL,
	[QtyOrAmount] [numeric](10, 4) NOT NULL,
	[fk_Stage] [int] NOT NULL,
	[Comment] [nvarchar](4000) NULL,
	[Phrase] [nvarchar](1000) NOT NULL,
	[PhraseTags]  AS ([bhp].[fn_RecipeIngredientTags]([RowID])),
 CONSTRAINT [PK__RecipeIngredients_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[RecipeIngredients] ADD  CONSTRAINT [DF__RecipeIngredients_fk_RecipeJrnlMstr]  DEFAULT ((0)) FOR [fk_RecipeJrnlMstrID]
GO

ALTER TABLE [bhp].[RecipeIngredients] ADD  CONSTRAINT [DF__RecipeIngredients_fk_IngredientUOM]  DEFAULT ((0)) FOR [fk_IngredientUOM]
GO

ALTER TABLE [bhp].[RecipeIngredients] ADD  CONSTRAINT [DF_RecipeIngredients_QtyOrAmount]  DEFAULT ((0)) FOR [QtyOrAmount]
GO

ALTER TABLE [bhp].[RecipeIngredients] ADD  CONSTRAINT [DF__RecipeIngredients_fk_Stage]  DEFAULT ((0)) FOR [fk_Stage]
GO

ALTER TABLE [bhp].[RecipeIngredients] ADD  CONSTRAINT [DF_RecipeIngredients_Comment]  DEFAULT ('n/a') FOR [Comment]
GO

ALTER TABLE [bhp].[RecipeIngredients] ADD  CONSTRAINT [DF_RecipeIngredients_Phrase]  DEFAULT ('not set...') FOR [Phrase]
GO

ALTER TABLE [bhp].[RecipeIngredients]  WITH CHECK ADD  CONSTRAINT [FK_RecipeIngredients_IngredientUOM] FOREIGN KEY([fk_IngredientUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeIngredients] CHECK CONSTRAINT [FK_RecipeIngredients_IngredientUOM]
GO

ALTER TABLE [bhp].[RecipeIngredients]  WITH CHECK ADD  CONSTRAINT [FK_RecipeIngredients_RecipeJrnlMstr] FOREIGN KEY([fk_RecipeJrnlMstrID])
REFERENCES [bhp].[RecipeJrnlMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeIngredients] CHECK CONSTRAINT [FK_RecipeIngredients_RecipeJrnlMstr]
GO

ALTER TABLE [bhp].[RecipeIngredients]  WITH CHECK ADD  CONSTRAINT [FK_RecipeIngredients_Stage] FOREIGN KEY([fk_Stage])
REFERENCES [bhp].[StageTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeIngredients] CHECK CONSTRAINT [FK_RecipeIngredients_Stage]
GO

set identity_insert [bhp].[RecipeIngredients] on;
insert into [bhp].[RecipeIngredients] (RowID) values(0);
set identity_insert [bhp].[RecipeIngredients] off;
go

create trigger [bhp].[RecipeIngredients_Del_Trig_1] on [bhp].[RecipeIngredients] 
with encryption
for delete
as
begin
	If Exists (Select * from Deleted where rowid = 0)
	Begin
		Raiserror('Row ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end

GO

Create trigger [bhp].[RecipeIngredients_Trig_Ins_01] on [bhp].[RecipeIngredients]
with encryption
for insert
as
begin
	If Not Exists (Select 1 
		from Inserted I Inner Join [bhp].UOMTypes U 
		On (I.fk_IngredientUOM = U.RowID And U.AllowedAsVolumnMeasure = 1)
	)
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Ingredient Amount UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end

GO

