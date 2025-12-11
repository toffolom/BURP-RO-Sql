USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeYeasts]'))
ALTER TABLE [bhp].[RecipeYeasts] DROP CONSTRAINT [FK_YeastUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastStage]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeYeasts]'))
ALTER TABLE [bhp].[RecipeYeasts] DROP CONSTRAINT [FK_YeastStage]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastMstrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeYeasts]'))
ALTER TABLE [bhp].[RecipeYeasts] DROP CONSTRAINT [FK_YeastMstrID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeYeasts_CostUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeYeasts]'))
ALTER TABLE [bhp].[RecipeYeasts] DROP CONSTRAINT [FK_RecipeYeasts_CostUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeJrnlMstr]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeYeasts]'))
ALTER TABLE [bhp].[RecipeYeasts] DROP CONSTRAINT [FK_RecipeJrnlMstr]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeYeasts_fk_OpCostUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeYeasts] DROP CONSTRAINT [DF_RecipeYeasts_fk_OpCostUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeYeasts_OpCost]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeYeasts] DROP CONSTRAINT [DF_RecipeYeasts_OpCost]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__RecipeYeasts_fk_Stage]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeYeasts] DROP CONSTRAINT [DF__RecipeYeasts_fk_Stage]
END
GO

/****** Object:  Index [IDX_RecipeYeasts_JrnlYst]    Script Date: 3/4/2020 2:49:05 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[RecipeYeasts]') AND name = N'IDX_RecipeYeasts_JrnlYst')
DROP INDEX [IDX_RecipeYeasts_JrnlYst] ON [bhp].[RecipeYeasts] WITH ( ONLINE = OFF )
GO

/****** Object:  Table [bhp].[RecipeYeasts]    Script Date: 3/4/2020 2:49:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeYeasts]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeYeasts]
GO

/****** Object:  Table [bhp].[RecipeYeasts]    Script Date: 3/4/2020 2:49:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[RecipeYeasts](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_RecipeJrnlMstrID] [int] NOT NULL,
	[fk_YeastMstrID] [int] NOT NULL,
	[fk_YeastUOM] [int] NOT NULL,
	[YeastUOM]  AS ([bhp].[fn_GetUOM]([fk_YeastUOM])),
	[QtyOrAmount] [numeric](10, 4) NOT NULL,
	[fk_Stage] [int] NOT NULL,
	[StageNm]  AS ([bhp].[fn_GetStageName]([fk_Stage])),
	[OpCost] [money] NULL,
	[fk_OpCostUOM] [int] NULL,
	[OpCostUOM]  AS ([bhp].[fn_getUOM]([fk_opCostUOM])),
	[Comment] [nvarchar](4000) NULL,
 CONSTRAINT [PK__RecipeYeasts_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RecipeYeasts_JrnlYst]    Script Date: 3/4/2020 2:49:05 PM ******/
