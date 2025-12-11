USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamousWaterProfiles_isDfltForNu]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamousWaterProfiles_isDfltForNu]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamWtrProfile_Notes]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamWtrProfile_Notes]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamWtrProfile_PhUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamWtrProfile_PhUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamWtrProfile_BicarbonateUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamWtrProfile_BicarbonateUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamWtrProfile_ChlorideUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamWtrProfile_ChlorideUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamWtrProfile_SulfateUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamWtrProfile_SulfateUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamWtrProfile_SodiumUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamWtrProfile_SodiumUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamWtrProfile_MagnesiumUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamWtrProfile_MagnesiumUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_FamWtrProfile_CalciumUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[FamousWaterProfiles] DROP CONSTRAINT [DF_FamWtrProfile_CalciumUOM]
END
GO

/****** Object:  Table [bhp].[FamousWaterProfiles]    Script Date: 2/27/2020 12:07:45 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[FamousWaterProfiles]') AND type in (N'U'))
DROP TABLE [bhp].[FamousWaterProfiles]
GO

/****** Object:  Table [bhp].[FamousWaterProfiles]    Script Date: 2/27/2020 12:07:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[FamousWaterProfiles](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NULL,
	[Country_State] [varchar](100) NULL,
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
	[Ph] [numeric](4, 1) NULL,
	[fk_PhUOM] [int] NULL,
	[PhUOM]  AS ([bhp].[fn_GetUOM]([fk_PhUOM])),
	[Notes] [nvarchar](1000) NULL,
	[isDfltForNu] [bit] NULL,
 CONSTRAINT [PK_FamousWaterProfiles_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[FamousWaterProfiles] ADD  CONSTRAINT [DF_FamWtrProfile_Fk_CalciumUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_CalciumUOM]
GO

ALTER TABLE [bhp].[FamousWaterProfiles] ADD  CONSTRAINT [DF_FamWtrProfile_Fk_MagnesiumUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_MagnesiumUOM]
GO

ALTER TABLE [bhp].[FamousWaterProfiles] ADD  CONSTRAINT [DF_FamWtrProfile_Fk_SodiumUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_SodiumUOM]
GO

ALTER TABLE [bhp].[FamousWaterProfiles] ADD  CONSTRAINT [DF_FamWtrProfile_Fk_SulfateUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_SulfateUOM]
GO

ALTER TABLE [bhp].[FamousWaterProfiles] ADD  CONSTRAINT [DF_FamWtrProfile_Fk_ChlorideUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_ChlorideUOM]
GO

ALTER TABLE [bhp].[FamousWaterProfiles] ADD  CONSTRAINT [DF_FamWtrProfile_Fk_BicarbonateUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ppm')) FOR [fk_BicarbonateUOM]
GO

ALTER TABLE [bhp].[FamousWaterProfiles] ADD  CONSTRAINT [DF_FamWtrProfile_Fk_PhUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('ph')) FOR [fk_PhUOM]
GO

ALTER TABLE [bhp].[FamousWaterProfiles] ADD  CONSTRAINT [DF_FamWtrProfile_Notes]  DEFAULT (N'<Notes><Note nbr=''1''>pls add note...</Note></Notes>') FOR [Notes]
GO

alter table bhp.FamousWaterProfiles add
	Constraint FK_FamousWtrProfs_FkCalcium Foreign Key ([fk_CalciumUOM])
		References bhp.UOMTypes (RowID),
	Constraint FK_FamousWtrProfs_FkMagnesium Foreign Key (Fk_MagnesiumUOM)
		References bhp.UOMTypes (RowID),
	Constraint FK_FamousWtrProfs_FkSodium Foreign Key (Fk_SodiumUOM)
		References bhp.UOMTypes (RowID),
	Constraint FK_FamousWtrProfs_FkSulfate Foreign Key (Fk_SulfateUOM)
		References bhp.UOMTypes (RowID),
	Constraint FK_FamousWtrProfs_FkChloride Foreign Key (Fk_ChlorideUOM)
		References bhp.UOMTypes (RowID),
	Constraint FK_FamousWtrProfs_FkBicarb Foreign Key (Fk_BicarbonateUOM)
		References bhp.UOMTypes (RowID),
	Constraint FK_FamousWtrProfs_FkPh Foreign Key (Fk_PhUOM)
		References bhp.UOMTypes (RowID)
go

ALTER TABLE [bhp].[FamousWaterProfiles] ADD
CONSTRAINT [DF_FamousWaterProfiles_isDfltForNu]  DEFAULT ((0)) FOR [isDfltForNu],
CONSTRAINT [DF_FamousWaterProfiles_Calcium]  DEFAULT ((0)) FOR [Calcium],
CONSTRAINT [DF_FamousWaterProfiles_Magnesium]  DEFAULT ((0)) FOR [Magnesium],
CONSTRAINT [DF_FamousWaterProfiles_Sodium]  DEFAULT ((0)) FOR [Sodium],
CONSTRAINT [DF_FamousWaterProfiles_Sulfate]  DEFAULT ((0)) FOR [Sulfate],
CONSTRAINT [DF_FamousWaterProfiles_Chloride]  DEFAULT ((0)) FOR [Chloride],
CONSTRAINT [DF_FamousWaterProfiles_Bicarbonate]  DEFAULT ((0)) FOR [Bicarbonate],
CONSTRAINT [DF_FamousWaterProfiles_Ph]  DEFAULT ((0)) FOR [Ph];
go

set identity_Insert [bhp].[FamousWaterProfiles] on;
insert into [bhp].[FamousWaterProfiles](RowID,[Name],[Country_State],Notes)
values (0,'pls select...','not set',N'DO NOT REMOVE!!!');
set identity_Insert [bhp].[FamousWaterProfiles] off;
go

Create Trigger [bhp].[FamousWtrProfile_Del_99] on [bhp].[FamousWaterProfiles]
--with encryption
after delete
as
begin
	If Exists (Select * from deleted where RowID = 0)
	Begin
		Raiserror(N'Row ''Zero'' cannot be removed!!!',16,1);
		Rollback Transaction;
	End
end