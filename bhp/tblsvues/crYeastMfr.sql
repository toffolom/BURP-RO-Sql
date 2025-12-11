USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastManufs_VolDiscUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastManufacturers]'))
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [FK_YeastManufs_VolDiscUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastManuf_Fk_Country]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastManufacturers]'))
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [FK_YeastManuf_Fk_Country]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastManufacturers_Lang]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [DF_YeastManufacturers_Lang]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastManuf_EnteredBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [DF_YeastManuf_EnteredBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastManuf_EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [DF_YeastManuf_EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastManu_W3C]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [DF_YeastManu_W3C]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastManuf_Phylum]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [DF_YeastManuf_Phylum]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastManuf_MinOrderQty]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [DF_YeastManuf_MinOrderQty]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastManuf_VolDiscSz]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [DF_YeastManuf_VolDiscSz]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastManuf_fk_VolDiscUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastManufacturers] DROP CONSTRAINT [DF_YeastManuf_fk_VolDiscUOM]
END
GO

/****** Object:  Index [IDX_YeastMfrs_Name]    Script Date: 2/26/2020 12:34:22 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[YeastManufacturers]') AND name = N'IDX_YeastMfrs_Name')
DROP INDEX [IDX_YeastMfrs_Name] ON [bhp].[YeastManufacturers]
GO

/****** Object:  Table [bhp].[YeastManufacturers]    Script Date: 2/26/2020 12:34:22 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[YeastManufacturers]') AND type in (N'U'))
DROP TABLE [bhp].[YeastManufacturers]
GO

/****** Object:  Table [bhp].[YeastManufacturers]    Script Date: 2/26/2020 12:34:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[YeastManufacturers](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](300) NOT NULL,
	[fk_VolDiscUOM] [int] NULL,
	[VolDiscUOM]  AS ([bhp].[fn_GetUOM]([fk_VolDiscUOM])),
	[VolDiscSz] [numeric](18, 4) NULL,
	[MinOrderQty] [numeric](18, 4) NULL,
	[Phylum] [nvarchar](100) NULL,
	[W3C] [nvarchar](2000) NULL,
	[EnteredOn] [datetime] NULL,
	[EnteredBy] [sysname] NULL,
	[Lang] [varchar](50) NULL,
	[fk_Country] [int] NOT NULL,
 CONSTRAINT [PK__YeastManuf_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_YeastMfrs_Name]    Script Date: 2/26/2020 12:34:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_YeastMfrs_Name] ON [bhp].[YeastManufacturers]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManuf_fk_VolDiscUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('oz')) FOR [fk_VolDiscUOM]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManuf_VolDiscSz]  DEFAULT ((0.0)) FOR [VolDiscSz]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManuf_MinOrderQty]  DEFAULT ((0.0)) FOR [MinOrderQty]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManuf_Phylum]  DEFAULT ('not set') FOR [Phylum]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManu_W3C]  DEFAULT ('http://www.something.com') FOR [W3C]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManuf_EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManuf_EnteredBy]  DEFAULT (suser_sname()) FOR [EnteredBy]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManufacturers_Lang]  DEFAULT ('en_us') FOR [Lang]
GO

ALTER TABLE [bhp].[YeastManufacturers] ADD  CONSTRAINT [DF_YeastManufacturers_Country]  DEFAULT (0) FOR [fk_Country];
GO

ALTER TABLE [bhp].[YeastManufacturers]  WITH CHECK ADD  CONSTRAINT [FK_YeastManuf_Fk_Country] FOREIGN KEY([fk_Country])
REFERENCES [di].[Countries] ([RowID])
GO

ALTER TABLE [bhp].[YeastManufacturers] CHECK CONSTRAINT [FK_YeastManuf_Fk_Country]
GO

ALTER TABLE [bhp].[YeastManufacturers]  WITH CHECK ADD  CONSTRAINT [FK_YeastManufs_VolDiscUOM] FOREIGN KEY([fk_VolDiscUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[YeastManufacturers] CHECK CONSTRAINT [FK_YeastManufs_VolDiscUOM]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Trigger [bhp].[Trig_YeastManufacturers_Del_01]    Script Date: 2/26/2020 12:34:32 PM ******/
-- =============================================
-- Author:		mike
-- Create date: 25Aug2014
-- Description:	prevent deletion if row referenced within yeast master
-- =============================================
CREATE TRIGGER [bhp].[Trig_YeastManufacturers_Del_01] ON  [bhp].[YeastManufacturers] 
--with encryption
AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

    If Exists (Select * from [bhp].YeastMstr YM Inner Join deleted d On (YM.fk_YeastMfr = d.RowID))
	Begin
		Declare @Mesg nvarchar(2000);
		Exec [di].getI18NMsg @Nbr=66024, @Lang='en_us',@Msg = @Mesg Output;
		Raiserror(@Mesg, 16, 1);
		Rollback Transaction;
	End

END
GO

CREATE trigger [bhp].[YeastManufacturers_Trig_Del_99] on [bhp].[YeastManufacturers] 
--with encryption
for delete
as
begin
	if exists (select * from deleted where rowid = 0)
	begin
		raiserror('Yeast Manufacturer record ''zero'' cannot be removed...aborting!!!',16,1);
		rollback transaction;
	end
end
GO

set identity_insert [bhp].[YeastManufacturers] on;
insert into [bhp].[YeastManufacturers](RowID, Name) values (0, 'pls select...');
set identity_insert [bhp].[YeastManufacturers] off;
go