CREATE CLUSTERED INDEX [IDX_RecipeYeasts_JrnlYst] ON [bhp].[RecipeYeasts]
(
	[fk_RecipeJrnlMstrID] ASC,
	[fk_YeastMstrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[RecipeYeasts] ADD  CONSTRAINT [DF__RecipeYeasts_fk_Stage]  DEFAULT ((0)) FOR [fk_Stage]
GO

ALTER TABLE [bhp].[RecipeYeasts] ADD  CONSTRAINT [DF_RecipeYeasts_OpCost]  DEFAULT ((0.00)) FOR [OpCost]
GO

ALTER TABLE [bhp].[RecipeYeasts] ADD  CONSTRAINT [DF_RecipeYeasts_fk_OpCostUOM]  DEFAULT ((0)) FOR [fk_OpCostUOM]
GO

ALTER TABLE [bhp].[RecipeYeasts]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr] FOREIGN KEY([fk_RecipeJrnlMstrID])
REFERENCES [bhp].[RecipeJrnlMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeYeasts] CHECK CONSTRAINT [FK_RecipeJrnlMstr]
GO

ALTER TABLE [bhp].[RecipeYeasts]  WITH CHECK ADD  CONSTRAINT [FK_RecipeYeasts_CostUOM] FOREIGN KEY([fk_OpCostUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeYeasts] CHECK CONSTRAINT [FK_RecipeYeasts_CostUOM]
GO

ALTER TABLE [bhp].[RecipeYeasts]  WITH CHECK ADD  CONSTRAINT [FK_YeastMstrID] FOREIGN KEY([fk_YeastMstrID])
REFERENCES [bhp].[YeastMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeYeasts] CHECK CONSTRAINT [FK_YeastMstrID]
GO

ALTER TABLE [bhp].[RecipeYeasts]  WITH CHECK ADD  CONSTRAINT [FK_YeastStage] FOREIGN KEY([fk_Stage])
REFERENCES [bhp].[StageTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeYeasts] CHECK CONSTRAINT [FK_YeastStage]
GO

ALTER TABLE [bhp].[RecipeYeasts]  WITH CHECK ADD  CONSTRAINT [FK_YeastUOM] FOREIGN KEY([fk_YeastUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeYeasts] CHECK CONSTRAINT [FK_YeastUOM]
GO

set identity_insert [bhp].[RecipeYeasts] on;
insert into [bhp].RecipeYeasts (RowID,fk_RecipeJrnlMstrID,fk_YeastMstrID,QtyOrAmount,fk_YeastUOM,Comment)
values (0,0,0,0.00,0,'DO NOT REMOVE!!!');
set identity_insert [bhp].[RecipeYeasts] off;
go

/****** Object:  Trigger [bhp].[RecipeYeasts_Trig_DecrYeastMstrRecipeCounter_00]    Script Date: 3/4/2020 2:49:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [bhp].[RecipeYeasts_Trig_DecrYeastMstrRecipeCounter_00] on [bhp].[RecipeYeasts]
--with encryption
for delete
as
begin
	Update [bhp].YeastMstr
		Set NbrOfRecipesUsedIn = (case YM.NbrOfRecipesUsedIn when null then 1 when 0 then 1 else YM.NbrOfRecipesUsedIn End) - 1
	From [bhp].YeastMstr YM Inner Join Inserted I On (YM.RowID = I.fk_YeastMstrID);
end
GO

ALTER TABLE [bhp].[RecipeYeasts] ENABLE TRIGGER [RecipeYeasts_Trig_DecrYeastMstrRecipeCounter_00]
GO

/****** Object:  Trigger [bhp].[RecipeYeasts_Trig_IncrYeastMstrRecipeCounter_03]    Script Date: 3/4/2020 2:49:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [bhp].[RecipeYeasts_Trig_IncrYeastMstrRecipeCounter_03] on [bhp].[RecipeYeasts]
--with encryption
for insert
as
begin
	Update [bhp].YeastMstr
		Set NbrOfRecipesUsedIn = isnull(NbrOfRecipesUsedIn,0) + 1
	From [bhp].YeastMstr YM Inner Join Inserted I On (YM.RowID = I.fk_YeastMstrID);
end
GO

ALTER TABLE [bhp].[RecipeYeasts] ENABLE TRIGGER [RecipeYeasts_Trig_IncrYeastMstrRecipeCounter_03]
GO

/****** Object:  Trigger [bhp].[RecipeYeasts_Trig_Ins_01]    Script Date: 3/4/2020 2:49:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [bhp].[RecipeYeasts_Trig_Ins_01] on [bhp].[RecipeYeasts]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_YeastUOM > 0)
		And (fk_YeastUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',space(0)) + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Yeast Amount UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
GO

ALTER TABLE [bhp].[RecipeYeasts] ENABLE TRIGGER [RecipeYeasts_Trig_Ins_01]
GO

/****** Object:  Trigger [bhp].[RecipeYeasts_Trig_Ins_02]    Script Date: 3/4/2020 2:49:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [bhp].[RecipeYeasts_Trig_Ins_02] on [bhp].[RecipeYeasts]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_Stage > 0)
		And (fk_Stage Not In (Select RowID from [bhp].StageTypes Where (AllowedInYeastSched = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + [Name] From [bhp].StageTypes Where (AllowedInYeastSched = 1);
		Raiserror('Yeast Stage(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
GO

ALTER TABLE [bhp].[RecipeYeasts] ENABLE TRIGGER [RecipeYeasts_Trig_Ins_02]
GO



