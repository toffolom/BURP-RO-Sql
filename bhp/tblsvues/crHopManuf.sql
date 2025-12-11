USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopManufs_VolDiscUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopManufacturers]'))
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [FK_HopManufs_VolDiscUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_HopManuf_Fk_Countries]') AND parent_object_id = OBJECT_ID(N'[bhp].[HopManufacturers]'))
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [FK_HopManuf_Fk_Countries]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopMfrs_Lang]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [DF_HopMfrs_Lang]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopMfr_EnteredBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [DF_HopMfr_EnteredBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopMfr_EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [DF_HopMfr_EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopMfr_W3C]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [DF_HopMfr_W3C]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopMfr_MinOrderQty]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [DF_HopMfr_MinOrderQty]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopMfr_VolDiscSz]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [DF_HopMfr_VolDiscSz]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_HopMfr_FK_VolDiscUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[HopManufacturers] DROP CONSTRAINT [DF_HopMfr_FK_VolDiscUOM]
END
GO

/****** Object:  Table [bhp].[HopManufacturers]    Script Date: 2/27/2020 1:31:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[HopManufacturers]') AND type in (N'U'))
DROP TABLE [bhp].[HopManufacturers]
GO

/****** Object:  Table [bhp].[HopManufacturers]    Script Date: 2/27/2020 1:31:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[HopManufacturers](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](300) NOT NULL,
	[fk_VolDiscUOM] [int] NULL,
	[UOMDescr]  AS ([bhp].[fn_GetUOM]([fk_VolDiscUOM])),
	[VolDiscSz] [numeric](18, 4) NULL,
	[MinOrderQty] [numeric](18, 4) NULL,
	[W3C] [nvarchar](2000) NULL,
	[EnteredOn] [datetime] NULL,
	[EnteredBy] [sysname] NULL,
	[Lang] [nvarchar](20) NULL,
	[fk_Country] [int] NOT NULL,
 CONSTRAINT [PK_HopMfr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[HopManufacturers] ADD  CONSTRAINT [DF_HopMfr_FK_VolDiscUOM]  DEFAULT ((0)) FOR [fk_VolDiscUOM]
GO

ALTER TABLE [bhp].[HopManufacturers] ADD  CONSTRAINT [DF_HopMfr_VolDiscSz]  DEFAULT ((0.0)) FOR [VolDiscSz]
GO

ALTER TABLE [bhp].[HopManufacturers] ADD  CONSTRAINT [DF_HopMfr_MinOrderQty]  DEFAULT ((0.0)) FOR [MinOrderQty]
GO

ALTER TABLE [bhp].[HopManufacturers] ADD  CONSTRAINT [DF_HopMfr_W3C]  DEFAULT (N'http://www.something.com') FOR [W3C]
GO

ALTER TABLE [bhp].[HopManufacturers] ADD  CONSTRAINT [DF_HopMfr_EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[HopManufacturers] ADD  CONSTRAINT [DF_HopMfr_EnteredBy]  DEFAULT (suser_sname()) FOR [EnteredBy]
GO

ALTER TABLE [bhp].[HopManufacturers] ADD  CONSTRAINT [DF_HopMfrs_Lang]  DEFAULT ('en_us') FOR [Lang]
GO

ALTER TABLE [bhp].[HopManufacturers] ADD  CONSTRAINT [DF_HopMfrs_Fk_Country]  DEFAULT (0) FOR [fk_Country];
GO

ALTER TABLE [bhp].[HopManufacturers]  WITH CHECK ADD  CONSTRAINT [FK_HopManuf_Fk_Countries] FOREIGN KEY([fk_Country])
REFERENCES [di].[Countries] ([RowID])
GO

ALTER TABLE [bhp].[HopManufacturers] CHECK CONSTRAINT [FK_HopManuf_Fk_Countries]
GO

ALTER TABLE [bhp].[HopManufacturers]  WITH CHECK ADD  CONSTRAINT [FK_HopManufs_VolDiscUOM] FOREIGN KEY([fk_VolDiscUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[HopManufacturers] CHECK CONSTRAINT [FK_HopManufs_VolDiscUOM]
GO

/****** Object:  Trigger [bhp].[HopManufacturers_Trig_Del_99]    Script Date: 2/27/2020 1:32:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[HopManufacturers_Trig_Del_99] on [bhp].[HopManufacturers] 
--with encryption
for delete
as
begin
	if exists (select * from deleted where rowid = 0)
	begin
		raiserror('Hop Manufacturer record ''zero'' cannot be removed...aborting!!!',16,1);
		if (xact_state() = 1) rollback transaction;
	end
end
GO

set identity_insert [bhp].[HopManufacturers] on;
insert into [bhp].[HopManufacturers] (RowID, Name) Values (0,'pls select...');
set identity_insert [bhp].[HopManufacturers] off;



