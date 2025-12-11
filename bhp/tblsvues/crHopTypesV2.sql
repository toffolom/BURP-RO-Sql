USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypeV2_PSub5]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypeV2_PSub5]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypeV2_PSub4]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypeV2_PSub4]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypeV2_PSub3]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypeV2_PSub3]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypeV2_PSub2]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypeV2_PSub2]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypeV2_PSub1]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypeV2_PSub1]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypeV2_HopMfrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypeV2_HopMfrID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypeV2_CostUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypeV2_CostUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypesV2_Fk_HopPurposeTypes]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypesV2_Fk_HopPurposeTypes]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopTypesV2_Fk_CountryID]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopTypesV2]'))
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [FK_HopTypesV2_Fk_CountryID]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_Fk_HopPurposeID_Zero]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_Fk_HopPurposeID_Zero]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2__EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2__EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_PSub5]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_PSub5]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_PSub4]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_PSub4]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_PSub3]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_PSub3]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_PSub2]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_PSub2]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_PSub1]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_PSub1]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_RowSize]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_RowSize]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_RecipeCnt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_RecipeCnt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_Lang]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_Lang]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_fk_OpCostUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_fk_OpCostUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_IBU]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_IBU]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_IsHomeGrwn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_IsHomeGrwn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_isExtract]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_isExtract]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_isOil]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_isOil]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_IsFlower]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_IsFlower]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_IsPellet]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_IsPellet]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_BetaAcidHigh]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_BetaAcidHigh]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_BetaAcidLow]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_BetaAcidLow]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_AlphaAcidHigh]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_AlphaAcidHigh]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_AlphaAcidLow]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_AlphaAcidLow]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopTypesV2_Fk_HopMfrID]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopTypesV2] DROP CONSTRAINT [DF_HopTypesV2_Fk_HopMfrID]
END
GO

