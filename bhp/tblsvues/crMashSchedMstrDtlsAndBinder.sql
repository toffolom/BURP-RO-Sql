USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CK_MashSchedMstr_CreatedBy]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedMstr]'))
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [CK_MashSchedMstr_CreatedBy]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CHK_MashSchedMstr_DeployInfo]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedMstr]'))
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [CHK_MashSchedMstr_DeployInfo]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeMashSchedBinder_RecipeID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeMashSchedBinder]'))
ALTER TABLE [bhp].[RecipeMashSchedBinder] DROP CONSTRAINT [FK_RecipeMashSchedBinder_RecipeID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeMashSchedBinder_MashSchedID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeMashSchedBinder]'))
ALTER TABLE [bhp].[RecipeMashSchedBinder] DROP CONSTRAINT [FK_RecipeMashSchedBinder_MashSchedID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedMstr_WtrToGrainRatioUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedMstr]'))
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [FK_MashSchedMstr_WtrToGrainRatioUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedMstr_MashType]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedMstr]'))
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [FK_MashSchedMstr_MashType]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedMstr_Fk_SpargeTypes]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedMstr]'))
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [FK_MashSchedMstr_Fk_SpargeTypes]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedDtls_WaterUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]'))
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [FK_MashSchedDtls_WaterUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedDtls_TimeID]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]'))
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [FK_MashSchedDtls_TimeID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedDtls_TargetTemps]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]'))
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [FK_MashSchedDtls_TargetTemps]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedDtls_StrikeTempID]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]'))
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [FK_MashSchedDtls_StrikeTempID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedDtls_StageID]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]'))
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [FK_MashSchedDtls_StageID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedDtls_MstrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]'))
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [FK_MashSchedDtls_MstrID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_MashSchedDtls_GrainUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]'))
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [FK_MashSchedDtls_GrainUOM]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_MashSchedMstr_SharingMask]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [DF_MashSchedMstr_SharingMask]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_MashSchedMstr_DeployInfo]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [DF_MashSchedMstr_DeployInfo]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_MashSchedMstr_IsDflt4Nu]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [DF_MashSchedMstr_IsDflt4Nu]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedMstr_Comments]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [DF__MashSchedMstr_Comments]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_MashSchedMstr_fk_WtrToGrainRatioUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [DF_MashSchedMstr_fk_WtrToGrainRatioUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_MashSchedMstr_WtrToGrainRatio]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [DF_MashSchedMstr_WtrToGrainRatio]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedMstr_TotRecipes]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [DF__MashSchedMstr_TotRecipes]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedMstr_fk_MashType]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedMstr] DROP CONSTRAINT [DF__MashSchedMstr_fk_MashType]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_GrainUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_GrainUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_GrainAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_GrainAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_WaterUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_WaterUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_WaterAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_WaterAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_TimeUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_TimeUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_EndTimeAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_EndTimeAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_BegTimeAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_BegTimeAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_TrgtTempsUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_TrgtTempsUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_EndTrgtTempAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_EndTrgtTempAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_BegTrgtTempAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_BegTrgtTempAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_StrikeTempUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_StrikeTempUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_StrikeTempAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_StrikeTempAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__MashSchedDtls_StageTypID]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashSchedDetails] DROP CONSTRAINT [DF__MashSchedDtls_StageTypID]
END
GO

