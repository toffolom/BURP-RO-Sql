USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_REcipeWaterProfile_fk_RecipeID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeWaterProfile]'))
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [FK_REcipeWaterProfile_fk_RecipeID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeWaterPRofile_fk_InitFamousWtrProfID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeWaterProfile]'))
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [FK_RecipeWaterPRofile_fk_InitFamousWtrProfID]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeWaterProfile_LoadedFromID]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [DF_RecipeWaterProfile_LoadedFromID]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeWtrProfile_PhUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [DF_RecipeWtrProfile_PhUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeWtrProfile_BicarbonateUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [DF_RecipeWtrProfile_BicarbonateUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeWtrProfile_ChlorideUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [DF_RecipeWtrProfile_ChlorideUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeWtrProfile_SulfateUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [DF_RecipeWtrProfile_SulfateUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeWtrProfile_SodiumUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [DF_RecipeWtrProfile_SodiumUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeWtrProfile_MagnesiumUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [DF_RecipeWtrProfile_MagnesiumUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_RecipeWtrProfile_CalciumUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[RecipeWaterProfile] DROP CONSTRAINT [DF_RecipeWtrProfile_CalciumUOM]
END
GO

/****** Object:  Index [IDX_RecipeWaterProfile_RecipeID]    Script Date: 3/4/2020 2:41:00 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[RecipeWaterProfile]') AND name = N'IDX_RecipeWaterProfile_RecipeID')
DROP INDEX [IDX_RecipeWaterProfile_RecipeID] ON [bhp].[RecipeWaterProfile]
GO

/****** Object:  Table [bhp].[RecipeWaterProfile]    Script Date: 3/4/2020 2:41:00 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeWaterProfile]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeWaterProfile]
GO

/****** Object:  Table [bhp].[RecipeWaterProfile]    Script Date: 3/4/2020 2:41:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[RecipeWaterProfile](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[fk_RecipeJrnlMstrID] [int] NULL,
	[Calcium] [numeric](4, 1) NULL,
	[fk_CalciumUOM] [int] NULL,
	[CalcUOM]  AS ([bhp].[fn_GetUOM]([fk_CalciumUOM])),
	[Magnesium] [numeric](4, 1) NULL,
	[fk_MagnesiumUOM] [int] NULL,
	[MagUOM]  AS ([bhp].[fn_GetUOM]([fk_MagnesiumUOM])),
	[Sodium] [numeric](4, 1) NULL,
	[fk_SodiumUOM] [int] NULL,
	[SodUOM]  AS ([bhp].[fn_GetUOM]([fk_SodiumUOM])),
	[Sulfate] [numeric](4, 1) NULL,
	[fk_SulfateUOM] [int] NULL,
	[SulfUOM]  AS ([bhp].[fn_GetUOM]([fk_SulfateUOM])),
	[Chloride] [numeric](4, 1) NULL,
	[fk_ChlorideUOM] [int] NULL,
	[ChlorUOM]  AS ([bhp].[fn_GetUOM]([fk_ChlorideUOM])),
	[Bicarbonate] [numeric](4, 1) NULL,
	[fk_BicarbonateUOM] [int] NULL,
	[BicarUOM]  AS ([bhp].[fn_GetUOM]([fk_BicarbonateUOM])),
	[Ph] [numeric](3, 1) NULL,
	[fk_PhUOM] [int] NULL,
	[PhUOM]  AS ([bhp].[fn_GetUOM]([fk_PhUOM])),
	[fk_InitilizedByFamousWtrID] [int] NULL,
	[FromProfileNm]  AS ([bhp].[fn_GetFamousWtrProfNm]([fk_InitilizedByFamousWtrID])),
	[Comments] [nvarchar](2000) NULL,
 CONSTRAINT [PK_RecipeWaterProfile_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RecipeWaterProfile_RecipeID]    Script Date: 3/4/2020 2:41:00 PM ******/
CREATE NONCLUSTERED INDEX [IDX_RecipeWaterProfile_RecipeID] ON [bhp].[RecipeWaterProfile]
(
	[fk_RecipeJrnlMstrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[RecipeWaterProfile] ADD  CONSTRAINT [DF_RecipeWtrProfile_CalciumUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_CalciumUOM]
GO

ALTER TABLE [bhp].[RecipeWaterProfile] ADD  CONSTRAINT [DF_RecipeWtrProfile_MagnesiumUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_MagnesiumUOM]
GO

ALTER TABLE [bhp].[RecipeWaterProfile] ADD  CONSTRAINT [DF_RecipeWtrProfile_SodiumUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_SodiumUOM]
GO

ALTER TABLE [bhp].[RecipeWaterProfile] ADD  CONSTRAINT [DF_RecipeWtrProfile_SulfateUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_SulfateUOM]
GO

ALTER TABLE [bhp].[RecipeWaterProfile] ADD  CONSTRAINT [DF_RecipeWtrProfile_ChlorideUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_ChlorideUOM]
GO

ALTER TABLE [bhp].[RecipeWaterProfile] ADD  CONSTRAINT [DF_RecipeWtrProfile_BicarbonateUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_BicarbonateUOM]
GO

ALTER TABLE [bhp].[RecipeWaterProfile] ADD  CONSTRAINT [DF_RecipeWtrProfile_PhUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ph')) FOR [fk_PhUOM]
GO

ALTER TABLE [bhp].[RecipeWaterProfile] ADD  CONSTRAINT [DF_RecipeWaterProfile_LoadedFromID]  DEFAULT ((0)) FOR [fk_InitilizedByFamousWtrID]
GO

ALTER TABLE [bhp].[RecipeWaterProfile]  WITH CHECK ADD  CONSTRAINT [FK_RecipeWaterPRofile_fk_InitFamousWtrProfID] FOREIGN KEY([fk_InitilizedByFamousWtrID])
REFERENCES [bhp].[FamousWaterProfiles] ([RowID])
GO

ALTER TABLE [bhp].[RecipeWaterProfile] CHECK CONSTRAINT [FK_RecipeWaterPRofile_fk_InitFamousWtrProfID]
GO

ALTER TABLE [bhp].[RecipeWaterProfile]  WITH CHECK ADD  CONSTRAINT [FK_REcipeWaterProfile_fk_RecipeID] FOREIGN KEY([fk_RecipeJrnlMstrID])
REFERENCES [bhp].[RecipeJrnlMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeWaterProfile] CHECK CONSTRAINT [FK_REcipeWaterProfile_fk_RecipeID]
GO


/****** Object:  Trigger [bhp].[RecipeWaterProfile_Ins_01]    Script Date: 3/4/2020 2:41:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create Trigger [bhp].[RecipeWaterProfile_Ins_01] on [bhp].[RecipeWaterProfile]
--with encryption
for insert
as
begin
	if exists (select * from inserted where fk_InitilizedByFamousWtrID > 0)
	Begin
		Update [bhp].RecipeWaterProfile
			Set 
				Calcium = p.Calcium,
				fk_CalciumUOM = p.fk_CalciumUOM,
				Magnesium = p.Magnesium,
				fk_MagnesiumUOM = p.fk_MagnesiumUOM,
				Sodium = p.Sodium,
				fk_SodiumUOM = p.fk_SodiumUOM,
				Sulfate = p.Sulfate,
				fk_SulfateUOM = p.fk_SulfateUOM,
				Chloride = p.Chloride,
				fk_ChlorideUOM = p.fk_ChlorideUOM,
				Bicarbonate = p.Bicarbonate,
				fk_BicarbonateUOM = p.fk_BicarbonateUOM,
				Ph = p.Ph,
				fk_PhUOM = p.fk_PhUOM,
				Comments = ISNULL(i.Comments, N'profile initialized from famous profile:['+p.Name+']...')
		From inserted i inner join [bhp].FamousWaterProfiles p on (i.fk_InitilizedByFamousWtrID = p.RowID);
	End
end
GO

ALTER TABLE [bhp].[RecipeWaterProfile] DISABLE TRIGGER [RecipeWaterProfile_Ins_01]
GO

