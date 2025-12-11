USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CK_AgingSchedMstr_CreatedBy]') AND parent_object_id = OBJECT_ID(N'[bhp].[AgingSchedMstr]'))
ALTER TABLE [bhp].[AgingSchedMstr] DROP CONSTRAINT [CK_AgingSchedMstr_CreatedBy]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CHK_AgingSchedMstr_DeployInfo]') AND parent_object_id = OBJECT_ID(N'[bhp].[AgingSchedMstr]'))
ALTER TABLE [bhp].[AgingSchedMstr] DROP CONSTRAINT [CHK_AgingSchedMstr_DeployInfo]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_AgingSchedDtlTimeUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[AgingSchedDetails]'))
ALTER TABLE [bhp].[AgingSchedDetails] DROP CONSTRAINT [FK_AgingSchedDtlTimeUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_AgingSchedDtlStage]') AND parent_object_id = OBJECT_ID(N'[bhp].[AgingSchedDetails]'))
ALTER TABLE [bhp].[AgingSchedDetails] DROP CONSTRAINT [FK_AgingSchedDtlStage]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_AgingSchedDtlMstrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[AgingSchedDetails]'))
ALTER TABLE [bhp].[AgingSchedDetails] DROP CONSTRAINT [FK_AgingSchedDtlMstrID]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_AgingSchedMstr_SharingMask]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedMstr] DROP CONSTRAINT [DF_AgingSchedMstr_SharingMask]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_AgingSchedMstr_DeployInfo]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedMstr] DROP CONSTRAINT [DF_AgingSchedMstr_DeployInfo]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_AgingSchedMstr_isDfltForNu]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedMstr] DROP CONSTRAINT [DF_AgingSchedMstr_isDfltForNu]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__AgingSchedMstr__UsageCount]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedMstr] DROP CONSTRAINT [DF__AgingSchedMstr__UsageCount]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__AgingSchedMstr_fk_CreatedBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedMstr] DROP CONSTRAINT [DF__AgingSchedMstr_fk_CreatedBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_AgingSchedDtl_TempRangUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedDetails] DROP CONSTRAINT [DF_AgingSchedDtl_TempRangUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_AgingSchedDtl_EndTempRange]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedDetails] DROP CONSTRAINT [DF_AgingSchedDtl_EndTempRange]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_AgingSchedDtl_BegTempRange]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedDetails] DROP CONSTRAINT [DF_AgingSchedDtl_BegTempRange]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_AgingSchedDtl_DurationUOM_Day]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedDetails] DROP CONSTRAINT [DF_AgingSchedDtl_DurationUOM_Day]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__AgingSchedDtl_Duration]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[AgingSchedDetails] DROP CONSTRAINT [DF__AgingSchedDtl_Duration]
END
GO