/****** Object:  Index [IDX_HopTypesV2_Name]    Script Date: 2/27/2020 1:42:40 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[HopTypesV2]') AND name = N'IDX_HopTypesV2_Name')
DROP INDEX [IDX_HopTypesV2_Name] ON [bhp].[HopTypesV2] WITH ( ONLINE = OFF )
GO

/****** Object:  Table [bhp].[HopTypesV2]    Script Date: 2/27/2020 1:42:40 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[HopTypesV2]') AND type in (N'U'))
DROP TABLE [bhp].[HopTypesV2]
GO

/****** Object:  Table [bhp].[HopTypesV2]    Script Date: 2/27/2020 1:42:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[HopTypesV2](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[AKA] [nvarchar](100) NULL,
	[fk_HopMfrID] [int] NULL,
	[HopMfrNm]  AS ([bhp].[fn_HopMfrNm]([fk_HopMfrID])),
	[AlphaAcidLow] [numeric](5, 2) NULL,
	[AlphaAcidHigh] [numeric](5, 2) NULL,
	[BetaAcidLow] [numeric](5, 2) NULL,
	[BetaAcidHigh] [numeric](5, 2) NULL,
	[Pellet] [bit] NULL,
	[Flower] [bit] NULL,
	[isOil] [bit] NULL,
	[isExtract] [bit] NULL,
	[HomeGrwn] [bit] NULL,
	[IBU] [numeric](5, 2) NULL,
	[OpCost] [money] NULL,
	[fk_OpCostUOM] [int] NULL,
	[OpCostUOM]  AS ([bhp].[fn_getUOM]([fk_opCostUOM])),
	[Lang] [nvarchar](20) NULL,
	[Commentary] [nvarchar](2000) NULL,
	[NbrOfRecipesUsedIn] [int] NULL,
	[RowSz] [int] NULL,
	[PSub1] [int] NULL,
	[PSub1Nm]  AS ([bhp].[fn_GetHopNameV2]([PSub1])),
	[PSub2] [int] NULL,
	[PSub2Nm]  AS ([bhp].[fn_GetHopNameV2]([PSub2])),
	[PSub3] [int] NULL,
	[PSub3Nm]  AS ([bhp].[fn_GetHopNameV2]([PSub3])),
	[PSub4] [int] NULL,
	[PSub4Nm]  AS ([bhp].[fn_GetHopNameV2]([PSub4])),
	[PSub5] [int] NULL,
	[PSub5Nm]  AS ([bhp].[fn_GetHopNameV2]([PSub5])),
	[EnteredOn] [datetime] NULL,
	[fk_CountryID] [int] NULL,
	[CountryOfOrigin]  AS ([bhp].[fn_GetCountryNm]([fk_CountryID])),
	[fk_HopPurposeID] [tinyint] NULL,
	[HopPurpose]  AS ([bhp].[fn_GetHopPurposeStr]([fk_HopPurposeID])),
 CONSTRAINT [PK__HopTypesV2_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_HopTypesV2_Name]    Script Date: 2/27/2020 1:42:40 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IDX_HopTypesV2_Name] ON [bhp].[HopTypesV2]
(
	[Name] ASC,
	[fk_HopMfrID] ASC,
	[fk_HopPurposeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_Fk_HopMfrID]  DEFAULT ((0)) FOR [fk_HopMfrID]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_AlphaAcidLow]  DEFAULT ((0.0)) FOR [AlphaAcidLow]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_AlphaAcidHigh]  DEFAULT ((0.0)) FOR [AlphaAcidHigh]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_BetaAcidLow]  DEFAULT ((0.0)) FOR [BetaAcidLow]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_BetaAcidHigh]  DEFAULT ((0.0)) FOR [BetaAcidHigh]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_IsPellet]  DEFAULT ((0)) FOR [Pellet]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_IsFlower]  DEFAULT ((0)) FOR [Flower]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_isOil]  DEFAULT ((0)) FOR [isOil]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_isExtract]  DEFAULT ((0)) FOR [isExtract]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_IsHomeGrwn]  DEFAULT ((0)) FOR [HomeGrwn]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_IBU]  DEFAULT ((0)) FOR [IBU]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_fk_OpCostUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('$')) FOR [fk_OpCostUOM]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_OpCost]  DEFAULT ((0.00)) FOR [OpCost]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_Lang]  DEFAULT ('en_us') FOR [Lang]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_RecipeCnt]  DEFAULT ((0)) FOR [NbrOfRecipesUsedIn]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_RowSize]  DEFAULT ((2)) FOR [RowSz]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_PSub1]  DEFAULT ((0)) FOR [PSub1]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_PSub2]  DEFAULT ((0)) FOR [PSub2]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_PSub3]  DEFAULT ((0)) FOR [PSub3]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_PSub4]  DEFAULT ((0)) FOR [PSub4]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_PSub5]  DEFAULT ((0)) FOR [PSub5]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_Fk_HopPurposeID_Zero]  DEFAULT ((0)) FOR [fk_HopPurposeID]
GO

ALTER TABLE [bhp].[HopTypesV2] ADD  CONSTRAINT [DF_HopTypesV2_Fk_Country]  DEFAULT ((0)) FOR [fk_CountryID]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypesV2_Fk_CountryID] FOREIGN KEY([fk_CountryID])
REFERENCES [di].[Countries] ([RowID])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypesV2_Fk_CountryID]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypesV2_Fk_HopPurposeTypes] FOREIGN KEY([fk_HopPurposeID])
REFERENCES [bhp].[HopPurposeTypes] ([BitVal])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypesV2_Fk_HopPurposeTypes]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypeV2_CostUOM] FOREIGN KEY([fk_OpCostUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypeV2_CostUOM]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypeV2_HopMfrID] FOREIGN KEY([fk_HopMfrID])
REFERENCES [bhp].[HopManufacturers] ([RowID])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypeV2_HopMfrID]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypeV2_PSub1] FOREIGN KEY([PSub1])
REFERENCES [bhp].[HopTypesV2] ([RowID])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypeV2_PSub1]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypeV2_PSub2] FOREIGN KEY([PSub2])
REFERENCES [bhp].[HopTypesV2] ([RowID])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypeV2_PSub2]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypeV2_PSub3] FOREIGN KEY([PSub3])
REFERENCES [bhp].[HopTypesV2] ([RowID])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypeV2_PSub3]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypeV2_PSub4] FOREIGN KEY([PSub4])
REFERENCES [bhp].[HopTypesV2] ([RowID])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypeV2_PSub4]
GO

ALTER TABLE [bhp].[HopTypesV2]  WITH CHECK ADD  CONSTRAINT [FK_HopTypeV2_PSub5] FOREIGN KEY([PSub5])
REFERENCES [bhp].[HopTypesV2] ([RowID])
GO

ALTER TABLE [bhp].[HopTypesV2] CHECK CONSTRAINT [FK_HopTypeV2_PSub5]
GO

/****** Object:  Trigger [bhp].[HopTypesV2_Del_Trig_1]    Script Date: 2/27/2020 1:42:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [bhp].[HopTypesV2_Del_Trig_1] on [bhp].[HopTypesV2]
--with encryption
for delete
as
Begin
	If Exists (Select * from Deleted where rowid = 0)
	Begin
		Raiserror('Row ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
End
GO

create trigger [bhp].[HopTypesV2_Trig_Ins_01] on [bhp].[HopTypesV2] 
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_OpCostUOM > 0)
		And (fk_OpCostUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsMonetary = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + Name from [bhp].UOMTypes Where (AllowedAsMonetary = 1);
		Raiserror('Cost can only be described using:[%s]...aborting!!!',16,1,@Buff);
		Rollback Transaction;
	End
end
GO

create trigger [bhp].[HopTypesV2_Trig_Upd_01] on [bhp].[HopTypesV2] 
--with encryption
for update
as
begin
	If Update(fk_OpCostUOM)
	Begin
		If Exists (Select * from Inserted I Where (fk_OpCostUOM > 0)
			And (fk_OpCostUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsMonetary = 1))))
		Begin
			Declare @buff varchar(2000);
			Select @buff = isnull(@buff + ',',SPACE(0)) + Name from [bhp].UOMTypes Where (AllowedAsMonetary = 1);
			Raiserror('Cost can only be described using:[%s]...aborting!!!',16,1,@Buff);
			Rollback Transaction;
		End
	End
end
GO

set identity_Insert [bhp].[HopTypesV2] on;
insert into [bhp].[HopTypesV2](RowID,Name,Commentary) values(0,'pls select...','DO NOT REMOVE!!!');
set identity_Insert [bhp].[HopTypesV2] off;
go
