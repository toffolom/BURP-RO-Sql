USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainType_EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainTypes] DROP CONSTRAINT [DF__GrainType_EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainType_EnteredBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainTypes] DROP CONSTRAINT [DF__GrainType_EnteredBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainTypes_Lang]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainTypes] DROP CONSTRAINT [DF__GrainTypes_Lang]
END
GO

/****** Object:  Index [IDX_GrainType_Name]    Script Date: 2/26/2020 9:10:04 AM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[GrainTypes]') AND name = N'IDX_GrainType_Name')
DROP INDEX [IDX_GrainType_Name] ON [bhp].[GrainTypes]
GO

/****** Object:  Table [bhp].[GrainTypes]    Script Date: 2/26/2020 9:10:04 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[GrainTypes]') AND type in (N'U'))
DROP TABLE [bhp].[GrainTypes]
GO

/****** Object:  Table [bhp].[GrainTypes]    Script Date: 2/26/2020 9:10:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[GrainTypes](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Lang] [nvarchar](20) NULL,
	[EnteredBy] [sysname] NULL,
	[EnteredOn] [datetime] NULL,
 CONSTRAINT [PK__GrainTyps_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_GrainType_Name]    Script Date: 2/26/2020 9:10:04 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_GrainType_Name] ON [bhp].[GrainTypes]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[GrainTypes] ADD  CONSTRAINT [DF__GrainTypes_Lang]  DEFAULT ('en_us') FOR [Lang]
GO

ALTER TABLE [bhp].[GrainTypes] ADD  CONSTRAINT [DF__GrainType_EnteredBy]  DEFAULT (suser_sname()) FOR [EnteredBy]
GO

ALTER TABLE [bhp].[GrainTypes] ADD  CONSTRAINT [DF__GrainType_EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

set identity_insert [bhp].GrainTypes on;
insert into [bhp].GrainTypes (RowID, Name, Lang) values (0,'dummy','en_us');
set identity_insert [bhp].GrainTypes off;
go