/****** Object:  Table [bhp].[RecipeAgingSchedBinder]    Script Date: 3/3/2020 1:17:56 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeAgingSchedBinder]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeAgingSchedBinder];
GO

/****** Object:  Table [bhp].[AgingSchedMstr]    Script Date: 3/3/2020 1:17:56 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[AgingSchedMstr]') AND type in (N'U'))
DROP TABLE [bhp].[AgingSchedMstr]
GO

/****** Object:  Table [bhp].[AgingSchedDetails]    Script Date: 3/3/2020 1:17:56 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[AgingSchedDetails]') AND type in (N'U'))
DROP TABLE [bhp].[AgingSchedDetails]
GO

/****** Object:  Table [bhp].[AgingSchedDetails]    Script Date: 3/3/2020 1:17:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[AgingSchedDetails](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_AgingSchedMstrID] [int] NOT NULL,
	[StepName] [varchar](50) NOT NULL,
	[fk_Stage] [int] NULL,
	[StageName]  AS ([bhp].[fn_GetStageName]([fk_Stage])),
	[Duration] [numeric](14, 2) NULL,
	[fk_DurationUOM] [int] NULL,
	[DurationUOM]  AS ([bhp].[fn_GetUOM]([fk_DurationUOM])),
	[BegTempRange] [int] NULL,
	[EndTempRange] [int] NULL,
	[fk_TempRangeUOM] [int] NULL,
	[TempRangeUOM]  AS ([bhp].[fn_GetUOM]([fk_TempRangeUOM])),
	[Comment] [nvarchar](1000) NULL,
 CONSTRAINT [PK_AgingSchedDetails_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [bhp].[AgingSchedMstr]    Script Date: 3/3/2020 1:17:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[AgingSchedMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[fk_CreatedBy] [bigint] NOT NULL,
	[BHPUid]  AS ([di].[fn_GetCustLoginNm]([fk_CreatedBy])),
	[UsageCount] [int] NULL,
	[Comments] [nvarchar](4000) NULL,
	[isDfltForNu] [bit] NULL,
	[fk_DeployInfo] [int] NULL,
	[SharingMask] [int] NOT NULL,
	[SharingMaskAsCSV]  AS ([bhp].[fn_SharingTypesMaskToStr]([SharingMask])),
 CONSTRAINT [PK__AgingSchedMstr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[AgingSchedDetails] ADD  CONSTRAINT [DF__AgingSchedDtl_Duration]  DEFAULT ((0)) FOR [Duration]
GO

ALTER TABLE [bhp].[AgingSchedDetails] ADD  CONSTRAINT [DF_AgingSchedDtl_DurationUOM_Day]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('day')) FOR [fk_DurationUOM]
GO

ALTER TABLE [bhp].[AgingSchedDetails] ADD  CONSTRAINT [DF_AgingSchedDtl_BegTempRange]  DEFAULT ((0)) FOR [BegTempRange]
GO

ALTER TABLE [bhp].[AgingSchedDetails] ADD  CONSTRAINT [DF_AgingSchedDtl_EndTempRange]  DEFAULT ((0)) FOR [EndTempRange]
GO

ALTER TABLE [bhp].[AgingSchedDetails] ADD  CONSTRAINT [DF_AgingSchedDtl_TempRangUOM]  DEFAULT ([bhp].[fn_getUOMIdByNm]('F')) FOR [fk_TempRangeUOM]
GO

ALTER TABLE [bhp].[AgingSchedMstr] ADD  CONSTRAINT [DF__AgingSchedMstr_fk_CreatedBy]  DEFAULT ((0)) FOR [fk_CreatedBy]
GO

ALTER TABLE [bhp].[AgingSchedMstr] ADD  CONSTRAINT [DF__AgingSchedMstr__UsageCount]  DEFAULT ((0)) FOR [UsageCount]
GO

ALTER TABLE [bhp].[AgingSchedMstr] ADD  CONSTRAINT [DF_AgingSchedMstr_isDfltForNu]  DEFAULT ((0)) FOR [isDfltForNu]
GO

ALTER TABLE [bhp].[AgingSchedMstr] ADD  CONSTRAINT [DF_AgingSchedMstr_DeployInfo]  DEFAULT ((0)) FOR [fk_DeployInfo]
GO

ALTER TABLE [bhp].[AgingSchedMstr] ADD  CONSTRAINT [DF_AgingSchedMstr_SharingMask]  DEFAULT ((0)) FOR [SharingMask]
GO

ALTER TABLE [bhp].[AgingSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_AgingSchedDtlMstrID] FOREIGN KEY([fk_AgingSchedMstrID])
REFERENCES [bhp].[AgingSchedMstr] ([RowID])
GO

ALTER TABLE [bhp].[AgingSchedDetails] CHECK CONSTRAINT [FK_AgingSchedDtlMstrID]
GO

ALTER TABLE [bhp].[AgingSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_AgingSchedDtlStage] FOREIGN KEY([fk_Stage])
REFERENCES [bhp].[StageTypes] ([RowID])
GO

ALTER TABLE [bhp].[AgingSchedDetails] CHECK CONSTRAINT [FK_AgingSchedDtlStage]
GO

ALTER TABLE [bhp].[AgingSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_AgingSchedDtlTimeUOM] FOREIGN KEY([fk_DurationUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[AgingSchedDetails] CHECK CONSTRAINT [FK_AgingSchedDtlTimeUOM]
GO

ALTER TABLE [bhp].[AgingSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_AgingSchedMstr_DeployInfo] 
Foreign Key ([fk_DeployInfo]) References [di].[Deployments] (RowID);
GO

ALTER TABLE [bhp].[AgingSchedMstr] CHECK CONSTRAINT [FK_AgingSchedMstr_DeployInfo]
GO

ALTER TABLE [bhp].[AgingSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_AgingSchedMstr_CreatedBy] 
Foreign Key ([fk_CreatedBy]) References [di].[CustMstr] (RowID);
GO

ALTER TABLE [bhp].[AgingSchedMstr] CHECK CONSTRAINT [FK_AgingSchedMstr_CreatedBy]
GO

/****** Object:  Trigger [bhp].[AgingSchedMstr_Trig_Del_99]    Script Date: 3/3/2020 1:18:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[AgingSchedMstr_Trig_Del_99] on [bhp].[AgingSchedMstr] 
--with encryption
for delete
as
begin
	If Exists (Select * from Deleted Where RowID = 0)
	Begin
		Raiserror('Aging Schedue ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end 
GO

set identity_insert [bhp].[AgingSchedMstr] on;
insert into [bhp].[AgingSchedMstr] (RowID, Name, fk_CreatedBy, UsageCount, Comments, isDfltForNu, fk_DeployInfo, SharingMask)
values (0,'dummy',0,0,N'DO NOT REMOVE!!!',0,0,0);
set identity_insert [bhp].[AgingSchedMstr] off;
go

create trigger AgingSchedDetails_Trig_Del_99 on [bhp].AgingSchedDetails 
with encryption
for delete
as
begin
	If Exists (Select * from Deleted Where RowID = 0)
	Begin
		Raiserror('Aging Schedule Detail Item ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

create trigger AgingSchedDetails_Trig_InsUpd_01 on [bhp].AgingSchedDetails 
with encryption
for insert,update
as
begin
	If Exists (Select * from Inserted I Where (fk_Stage > 0)
		And (fk_Stage Not In (Select RowID from [bhp].StageTypes Where (AllowedInAgingSched = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + Name from [bhp].StageTypes Where (AllowedInAgingSched = 1);
		Raiserror('Allowed Aging schedule stages are:[%s]...aborting!!!',16,1,@Buff);
		Rollback Transaction;
	End
end
go


create trigger AgingSchedDetails_Trig_InsUpd_02 on [bhp].AgingSchedDetails
with encryption
for insert,update
as
begin
	If Exists (Select * from Inserted I Where (fk_DurationUOM > 0)
		And (fk_DurationUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsTimeMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsTimeMeasure = 1);
		Raiserror('Aging Schedule Time UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

create trigger AgingSchedDetails_Trig_InsUpd_03 on [bhp].AgingSchedDetails
with encryption
for insert,update
as
begin
	If Exists (Select * from Inserted I Where (fk_TempRangeUOM > 0)
		And (fk_TempRangeUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsTemperature = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsTemperature = 1);
		Raiserror('Aging Schedule Temp UOM(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

set identity_insert [bhp].AgingSchedDetails on;
insert into [bhp].AgingSchedDetails (RowID, fk_AgingSchedMstrID, StepName, fk_Stage, Duration, fk_DurationUOM, BegTempRange, EndTempRange, Comment)
select 0,0,'dummy',0,0.0,0,0,0,'do not remove...here for referential integrity purposes!!!'
set identity_insert [bhp].AgingSchedDetails off;
go

create table [bhp].RecipeAgingSchedBinder (
	RowID int identity(1,1) not null,
	fk_RecipeJrnlMstrID int not null,
	RecipeName as [bhp].fn_GetRecipeName(fk_RecipeJrnlMstrID),
	fk_AgingSchedMstrID int not null,
	Comments nvarchar(2000) null default('<Notes><Note nbr=''0''/></Notes>')
constraint PK_RecipeAgingschedBinder_RowID primary key nonclustered (RowID)
)
go

alter table [bhp].RecipeAgingSchedBinder add
constraint FK_RecipeAgingSchedBinder_RecipeID foreign key (fk_RecipeJrnlMstrID) references [bhp].RecipeJrnlMstr (RowID),
constraint FK_RecipeAgingSchedBinder_AgingSchedID foreign key (fk_AgingSchedMstrID) references [bhp].AgingSchedMstr(RowID);
go

create trigger RecipeAgingSchedBinder_Trig_Ins_1 on [bhp].RecipeAgingSchedBinder
with encryption
for insert
as
begin
	Update [bhp].AgingSchedMstr
		Set UsageCount = isnull(UsageCount,0) + 1
	From Inserted I Inner Join [bhp].AgingSchedMstr C On (I.fk_AgingSchedMstrID = C.RowID)
	Where (I.fk_AgingSchedMstrID != 0);
end
go

create trigger RecipeAgingSchedBinder_Trig_Del_1 on [bhp].RecipeAgingSchedBinder
with encryption
for delete
as
begin
	Update [bhp].AgingSchedMstr
		Set UsageCount = isnull(UsageCount,1) - 1
	From Inserted I Inner Join [bhp].AgingSchedMstr C On (I.fk_AgingSchedMstrID = C.RowID)
	Where (I.fk_AgingSchedMstrID != 0);
end
go