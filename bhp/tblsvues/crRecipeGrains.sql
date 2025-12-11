USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_StageID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeGrains]'))
ALTER TABLE [bhp].[RecipeGrains] DROP CONSTRAINT [FK_StageID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeJrnlMstrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeGrains]'))
ALTER TABLE [bhp].[RecipeGrains] DROP CONSTRAINT [FK_RecipeJrnlMstrID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_GrainUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeGrains]'))
ALTER TABLE [bhp].[RecipeGrains] DROP CONSTRAINT [FK_GrainUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_GrainMstrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeGrains]'))
ALTER TABLE [bhp].[RecipeGrains] DROP CONSTRAINT [FK_GrainMstrID]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeGrains_fkStage]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeGrains] DROP CONSTRAINT [DF__RecipeGrains_fkStage]
END
GO

/****** Object:  Index [IDX_RecipeGrains_JrnlGrain]    Script Date: 3/3/2020 12:14:52 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[RecipeGrains]') AND name = N'IDX_RecipeGrains_JrnlGrain')
DROP INDEX [IDX_RecipeGrains_JrnlGrain] ON [bhp].[RecipeGrains] WITH ( ONLINE = OFF )
GO

/****** Object:  Table [bhp].[RecipeGrains]    Script Date: 3/3/2020 12:14:52 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeGrains]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeGrains]
GO

/****** Object:  Table [bhp].[RecipeGrains]    Script Date: 3/3/2020 12:14:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[RecipeGrains](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_RecipeJrnlMstrID] [int] NOT NULL,
	[fk_GrainMstrID] [int] NOT NULL,
	[GrainName]  AS ([bhp].[fn_GetGrainName]([fk_grainMstrID])),
	[fk_GrainUOM] [int] NOT NULL,
	[UOM]  AS ([bhp].[fn_getUOM]([fk_GrainUOM])),
	[QtyOrAmount] [numeric](10, 4) NOT NULL,
	[fk_Stage] [int] NOT NULL,
	[Comment] [nvarchar](4000) NULL,
 CONSTRAINT [PK__RecipeGrains_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RecipeGrains_JrnlGrain]    Script Date: 3/3/2020 12:14:52 PM ******/
CREATE CLUSTERED INDEX [IDX_RecipeGrains_JrnlGrain] ON [bhp].[RecipeGrains]
(
	[fk_RecipeJrnlMstrID] ASC,
	[fk_GrainMstrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[RecipeGrains] ADD  
CONSTRAINT [DF__RecipeGrains_fkStage]  DEFAULT ((0)) FOR [fk_Stage],
Constraint [DF_RecipeGrains_fkGrainMstr] Default(0) for [Fk_GrainMstrID],
Constraint [DF_RecipeGrains_FkRecipeJrnl] Default(0) for [Fk_RecipeJrnlMstrID],
Constraint [DF_RecipeGrains_FkGrainUOMID] Default(0) for [Fk_GrainUOM];
GO

ALTER TABLE [bhp].[RecipeGrains]  WITH CHECK ADD  CONSTRAINT [FK_GrainMstrID] FOREIGN KEY([fk_GrainMstrID])
REFERENCES [bhp].[GrainMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeGrains] CHECK CONSTRAINT [FK_GrainMstrID]
GO

ALTER TABLE [bhp].[RecipeGrains]  WITH CHECK ADD  CONSTRAINT [FK_GrainUOM] FOREIGN KEY([fk_GrainUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeGrains] CHECK CONSTRAINT [FK_GrainUOM]
GO

ALTER TABLE [bhp].[RecipeGrains]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstrID] FOREIGN KEY([fk_RecipeJrnlMstrID])
REFERENCES [bhp].[RecipeJrnlMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeGrains] CHECK CONSTRAINT [FK_RecipeJrnlMstrID]
GO

ALTER TABLE [bhp].[RecipeGrains]  WITH CHECK ADD  CONSTRAINT [FK_StageID] FOREIGN KEY([fk_Stage])
REFERENCES [bhp].[StageTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeGrains] CHECK CONSTRAINT [FK_StageID]
GO

set identity_Insert [bhp].RecipeGrains on;
insert into [bhp].RecipeGrains (RowID, QtyOrAmount, Comment) values (0,0.00,'DO NOT REMOVE!!!');
set identity_Insert [bhp].RecipeGrains off;
go

create trigger RecipeGrains_Trig_Del_99 on [bhp].RecipeGrains
with encryption
for delete
as
begin
	If Exists (Select * from deleted where rowid = 0)
	begin
		Raiserror('Recipe Grain Zero cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	end
end
go

create trigger RecipeGrains_Trig_Ins_01 on [bhp].RecipeGrains
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_grainUOM > 0)
		And (fk_grainUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Grain Amount UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

create trigger RecipeGrains_Trig_Ins_02 on [bhp].RecipeGrains
with encryption
for insert
as
begin
	Update [bhp].GrainMstr
		Set NbrOfRecipesUsedIn = isnull(NbrOfRecipesUsedIn,0) + 1
	From [bhp].GrainMstr G Inner Join Inserted I
	On (G.RowID = I.fk_GrainMstrID);
end
go

create trigger RecipeGrains_Trig_Del_01 on [bhp].RecipeGrains
with encryption
for delete
as
begin
	Update [bhp].GrainMstr
		Set NbrOfRecipesUsedIn = (NbrOfRecipesUsedIn - 1)
	From [bhp].GrainMstr G Inner Join Inserted I
	On (G.RowID = I.fk_GrainMstrID)
	Where (G.NbrOfRecipesUsedIn is not null And G.NbrOfRecipesUsedIn > 0);
end
go