/****** Object:  Index [IDX_MashSchedMstr_Name]    Script Date: 3/4/2020 10:40:27 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[MashSchedMstr]') AND name = N'IDX_MashSchedMstr_Name')
DROP INDEX [IDX_MashSchedMstr_Name] ON [bhp].[MashSchedMstr]
GO

/****** Object:  Index [IDX_MashSchedDtls_MstrIDStepNm]    Script Date: 3/4/2020 10:40:27 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]') AND name = N'IDX_MashSchedDtls_MstrIDStepNm')
DROP INDEX [IDX_MashSchedDtls_MstrIDStepNm] ON [bhp].[MashSchedDetails]
GO

/****** Object:  Table [bhp].[RecipeMashSchedBinder]    Script Date: 3/4/2020 10:40:27 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeMashSchedBinder]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeMashSchedBinder]
GO

/****** Object:  Table [bhp].[MashSchedMstr]    Script Date: 3/4/2020 10:40:27 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[MashSchedMstr]') AND type in (N'U'))
DROP TABLE [bhp].[MashSchedMstr]
GO

/****** Object:  Table [bhp].[MashSchedDetails]    Script Date: 3/4/2020 10:40:27 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[MashSchedDetails]') AND type in (N'U'))
DROP TABLE [bhp].[MashSchedDetails]
GO

/****** Object:  Table [bhp].[MashSchedDetails]    Script Date: 3/4/2020 10:40:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[MashSchedDetails](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_MashSchedMstrID] [int] NOT NULL,
	[StepName] [varchar](50) NOT NULL,
	[Pos] [int] NOT NULL,
	[fk_StageTypID] [int] NOT NULL,
	[StageName]  AS ([bhp].[fn_GetStageName]([fk_StageTypID])),
	[StrikeTempAmt] [numeric](12, 2) NOT NULL,
	[fk_StrikeTempUOM] [int] NOT NULL,
	[StrikeTempUOM]  AS ([bhp].[fn_GetUOM]([fk_StrikeTempUOM])),
	[BegTargetTempAmt] [numeric](12, 2) NOT NULL,
	[EndTargetTempAmt] [numeric](12, 2) NOT NULL,
	[fk_TargetTempsUOM] [int] NOT NULL,
	[TempUOM]  AS ([bhp].[fn_GetUOM]([fk_TargetTempsUOM])),
	[BegTimeAmt] [numeric](12, 2) NOT NULL,
	[EndTimeAmt] [numeric](12, 2) NOT NULL,
	[fk_TimeUOM] [int] NOT NULL,
	[TimeUOM]  AS ([bhp].[fn_GetUOM]([fk_TimeUOM])),
	[WaterAmt] [numeric](12, 2) NOT NULL,
	[fk_WaterUOM] [int] NOT NULL,
	[WaterUOM]  AS ([bhp].[fn_GetUOM]([fk_WaterUOM])),
	[GrainAmt] [numeric](12, 2) NOT NULL,
	[fk_GrainUOM] [int] NOT NULL,
	[GrainUOM]  AS ([bhp].[fn_GetUOM]([fk_GrainUOM])),
	[Comments] [nvarchar](4000) NULL,
 CONSTRAINT [PK_MashSchedDetails] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [bhp].[MashSchedMstr]    Script Date: 3/4/2020 10:40:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[MashSchedMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[fk_CreatedBy] [bigint] NOT NULL,
	[CreatedBy]  AS ([di].[fn_GetCustLoginNm]([fk_CreatedBy])),
	[fk_MashTypeID] [int] NOT NULL,
	[MashTypeNm]  AS ([bhp].[fn_GetMashTypName]([fk_MashTypeID])),
	[TotRecipies] [int] NULL,
	[WtrToGrainRatio] [numeric](3, 2) NOT NULL,
	[fk_WtrToGrainRatioUOM] [int] NOT NULL,
	[WtrToGrainRatioUOM]  AS ([bhp].[fn_GetUOM]([fk_WtrToGrainRatioUOM])),
	[fk_SpargeType] [int] NOT NULL,
	[SpargeType]  AS ([bhp].[fn_GetSpargeType]([fk_SpargeType])),
	[Comments] [nvarchar](4000) NULL,
	[isDfltForNu] [bit] NULL,
	[fk_DeployInfo] [int] NULL,
	[SharingMask] [int] NOT NULL,
	[SharingMaskAsCSV]  AS ([bhp].[fn_SharingTypesMaskToStr]([SharingMask])),
 CONSTRAINT [PK__MashSchedMstr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [bhp].[RecipeMashSchedBinder]    Script Date: 3/4/2020 10:40:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[RecipeMashSchedBinder](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_RecipeJrnlMstrID] [int] NOT NULL,
	[RecipeName]  AS ([bhp].[fn_GetRecipeName]([fk_recipeJrnlMstrID])),
	[fk_MashSchedMstrID] [int] NOT NULL,
	[MashSchedName]  AS ([bhp].[fn_GetMashSchedName]([fk_MashSchedMstrID])),
	[Comment] [nvarchar](2000) NULL,
 CONSTRAINT [PK__RecipeMashSchedBinder_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_MashSchedDtls_MstrIDStepNm]    Script Date: 3/4/2020 10:40:27 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_MashSchedDtls_MstrIDStepNm] ON [bhp].[MashSchedDetails]
(
	[fk_MashSchedMstrID] ASC,
	[StepName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_MashSchedMstr_Name]    Script Date: 3/4/2020 10:40:27 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_MashSchedMstr_Name] ON [bhp].[MashSchedMstr]
(
	[Name] ASC,
	[fk_DeployInfo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_StageTypID]  DEFAULT ((0)) FOR [fk_StageTypID]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_StrikeTempAmt]  DEFAULT ((0)) FOR [StrikeTempAmt]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_StrikeTempUOM]  DEFAULT ((0)) FOR [fk_StrikeTempUOM]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_BegTrgtTempAmt]  DEFAULT ((0)) FOR [BegTargetTempAmt]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_EndTrgtTempAmt]  DEFAULT ((0)) FOR [EndTargetTempAmt]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_TrgtTempsUOM]  DEFAULT ((0)) FOR [fk_TargetTempsUOM]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_BegTimeAmt]  DEFAULT ((0)) FOR [BegTimeAmt]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_EndTimeAmt]  DEFAULT ((0)) FOR [EndTimeAmt]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_TimeUOM]  DEFAULT ((0)) FOR [fk_TimeUOM]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_WaterAmt]  DEFAULT ((0)) FOR [WaterAmt]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_WaterUOM]  DEFAULT ((0)) FOR [fk_WaterUOM]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_GrainAmt]  DEFAULT ((0)) FOR [GrainAmt]
GO

ALTER TABLE [bhp].[MashSchedDetails] ADD  CONSTRAINT [DF__MashSchedDtls_GrainUOM]  DEFAULT ((0)) FOR [fk_GrainUOM]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF__MashSchedMstr_fk_MashType]  DEFAULT ((0)) FOR [fk_MashTypeID]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF__MashSchedMstr_TotRecipes]  DEFAULT ((0)) FOR [TotRecipies]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF_MashSchedMstr_WtrToGrainRatio]  DEFAULT ((1.5)) FOR [WtrToGrainRatio]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF_MashSchedMstr_fk_WtrToGrainRatioUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('qt/lb')) FOR [fk_WtrToGrainRatioUOM]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF__MashSchedMstr_Comments]  DEFAULT ('not set') FOR [Comments]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF_MashSchedMstr_IsDflt4Nu]  DEFAULT ((0)) FOR [isDfltForNu]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF_MashSchedMstr_DeployInfo]  DEFAULT ((0)) FOR [fk_DeployInfo]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF_MashSchedMstr_SharingMask]  DEFAULT ((0)) FOR [SharingMask]
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF_MashSchedMstr_fk_CreatedBy]  DEFAULT ((0)) FOR [fk_CreatedBy];
GO

ALTER TABLE [bhp].[MashSchedMstr] ADD  CONSTRAINT [DF_MashSchedMstr_fk_SpargeType]  DEFAULT ((0)) FOR [fk_SpargeType]
GO

ALTER TABLE [bhp].[MashSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedDtls_GrainUOM] FOREIGN KEY([fk_GrainUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedDetails] CHECK CONSTRAINT [FK_MashSchedDtls_GrainUOM]
GO

ALTER TABLE [bhp].[MashSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedDtls_MstrID] FOREIGN KEY([fk_MashSchedMstrID])
REFERENCES [bhp].[MashSchedMstr] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedDetails] CHECK CONSTRAINT [FK_MashSchedDtls_MstrID]
GO

ALTER TABLE [bhp].[MashSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedDtls_StageID] FOREIGN KEY([fk_StageTypID])
REFERENCES [bhp].[StageTypes] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedDetails] CHECK CONSTRAINT [FK_MashSchedDtls_StageID]
GO

ALTER TABLE [bhp].[MashSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedDtls_StrikeTempID] FOREIGN KEY([fk_StrikeTempUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedDetails] CHECK CONSTRAINT [FK_MashSchedDtls_StrikeTempID]
GO

ALTER TABLE [bhp].[MashSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedDtls_TargetTemps] FOREIGN KEY([fk_TargetTempsUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedDetails] CHECK CONSTRAINT [FK_MashSchedDtls_TargetTemps]
GO

ALTER TABLE [bhp].[MashSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedDtls_TimeID] FOREIGN KEY([fk_TimeUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedDetails] CHECK CONSTRAINT [FK_MashSchedDtls_TimeID]
GO

ALTER TABLE [bhp].[MashSchedDetails]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedDtls_WaterUOM] FOREIGN KEY([fk_WaterUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedDetails] CHECK CONSTRAINT [FK_MashSchedDtls_WaterUOM]
GO

ALTER TABLE [bhp].[MashSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedMstr_Fk_SpargeTypes] FOREIGN KEY([fk_SpargeType])
REFERENCES [bhp].[SpargeTypes] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedMstr] CHECK CONSTRAINT [FK_MashSchedMstr_Fk_SpargeTypes]
GO

ALTER TABLE [bhp].[MashSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedMstr_MashType] FOREIGN KEY([fk_MashTypeID])
REFERENCES [bhp].[MashTypeMstr] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedMstr] CHECK CONSTRAINT [FK_MashSchedMstr_MashType]
GO

ALTER TABLE [bhp].[MashSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedMstr_WtrToGrainRatioUOM] FOREIGN KEY([fk_WtrToGrainRatioUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[MashSchedMstr] CHECK CONSTRAINT [FK_MashSchedMstr_WtrToGrainRatioUOM]
GO

ALTER TABLE [bhp].[RecipeMashSchedBinder]  WITH CHECK ADD  CONSTRAINT [FK_RecipeMashSchedBinder_MashSchedID] FOREIGN KEY([fk_MashSchedMstrID])
REFERENCES [bhp].[MashSchedMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeMashSchedBinder] CHECK CONSTRAINT [FK_RecipeMashSchedBinder_MashSchedID]
GO

ALTER TABLE [bhp].[RecipeMashSchedBinder]  WITH CHECK ADD  CONSTRAINT [FK_RecipeMashSchedBinder_RecipeID] FOREIGN KEY([fk_RecipeJrnlMstrID])
REFERENCES [bhp].[RecipeJrnlMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeMashSchedBinder] CHECK CONSTRAINT [FK_RecipeMashSchedBinder_RecipeID]
GO

ALTER TABLE [bhp].[MashSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedMstr_DeployInfo] 
Foreign Key ([fk_DeployInfo]) REferences [di].[Deployments] (RowID);
GO

ALTER TABLE [bhp].[MashSchedMstr] CHECK CONSTRAINT [FK_MashSchedMstr_DeployInfo]
GO

ALTER TABLE [bhp].[MashSchedMstr]  WITH CHECK ADD  CONSTRAINT [FK_MashSchedMstr_CreatedBy] 
Foreign Key ([fk_CreatedBy]) References [di].[CustMstr] (RowID);
GO

ALTER TABLE [bhp].[MashSchedMstr] CHECK CONSTRAINT [FK_MashSchedMstr_CreatedBy]
GO

set identity_insert [bhp].[MashSchedMstr] on;
insert into [bhp].[MashSchedMstr](RowID, Name, Comments) Values (0,'pls select...','DO NOT REMOVE!!!');
set identity_insert [bhp].[MashSchedMstr] off;
go

set identity_Insert [bhp].[MashSchedDetails] On;
insert into [bhp].[MashSchedDetails](RowID,fk_MashSchedMstrID,StepName,[Pos],Comments)
values (0,0,'step - 0',0,N'DO NOT REMOVE!!!');
set identity_Insert [bhp].[MashSchedDetails] Off;
go

CREATE trigger [bhp].[MashSchedMstr_Del_99] on [bhp].[MashSchedMstr]
--with encryption
for delete
as
begin
	set rowcount 0;
	if exists (select * from deleted where rowid = 0)
	begin
		Raiserror('Mash Schedule Master record ''zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	end
end
GO

ALTER TABLE [bhp].[MashSchedMstr] ENABLE TRIGGER [MashSchedMstr_Del_99]
GO


/****** Object:  Trigger [bhp].[MashSchedDetails_Trig_Del_99]    Script Date: 3/4/2020 10:48:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashSchedDetails_Trig_Del_99] on [bhp].[MashSchedDetails]
--with encryption
for delete
as
begin
	If Exists (Select * from deleted where RowID = 0)
	Begin
		Raiserror('Mash Schedule Detail record ''zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
GO

ALTER TABLE [bhp].[MashSchedDetails] ENABLE TRIGGER [MashSchedDetails_Trig_Del_99]
GO

/****** Object:  Trigger [bhp].[MashSchedDetails_Trig_Ins_01]    Script Date: 3/4/2020 10:48:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashSchedDetails_Trig_Ins_01] on [bhp].[MashSchedDetails]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_StageTypID > 0)
		And (fk_StageTypID Not In (Select RowID from [bhp].StageTypes Where (AllowedInMashSched = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + [Name] From [bhp].StageTypes Where (AllowedInMashSched = 1);
		Raiserror('Mash Stage(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
GO

ALTER TABLE [bhp].[MashSchedDetails] ENABLE TRIGGER [MashSchedDetails_Trig_Ins_01]
GO

/****** Object:  Trigger [bhp].[MashSchedDetails_Trig_Ins_02]    Script Date: 3/4/2020 10:48:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashSchedDetails_Trig_Ins_02] on [bhp].[MashSchedDetails]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_TimeUOM > 0)
		And (fk_TimeUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsTimeMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + [Name] From [bhp].UOMTypes Where (AllowedAsTimeMeasure = 1);
		Raiserror('Mashing Time(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
GO

ALTER TABLE [bhp].[MashSchedDetails] ENABLE TRIGGER [MashSchedDetails_Trig_Ins_02]
GO

/****** Object:  Trigger [bhp].[MashSchedDetails_Trig_Ins_03]    Script Date: 3/4/2020 10:48:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashSchedDetails_Trig_Ins_03] on [bhp].[MashSchedDetails]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_TargetTempsUOM > 0)
		And (fk_TargetTempsUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsTemperature = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + [Name] From [bhp].UOMTypes Where (AllowedAsTemperature = 1);
		Raiserror('Mashing Temp(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
GO

ALTER TABLE [bhp].[MashSchedDetails] ENABLE TRIGGER [MashSchedDetails_Trig_Ins_03]
GO

/****** Object:  Trigger [bhp].[MashSchedDetails_Trig_Ins_04]    Script Date: 3/4/2020 10:48:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashSchedDetails_Trig_Ins_04] on [bhp].[MashSchedDetails]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_StrikeTempUOM > 0)
		And (fk_StrikeTempUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsTemperature = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + [Name] From [bhp].UOMTypes Where (AllowedAsTemperature = 1);
		Raiserror('Mashing Strike Temp(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback Transaction;
	End
end
GO

ALTER TABLE [bhp].[MashSchedDetails] ENABLE TRIGGER [MashSchedDetails_Trig_Ins_04]
GO

/****** Object:  Trigger [bhp].[MashSchedDetails_Trig_Ins_05]    Script Date: 3/4/2020 10:48:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashSchedDetails_Trig_Ins_05] on [bhp].[MashSchedDetails]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_WaterUOM > 0)
		And (fk_WaterUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Water Amount(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback Transaction;
	End
end
GO

ALTER TABLE [bhp].[MashSchedDetails] ENABLE TRIGGER [MashSchedDetails_Trig_Ins_05]
GO

/****** Object:  Trigger [bhp].[MashSchedDetails_Trig_Ins_06]    Script Date: 3/4/2020 10:48:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashSchedDetails_Trig_Ins_06] on [bhp].[MashSchedDetails]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_GrainUOM > 0)
		And (fk_GrainUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsWeightMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + [Name] From [bhp].UOMTypes Where (AllowedAsWeightMeasure = 1);
		Raiserror('Grain Amount(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback Transaction;
	End
end
GO

ALTER TABLE [bhp].[MashSchedDetails] ENABLE TRIGGER [MashSchedDetails_Trig_Ins_06]
GO

/****** Object:  Trigger [bhp].[RecipeMashSchedBinder_Trig_Del_1]    Script Date: 3/4/2020 10:51:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[RecipeMashSchedBinder_Trig_Del_1] on [bhp].[RecipeMashSchedBinder]
--with encryption
for delete
as
begin
	Update [bhp].MashSchedMstr
		Set TotRecipies = ((Case When TotRecipies is null Then 1 When TotRecipies = 0 Then 1 Else TotRecipies End)  - 1)
	From Inserted I Inner Join [bhp].MashSchedMstr C
	On (I.fk_RecipeJrnlMstrID = C.RowID)
	Where (I.fk_RecipeJrnlMstrID > 0);
end
GO

ALTER TABLE [bhp].[RecipeMashSchedBinder] ENABLE TRIGGER [RecipeMashSchedBinder_Trig_Del_1]
GO

/****** Object:  Trigger [bhp].[RecipeMashSchedBinder_Trig_Del_99]    Script Date: 3/4/2020 10:51:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[RecipeMashSchedBinder_Trig_Del_99] on [bhp].[RecipeMashSchedBinder]
--with encryption
for delete
as
begin
	If Exists (Select * from Deleted Where RowID = 0)
	Begin
		Raiserror('Recipe Mash Schedule Binder Entry ''zero'' can NOT be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
GO

--ALTER TABLE [bhp].[RecipeMashSchedBinder] DISABLE TRIGGER [RecipeMashSchedBinder_Trig_Del_99]
--GO

/****** Object:  Trigger [bhp].[RecipeMashSchedBinder_Trig_Ins_1]    Script Date: 3/4/2020 10:51:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[RecipeMashSchedBinder_Trig_Ins_1] on [bhp].[RecipeMashSchedBinder]
--with encryption
for insert
as
begin
	Update [bhp].MashSchedMstr
		Set TotRecipies = isnull(TotRecipies,0) + 1
	From Inserted I Inner Join [bhp].MashSchedMstr C
	On (I.fk_RecipeJrnlMstrID = C.RowID)
	Where (I.fk_RecipeJrnlMstrID > 0);
end 
GO

ALTER TABLE [bhp].[RecipeMashSchedBinder] ENABLE TRIGGER [RecipeMashSchedBinder_Trig_Ins_1]
GO



