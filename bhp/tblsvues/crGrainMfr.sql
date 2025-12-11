USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_GrainManufs_VolDiscUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[GrainManufacturers]'))
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [FK_GrainManufs_VolDiscUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_GrainManuf_MinPkgSzUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[GrainManufacturers]'))
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [FK_GrainManuf_MinPkgSzUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_GrainManuf_Fk_Country]') AND parent_object_id = OBJECT_ID(N'[bhp].[GrainManufacturers]'))
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [FK_GrainManuf_Fk_Country]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_GrainManuf_Fk_MinPkgSz]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [DF_GrainManuf_Fk_MinPkgSz]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_GrainManuf_MinPkgSz]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [DF_GrainManuf_MinPkgSz]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainManuf__EnteredBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [DF__GrainManuf__EnteredBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainManuf__EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [DF__GrainManuf__EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_GrainManufacturers_W3C]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [DF_GrainManufacturers_W3C]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainManuf__MinOrdQty]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [DF__GrainManuf__MinOrdQty]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainManuf__VolDiscSz]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [DF__GrainManuf__VolDiscSz]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainManuf__fk_VolDiscUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainManufacturers] DROP CONSTRAINT [DF__GrainManuf__fk_VolDiscUOM]
END
GO

/****** Object:  Index [IDX_GrainMfrs_Name]    Script Date: 2/26/2020 9:16:21 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[GrainManufacturers]') AND name = N'IDX_GrainMfrs_Name')
DROP INDEX [IDX_GrainMfrs_Name] ON [bhp].[GrainManufacturers]
GO

/****** Object:  Table [bhp].[GrainManufacturers]    Script Date: 2/26/2020 9:16:21 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[GrainManufacturers]') AND type in (N'U'))
DROP TABLE [bhp].[GrainManufacturers]
GO

/****** Object:  Table [bhp].[GrainManufacturers]    Script Date: 2/26/2020 9:16:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[GrainManufacturers](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](300) NOT NULL,
	[fk_VolDiscUOM] [int] NULL,
	[VolDiscSz] [numeric](18, 4) NULL,
	[MinOrderQty] [numeric](18, 4) NULL,
	[W3C] [nvarchar](2000) NULL,
	[EnteredOn] [datetime] NULL,
	[EnteredBy] [sysname] NULL,
	[Lang] [nvarchar](20) NULL,
	[fk_Country] [int] NOT NULL,
	[MinPkgingSize] [numeric](10, 4) NULL,
	[fk_MinPkgingSizeUOM] [int] NULL,
 CONSTRAINT [PK__GrainManuf_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_GrainMfrs_Name]    Script Date: 2/26/2020 9:16:21 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_GrainMfrs_Name] ON [bhp].[GrainManufacturers]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF__GrainManuf__fk_VolDiscUOM]  DEFAULT ((0)) FOR [fk_VolDiscUOM]
GO

ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF__GrainManuf__VolDiscSz]  DEFAULT ((0.0)) FOR [VolDiscSz]
GO

ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF__GrainManuf__MinOrdQty]  DEFAULT ((0.0)) FOR [MinOrderQty]
GO

ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF_GrainManufacturers_W3C]  DEFAULT (N'http://www.something.com') FOR [W3C]
GO

ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF__GrainManuf__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF__GrainManuf__EnteredBy]  DEFAULT (suser_sname()) FOR [EnteredBy]
GO

ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF_GrainManuf_MinPkgSz]  DEFAULT ((0)) FOR [MinPkgingSize]
GO

ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF_GrainManuf_Fk_MinPkgSz]  DEFAULT ((0)) FOR [fk_MinPkgingSizeUOM]
GO

ALTER TABLE [bhp].[GrainManufacturers] ADD  CONSTRAINT [DF_GrainManuf_Fk_Country]  DEFAULT ((0)) FOR [fk_Country]
GO

ALTER TABLE [bhp].[GrainManufacturers]  WITH CHECK ADD  CONSTRAINT [FK_GrainManuf_Fk_Country] FOREIGN KEY([fk_Country])
REFERENCES [di].[Countries] ([RowID])
GO

ALTER TABLE [bhp].[GrainManufacturers] CHECK CONSTRAINT [FK_GrainManuf_Fk_Country]
GO

ALTER TABLE [bhp].[GrainManufacturers]  WITH CHECK ADD  CONSTRAINT [FK_GrainManuf_MinPkgSzUOM] FOREIGN KEY([fk_MinPkgingSizeUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[GrainManufacturers] CHECK CONSTRAINT [FK_GrainManuf_MinPkgSzUOM]
GO

ALTER TABLE [bhp].[GrainManufacturers]  WITH CHECK ADD  CONSTRAINT [FK_GrainManufs_VolDiscUOM] FOREIGN KEY([fk_VolDiscUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[GrainManufacturers] CHECK CONSTRAINT [FK_GrainManufs_VolDiscUOM]
GO

/****** Object:  Trigger [bhp].[GrainManufacturers_Trig_Del_01]    Script Date: 2/26/2020 9:16:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create trigger [bhp].[GrainManufacturers_Trig_Del_01] on [bhp].[GrainManufacturers] 
with encryption
for delete
as
begin
	if exists (select * from [bhp].GrainMstr GM Inner Join deleted d On (GM.fk_GrainMfr = d.RowID))
	begin
		raiserror('Grain Manufacturer has Grains defined in system.  Request to remove aborted!!!',16,1);
		rollback transaction;
	end
end
GO

CREATE trigger [bhp].[GrainManufacturers_Trig_Del_99] on [bhp].[GrainManufacturers] 
with encryption
for delete
as
begin
	if exists (select * from deleted where rowid = 0)
	begin
		raiserror('Grain Manufacturer record ''zero'' cannot be removed...aborting!!!',16,1);
		rollback transaction;
	end
end
GO

set identity_insert [bhp].GrainManufacturers on;
insert into [bhp].[GrainManufacturers] (RowID, Name) Values(0,'pls select...');
set identity_insert [bhp].GrainManufacturers off;
go

