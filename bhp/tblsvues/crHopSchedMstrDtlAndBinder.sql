USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CK_HopSchedMstr_CreatedBy]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopSchedMstr]'))
ALTER TABLE [bhp].[HopSchedMstr] DROP CONSTRAINT [CK_HopSchedMstr_CreatedBy]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CHK_HopSchedMstr_DeployInfo]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopSchedMstr]'))
ALTER TABLE [bhp].[HopSchedMstr] DROP CONSTRAINT [CHK_HopSchedMstr_DeployInfo]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeHopSchedBinder_RecipeID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeHopSchedBinder]'))
ALTER TABLE [bhp].[RecipeHopSchedBinder] DROP CONSTRAINT [FK_RecipeHopSchedBinder_RecipeID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeHopSchedBinder_HopSchedID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeHopSchedBinder]'))
ALTER TABLE [bhp].[RecipeHopSchedBinder] DROP CONSTRAINT [FK_RecipeHopSchedBinder_HopSchedID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopSchedDtlTimeUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopSchedDetails]'))
ALTER TABLE [bhp].[HopSchedDetails] DROP CONSTRAINT [FK_HopSchedDtlTimeUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopSchedDtlStage]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopSchedDetails]'))
ALTER TABLE [bhp].[HopSchedDetails] DROP CONSTRAINT [FK_HopSchedDtlStage]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopSchedDtlMstrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopSchedDetails]'))
ALTER TABLE [bhp].[HopSchedDetails] DROP CONSTRAINT [FK_HopSchedDtlMstrID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopSchedDtlHopUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopSchedDetails]'))
ALTER TABLE [bhp].[HopSchedDetails] DROP CONSTRAINT [FK_HopSchedDtlHopUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopSchedDtlHopTyp]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopSchedDetails]'))
ALTER TABLE [bhp].[HopSchedDetails] DROP CONSTRAINT [FK_HopSchedDtlHopTyp]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopSchedDtlCostUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopSchedDetails]'))
ALTER TABLE [bhp].[HopSchedDetails] DROP CONSTRAINT [FK_HopSchedDtlCostUOM]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopSchedMstr_fk_TotBoilTimeUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopSchedMstr] DROP CONSTRAINT [DF_HopSchedMstr_fk_TotBoilTimeUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopSchedMstr_TotBoilTime]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopSchedMstr] DROP CONSTRAINT [DF_HopSchedMstr_TotBoilTime]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopSchedMstr_SharingMask]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopSchedMstr] DROP CONSTRAINT [DF_HopSchedMstr_SharingMask]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopSchedMstr_DeployInfo]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopSchedMstr] DROP CONSTRAINT [DF_HopSchedMstr_DeployInfo]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopSchedMstr_TotRecipes]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopSchedMstr] DROP CONSTRAINT [DF_HopSchedMstr_TotRecipes]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopSchedMstr_Fk_CreatedBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopSchedMstr] DROP CONSTRAINT [DF_HopSchedMstr_Fk_CreatedBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopSchedDtls_fk_TimeUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopSchedDetails] DROP CONSTRAINT [DF_HopSchedDtls_fk_TimeUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopSchedDtls_TimeAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopSchedDetails] DROP CONSTRAINT [DF_HopSchedDtls_TimeAmt]
END
GO

