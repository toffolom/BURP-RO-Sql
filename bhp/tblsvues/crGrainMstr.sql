USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_GrainMstr_GrainType]') AND parent_object_id = OBJECT_ID(N'[bhp].[GrainMstr]'))
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [FK_GrainMstr_GrainType]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_GrainMstr_GrainMfr]') AND parent_object_id = OBJECT_ID(N'[bhp].[GrainMstr]'))
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [FK_GrainMstr_GrainMfr]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_GrainMstr_Country]') AND parent_object_id = OBJECT_ID(N'[bhp].[GrainMstr]'))
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [FK_GrainMstr_Country]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_GrainMstr_Fk_Country]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF_GrainMstr_Fk_Country]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr__EnteredBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr__EnteredBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr__EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr__EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_GrainMstr_isUnderModified]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF_GrainMstr_isUnderModified]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_GrainMstr_isModified]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF_GrainMstr_isModified]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr_CountryOfOrigin]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr_CountryOfOrigin]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr__NbrOfRecipes]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr__NbrOfRecipes]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr__fk_GrainMfr]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr__fk_GrainMfr]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr__RowSize]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr__RowSize]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr_fk_GrainTyp]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr_fk_GrainTyp]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr__SRM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr__SRM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr_degLEnd]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr_degLEnd]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__GrainMstr__degLStart]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[GrainMstr] DROP CONSTRAINT [DF__GrainMstr__degLStart]
END
GO

/****** Object:  Index [IDX_GraintMstr_Name]    Script Date: 2/27/2020 12:38:31 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[GrainMstr]') AND name = N'IDX_GraintMstr_Name')
DROP INDEX [IDX_GraintMstr_Name] ON [bhp].[GrainMstr] WITH ( ONLINE = OFF )
GO

/****** Object:  Table [bhp].[GrainMstr]    Script Date: 2/27/2020 12:38:31 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[GrainMstr]') AND type in (N'U'))
DROP TABLE [bhp].[GrainMstr]
GO

/****** Object:  Table [bhp].[GrainMstr]    Script Date: 2/27/2020 12:38:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[GrainMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[degLStart] [numeric](8, 2) NOT NULL,
	[degLEnd] [numeric](8, 2) NOT NULL,
	[SRM] [numeric](8, 2) NULL,
	[degEBC]  AS ((2.65)*[degLStart]-(1.2)),
	[fk_GrainType] [int] NOT NULL,
	[GrainType]  AS ([bhp].[fn_GetGrainTypeNm]([fk_GrainType])),
	[RowSize] [int] NULL,
	[KnownAs1] [nvarchar](256) NULL,
	[KnownAs2] [nvarchar](256) NULL,
	[KnownAs3] [nvarchar](256) NULL,
	[fk_GrainMfr] [int] NULL,
	[NbrOfRecipesUsedIn] [int] NULL,
	[CountryOfOrigin] [nvarchar](256) NULL,
	[isModified] [bit] NULL,
	[isUnderModified] [bit] NULL,
	[EnteredOn] [datetime] NULL,
	[EnteredBy] [sysname] NULL,
	[PotentialGravityBeg] [numeric](5, 4) NULL,
	[PotentialGravityEnd] [numeric](5, 4) NULL,
	[Comment] [nvarchar](1000) NULL,
	[fk_CountryID] [int] NOT NULL,
 CONSTRAINT [PK__GrainMstr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_GraintMstr_Name]    Script Date: 2/27/2020 12:38:31 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IDX_GraintMstr_Name] ON [bhp].[GrainMstr]
(
	[Name] ASC,
	[fk_GrainMfr] ASC,
	[fk_GrainType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr__degLStart]  DEFAULT ((0)) FOR [degLStart]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr_degLEnd]  DEFAULT ((0)) FOR [degLEnd]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr__SRM]  DEFAULT ((0)) FOR [SRM]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr_fk_GrainTyp]  DEFAULT ((0)) FOR [fk_GrainType]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr__RowSize]  DEFAULT ((0)) FOR [RowSize]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr__fk_GrainMfr]  DEFAULT ((0)) FOR [fk_GrainMfr]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr__NbrOfRecipes]  DEFAULT ((0)) FOR [NbrOfRecipesUsedIn]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr_CountryOfOrigin]  DEFAULT ('n/a') FOR [CountryOfOrigin]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF_GrainMstr_isModified]  DEFAULT ((0)) FOR [isModified]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF_GrainMstr_isUnderModified]  DEFAULT ((0)) FOR [isUnderModified]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF__GrainMstr__EnteredBy]  DEFAULT (suser_sname()) FOR [EnteredBy]
GO

ALTER TABLE [bhp].[GrainMstr] ADD  CONSTRAINT [DF_GrainMstr_Fk_Country]  DEFAULT ((0)) FOR [fk_CountryID]
GO

alter table [bhp].[GrainMstr] Add 
Constraint [DF_GrainMstr_PotentialBeg] default(0) for [PotentialGravityBeg],
Constraint [DF_GrainMstr_PotentialEnd] default(0) for [PotentialGravityEnd];
go

ALTER TABLE [bhp].[GrainMstr]  WITH CHECK ADD  CONSTRAINT [FK_GrainMstr_Country] FOREIGN KEY([fk_CountryID])
REFERENCES [di].[Countries] ([RowID])
GO

ALTER TABLE [bhp].[GrainMstr] CHECK CONSTRAINT [FK_GrainMstr_Country]
GO

ALTER TABLE [bhp].[GrainMstr]  WITH CHECK ADD  CONSTRAINT [FK_GrainMstr_GrainMfr] FOREIGN KEY([fk_GrainMfr])
REFERENCES [bhp].[GrainManufacturers] ([RowID])
GO

ALTER TABLE [bhp].[GrainMstr] CHECK CONSTRAINT [FK_GrainMstr_GrainMfr]
GO

ALTER TABLE [bhp].[GrainMstr]  WITH CHECK ADD  CONSTRAINT [FK_GrainMstr_GrainType] FOREIGN KEY([fk_GrainType])
REFERENCES [bhp].[GrainTypes] ([RowID])
GO

ALTER TABLE [bhp].[GrainMstr] CHECK CONSTRAINT [FK_GrainMstr_GrainType]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		mike t.
-- Create date: 19Aug2014
-- Description:	prevent deletion if grain used in recipe
-- =============================================
CREATE TRIGGER [bhp].[GrainMstr_Trig_Del_01] 
   ON  [bhp].[GrainMstr] 
--with encryption
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

    If Exists (Select * from [bhp].RecipeGrains RG Inner Join deleted d On (RG.fk_GrainMstrID = d.RowID))
	Begin
		Raiserror('Request to remove Grain Master cannot be performed.  Grain is used in a customer recipe. Request Aborted!!!',16,1);
		Rollback Transaction;
	End

END
GO

set identity_insert [bhp].[GrainMstr] on;
insert into [bhp].[GrainMstr](RowID, Name, Comment) Values(0,'pls select...','DO NOT REMOVE!!!');
set identity_insert [bhp].[GrainMstr] off;
go