/****** Object:  Index [IDX_HopSchedMstr_NameDeployment]    Script Date: 3/3/2020 2:19:22 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[HopSchedMstr]') AND name = N'IDX_HopSchedMstr_NameDeployment')
DROP INDEX [IDX_HopSchedMstr_NameDeployment] ON [bhp].[HopSchedMstr]
GO

/****** Object:  Index [IDX_HopSchedDetails_SchedNStepNm]    Script Date: 3/3/2020 2:19:22 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[HopSchedDetails]') AND name = N'IDX_HopSchedDetails_SchedNStepNm')
DROP INDEX [IDX_HopSchedDetails_SchedNStepNm] ON [bhp].[HopSchedDetails]
GO

/****** Object:  Index [IDX_RecipeHopSchedBinder_AllCols]    Script Date: 3/3/2020 2:19:22 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[RecipeHopSchedBinder]') AND name = N'IDX_RecipeHopSchedBinder_AllCols')
DROP INDEX [IDX_RecipeHopSchedBinder_AllCols] ON [bhp].[RecipeHopSchedBinder] WITH ( ONLINE = OFF )
GO

/****** Object:  Table [bhp].[RecipeHopSchedBinder]    Script Date: 3/3/2020 2:19:22 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeHopSchedBinder]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeHopSchedBinder]
GO

/****** Object:  Table [bhp].[HopSchedMstr]    Script Date: 3/3/2020 2:19:22 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[HopSchedMstr]') AND type in (N'U'))
DROP TABLE [bhp].[HopSchedMstr]
GO

/****** Object:  Table [bhp].[HopSchedDetails]    Script Date: 3/3/2020 2:19:22 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[HopSchedDetails]') AND type in (N'U'))
DROP TABLE [bhp].[HopSchedDetails]
GO

/****** Object:  Table [bhp].[HopSchedDetails]    Script Date: 3/3/2020 2:19:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[HopSchedDetails](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_HopSchedMstrID] [int] NOT NULL,
	[StepName] [varchar](50) NOT NULL,
	[fk_HopTypID] [int] NOT NULL,
	[QtyOrAmount] [numeric](14, 2) NOT NULL,
	[fk_HopUOM] [int] NOT NULL,
	[HopUOM]  AS ([bhp].[fn_GetUOM]([fk_HopUOM])),
	[fk_Stage] [int] NOT NULL,
	[StageName]  AS ([bhp].[fn_GetStageName]([fk_Stage])),
	[TimeAmt] [numeric](14, 2) NULL,
	[fk_TimeUOM] [int] NULL,
	[TimeUOM]  AS ([bhp].[fn_GetUOM]([fk_TimeUOM])),
	[Comment] [nvarchar](1000) NULL,
	[CostAmt] [numeric](6, 2) NULL,
	[fk_CostUOM] [int] NULL,
	[costUOM]  AS ([bhp].[fn_GetUOM]([fk_CostUOM])),
	[HopName]  AS ([bhp].[fn_GetHopNameV2]([fk_HopTypID])),
 CONSTRAINT [PK_HopSchedDetails_RowID] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [bhp].[HopSchedMstr]    Script Date: 3/3/2020 2:19:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[HopSchedMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[fk_CreatedBy] [bigint] NOT NULL,
	[CreatedBy]  AS ([di].[fn_GetCustLoginNm]([fk_CreatedBy])),
	[TotRecipes] [int] NULL,
	[Comments] [nvarchar](4000) NULL,
	[fk_DeployInfo] [int] NULL,
	[SharingMask] [int] NOT NULL,
	[SharingMaskAsCSV]  AS ([bhp].[fn_SharingTypesMaskToStr]([SharingMask])),
	[TotBoilTime] [numeric](9, 2) NOT NULL,
	[fk_TotBoilTimeUOM] [int] NOT NULL,
 CONSTRAINT [PK__HopSched__RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [bhp].[RecipeHopSchedBinder]    Script Date: 3/3/2020 2:19:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[RecipeHopSchedBinder](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_RecipeJrnlMstrID] [int] NOT NULL,
	[fk_HopSchedMstrID] [int] NOT NULL,
 CONSTRAINT [PK_RecipeHopschedBinder_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RecipeHopSchedBinder_AllCols]    Script Date: 3/3/2020 2:19:22 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IDX_RecipeHopSchedBinder_AllCols] ON [bhp].[RecipeHopSchedBinder]
(
	[fk_RecipeJrnlMstrID] ASC,
	[fk_HopSchedMstrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_HopSchedDetails_SchedNStepNm]    Script Date: 3/3/2020 2:19:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_HopSchedDetails_SchedNStepNm] ON [bhp].[HopSchedDetails]
(
	[fk_HopSchedMstrID] ASC,
	[StepName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_HopSchedMstr_NameDeployment]    Script Date: 3/3/2020 2:19:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_HopSchedMstr_NameDeployment] ON [bhp].[HopSchedMstr]
(
	[Name] ASC,
	[fk_DeployInfo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[HopSchedDetails] ADD  CONSTRAINT [DF_HopSchedDtls_TimeAmt]  DEFAULT ((0)) FOR [TimeAmt]
GO

ALTER TABLE [bhp].[HopSchedDetails] ADD  CONSTRAINT [DF_HopSchedDtls_fk_TimeUOM]  DEFAULT ((0)) FOR [fk_TimeUOM]
GO

ALTER TABLE [bhp].[HopSchedMstr] ADD  CONSTRAINT [DF_HopSchedMstr_Fk_CreatedBy]  DEFAULT ((0)) FOR [fk_CreatedBy]
GO

ALTER TABLE [bhp].[HopSchedMstr] ADD  CONSTRAINT [DF_HopSchedMstr_TotRecipes]  DEFAULT ((0)) FOR [TotRecipes]
GO

ALTER TABLE [bhp].[HopSchedMstr] ADD  CONSTRAINT [DF_HopSchedMstr_DeployInfo]  DEFAULT ((0)) FOR [fk_DeployInfo]
GO

ALTER TABLE [bhp].[HopSchedMstr] ADD  CONSTRAINT [DF_HopSchedMstr_SharingMask]  DEFAULT ((0)) FOR [SharingMask]
GO

ALTER TABLE [bhp].[HopSchedMstr] ADD  CONSTRAINT [DF_HopSchedMstr_TotBoilTime]  DEFAULT ((60)) FOR [TotBoilTime]
GO

ALTER TABLE [bhp].[HopSchedMstr] ADD  CONSTRAINT [DF_HopSchedMstr_fk_TotBoilTimeUOM]  DEFAULT ([bhp].[fn_GetUOMIDByNm]('min')) FOR [fk_TotBoilTimeUOM]
GO

ALTER TABLE [bhp].[HopSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_HopSchedDtlCostUOM] FOREIGN KEY([fk_CostUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[HopSchedDetails] CHECK CONSTRAINT [FK_HopSchedDtlCostUOM]
GO

ALTER TABLE [bhp].[HopSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_HopSchedDtlHopTyp] FOREIGN KEY([fk_HopTypID])
REFERENCES [bhp].[HopTypesV2] ([RowID])
GO

ALTER TABLE [bhp].[HopSchedDetails] CHECK CONSTRAINT [FK_HopSchedDtlHopTyp]
GO

ALTER TABLE [bhp].[HopSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_HopSchedDtlHopUOM] FOREIGN KEY([fk_HopUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[HopSchedDetails] CHECK CONSTRAINT [FK_HopSchedDtlHopUOM]
GO

ALTER TABLE [bhp].[HopSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_HopSchedDtlMstrID] FOREIGN KEY([fk_HopSchedMstrID])
REFERENCES [bhp].[HopSchedMstr] ([RowID])
GO

ALTER TABLE [bhp].[HopSchedDetails] CHECK CONSTRAINT [FK_HopSchedDtlMstrID]
GO

ALTER TABLE [bhp].[HopSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_HopSchedDtlStage] FOREIGN KEY([fk_Stage])
REFERENCES [bhp].[StageTypes] ([RowID])
GO

ALTER TABLE [bhp].[HopSchedDetails] CHECK CONSTRAINT [FK_HopSchedDtlStage]
GO

ALTER TABLE [bhp].[HopSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_HopSchedDtlTimeUOM] FOREIGN KEY([fk_TimeUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[HopSchedDetails] CHECK CONSTRAINT [FK_HopSchedDtlTimeUOM]
GO

ALTER TABLE [bhp].[RecipeHopSchedBinder]  WITH CHECK ADD  CONSTRAINT [FK_RecipeHopSchedBinder_HopSchedID] FOREIGN KEY([fk_HopSchedMstrID])
REFERENCES [bhp].[HopSchedMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeHopSchedBinder] CHECK CONSTRAINT [FK_RecipeHopSchedBinder_HopSchedID]
GO

ALTER TABLE [bhp].[RecipeHopSchedBinder]  WITH CHECK ADD  CONSTRAINT [FK_RecipeHopSchedBinder_RecipeID] FOREIGN KEY([fk_RecipeJrnlMstrID])
REFERENCES [bhp].[RecipeJrnlMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeHopSchedBinder] CHECK CONSTRAINT [FK_RecipeHopSchedBinder_RecipeID]
GO

ALTER TABLE [bhp].[HopSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_HopSchedMstr_DeployInfo] 
Foreign Key ([fk_DeployInfo]) References [di].[Deployments] (RowID);
GO

ALTER TABLE [bhp].[HopSchedMstr] CHECK CONSTRAINT [FK_HopSchedMstr_DeployInfo]
GO

ALTER TABLE [bhp].[HopSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_HopSchedMstr_CreatedBy] 
Foreign Key ([fk_CreatedBy]) References [di].[CustMstr] (RowID);
GO

ALTER TABLE [bhp].[HopSchedMstr] CHECK CONSTRAINT [FK_HopSchedMstr_CreatedBy]
GO

set identity_Insert [bhp].[HopSchedMstr] On;
insert into [bhp].[HopSchedMstr] (RowID, Name, fk_CreatedBy,Comments, fk_DeployInfo, SharingMask, fk_TotBoilTimeUOM, TotBoilTime)
values (0,'Dummy',0,'DO NOT REMOVE!!!',0,0,0,0);
set identity_Insert [bhp].[HopSchedMstr] Off;
go

set identity_insert [bhp].[HopSchedDetails] on;
insert into [bhp].[HopSchedDetails](RowID,fk_HopSchedMstrID,StepName,fk_HopTypID,QtyOrAmount,fk_HopUOM,fk_Stage,TimeAmt,fk_TimeUOM,Comment,CostAmt,fk_CostUOM)
values (0,0,'dummy',0,0.00,0,0,0.00,0,'DO NOT REMOVE!!!',0.00,0);
set identity_insert [bhp].[HopSchedDetails] off;
go

/****** Object:  Trigger [bhp].[HopSchedMstr_Trig_Del_99]    Script Date: 3/3/2020 2:20:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[HopSchedMstr_Trig_Del_99] on [bhp].[HopSchedMstr] 
--with encryption
for delete
as
begin
	If Exists (Select * from Deleted Where RowID = 0)
	Begin
		Raiserror('Hop Schedue ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
GO



/****** Object:  Trigger [bhp].[HopSchedMstr_Trig_Upd_99]    Script Date: 3/3/2020 2:20:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[HopSchedMstr_Trig_Upd_99] on [bhp].[HopSchedMstr] 
--with encryption
for update
as
begin
	If Exists (Select * from Deleted Where RowID = 0)
	Begin
		Raiserror('Hop Schedule ''Zero'' cannot be modified...aborting!!!',16,1);
		Rollback Transaction;
	End
end
GO

create trigger HopSchedDetails_Trig_Del_99 on [bhp].HopSchedDetails 
with encryption
for delete
as
begin
	If Exists (Select * from Deleted Where RowID = 0)
	Begin
		Raiserror('Hop Schedule Detail Item ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

create trigger HopSchedDetails_Trig_Upd_99 on [bhp].HopSchedDetails 
with encryption
for update
as
begin
	If Exists (Select * from Deleted Where RowID = 0)
	Begin
		Raiserror('Hop Schedule Detail Item ''Zero'' cannot be modified...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

create trigger HopSchedDetails_Trig_Ins_01 on [bhp].HopSchedDetails 
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_Stage > 0)
		And (fk_Stage Not In (Select RowID from [bhp].StageTypes Where (AllowedInHopSched = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + Name from [bhp].StageTypes Where (AllowedInHopSched = 1);
		Raiserror('Allowed hop schedule stages are:[%s]...aborting!!!',16,1,@Buff);
		Rollback Transaction;
	End
end
go

create trigger HopSchedDetails_Trig_Ins_02 on [bhp].HopSchedDetails
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_HopUOM > 0)
		And (fk_HopUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Hop Amount UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

create trigger HopSchedDetails_Trig_Ins_03 on [bhp].HopSchedDetails
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_TimeUOM > 0)
		And (fk_TimeUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsTimeMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsTimeMeasure = 1);
		Raiserror('Hop Schedule Time UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

create trigger HopSchedDetails_Trig_Ins_04 on [bhp].HopSchedDetails 
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_CostUOM > 0)
		And (fk_CostUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsMonetary = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + Name from [bhp].UOMTypes Where (AllowedAsMonetary = 1);
		Raiserror('Cost can only be described using:[%s]...aborting!!!',16,1,@Buff);
		Rollback Transaction;
	End
end
go

create trigger HopSchedDetails_Trig_Upd_01 on [bhp].HopSchedDetails 
with encryption
for update
as
begin
	If Update(fk_CostUOM)
	Begin
		If Exists (Select * from Inserted I Where (fk_CostUOM > 0)
			And (fk_CostUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsMonetary = 1))))
		Begin
			Declare @buff varchar(2000);
			Select @buff = isnull(@buff + ',','') + Name from [bhp].UOMTypes Where (AllowedAsMonetary = 1);
			Raiserror('Cost can only be described using:[%s]...aborting!!!',16,1,@Buff);
			Rollback Transaction;
		End
	End
end
go

create trigger HopSchedDetails_Trig_Upd_02 on [bhp].HopSchedDetails 
with encryption
for update
as
begin
	If Update(fk_Stage)
	Begin
		If Exists (Select * from Inserted I Where (fk_Stage > 0)
			And (fk_Stage Not In (Select RowID from [bhp].StageTypes Where (AllowedInHopSched = 1))))
		Begin
			Declare @buff varchar(2000);
			Select @buff = isnull(@buff + ',','') + Name from [bhp].StageTypes Where (AllowedInHopSched = 1);
			Raiserror('Allowed hop schedule stages are:[%s]...aborting!!!',16,1,@Buff);
			Rollback Transaction;
		End
	End
end
go

create trigger HopSchedDetails_Trig_Upd_03 on [bhp].HopSchedDetails
with encryption
for update
as
begin
	If Update(fk_HopUOM)
	Begin
		If Exists (Select * from Inserted I Where (fk_HopUOM > 0)
			And (fk_HopUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
		Begin
			Declare @buff varchar(2000);
			Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
			Raiserror('Hop Amount UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
			Rollback transaction;
		End
	End
end
go

create trigger HopSchedDetails_Trig_Update_04 on [bhp].HopSchedDetails
with encryption
for update
as
begin
	If Update(fk_TimeUOM)
	Begin
		If Exists (Select * from Inserted I Where (fk_TimeUOM > 0)
			And (fk_TimeUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsTimeMeasure = 1))))
		Begin
			Declare @buff varchar(2000);
			Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsTimeMeasure = 1);
			Raiserror('Hop Schedule Time UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
			Rollback transaction;
		End
	End
end
go

create trigger RecipeHopSchedBinder_Trig_Ins_1 on [bhp].RecipeHopSchedBinder
--with encryption
for insert
as
begin
	Update [bhp].HopSchedMstr
		Set TotRecipes = isnull(C.TotRecipes,0) + 1
	From Inserted I Inner Join [bhp].HopSchedMstr C
	On (I.fk_HopSchedMstrID = C.RowID)
	Where (I.fk_RecipeJrnlMstrID > 0 And I.fk_HopSchedMstrID > 0);
end
go

create trigger RecipeHopSchedBinder_Trig_Del_1 on [bhp].RecipeHopSchedBinder
--with encryption
for delete
as
begin
	Update [bhp].HopSchedMstr
		Set TotRecipes = (ISNULL(TotRecipes,1) - 1)
	From Inserted I Inner Join [bhp].HopSchedMstr C
	On (I.fk_HopSchedMstrID = C.RowID)
	Where (I.fk_RecipeJrnlMstrID > 0 And I.fk_HopSchedMstrID > 0); -- And C.TotRecipes Is Not Null And C.TotRecipes > 0);
end
go
