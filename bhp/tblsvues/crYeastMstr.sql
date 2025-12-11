USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CHK_YeastMstr_PSub2]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastMstr]'))
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [CHK_YeastMstr_PSub2]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[bhp].[CHK_YeastMstr_PSub1]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastMstr]'))
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [CHK_YeastMstr_PSub1]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastMstr_YeastType]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastMstr]'))
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [FK_YeastMstr_YeastType]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastMstr_YeastPkgTyp]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastMstr]'))
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [FK_YeastMstr_YeastPkgTyp]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastMstr_YeastMfr]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastMstr]'))
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [FK_YeastMstr_YeastMfr]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastMstr_FlocculationTypes]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastMstr]'))
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [FK_YeastMstr_FlocculationTypes]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_YeastMstr_Country]') AND parent_object_id = OBJECT_ID(N'[bhp].[YeastMstr]'))
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [FK_YeastMstr_Country]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_FlocculationTYpe]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_FlocculationTYpe]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_Lang]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_Lang]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__YeastMstr__EnteredBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF__YeastMstr__EnteredBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__YeastMstr__EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF__YeastMstr__EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_PSub2]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_PSub2]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_PSub1]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_PSub1]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__YeastMstr__NbrOfRecipesUsedIn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF__YeastMstr__NbrOfRecipesUsedIn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_fk_FermTempUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_fk_FermTempUOM]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_FermTempEnd]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_FermTempEnd]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_FermTempBeg]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_FermTempBeg]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_Attenuation]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_Attenuation]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_Flocculation]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_Flocculation]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastMstr_YeastPkgTypID]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF_YeastMstr_YeastPkgTypID]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__YeastMstr__fk_YeastType]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF__YeastMstr__fk_YeastType]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF__YeastMstr__fk_YeastMfr]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastMstr] DROP CONSTRAINT [DF__YeastMstr__fk_YeastMfr]
END
GO

/****** Object:  Index [IDX_YeastMstr_Name]    Script Date: 2/26/2020 2:36:19 PM ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[bhp].[YeastMstr]') AND name = N'IDX_YeastMstr_Name')
DROP INDEX [IDX_YeastMstr_Name] ON [bhp].[YeastMstr] WITH ( ONLINE = OFF )
GO

/****** Object:  Table [bhp].[YeastMstr]    Script Date: 2/26/2020 2:36:19 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[YeastMstr]') AND type in (N'U'))
DROP TABLE [bhp].[YeastMstr]
GO

/****** Object:  Table [bhp].[YeastMstr]    Script Date: 2/26/2020 2:36:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[YeastMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[fk_YeastMfr] [int] NULL,
	[MfrNm]  AS ([bhp].[fn_GetYeastMfrNm]([fk_YeastMfr])),
	[fk_YeastType] [int] NOT NULL,
	[YeastTypName]  AS ([bhp].[fn_GetYeastTypNm]([fk_YeastType])),
	[fk_YeastPkgTyp] [int] NOT NULL,
	[PkgDescr]  AS ([bhp].[fn_YeastPkgTypToStr]([fk_YeastPkgTyp])),
	[Flocculation] [varchar](50) NULL,
	[Attenuation] [varchar](50) NULL,
	[FermTempBeg] [tinyint] NULL,
	[FermTempEnd] [tinyint] NULL,
	[fk_FermTempUOM] [int] NULL,
	[FermTempUOM]  AS ([bhp].[fn_GetUOM]([fk_FermTempUOM])),
	[KnownAs1] [nvarchar](256) NULL,
	[KnownAs2] [nvarchar](256) NULL,
	[KnownAs3] [nvarchar](256) NULL,
	[NbrOfRecipesUsedIn] [int] NULL,
	[PSub1] [int] NULL,
	[PSubNm1]  AS ([bhp].[fn_YeastNm]([PSub1])),
	[PSub2] [int] NULL,
	[PSubNm2]  AS ([bhp].[fn_YeastNm]([PSub2])),
	[Notes] [nvarchar](2000) NULL,
	[EnteredOn] [datetime] NULL,
	[EnteredBy] [sysname] NULL,
	[Lang] [nvarchar](20) NULL,
	[fk_CountryID] [int] NULL,
	[fk_FlocculationType] [int] NOT NULL,
 CONSTRAINT [PK__YeastMstr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_YeastMstr_Name]    Script Date: 2/26/2020 2:36:19 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IDX_YeastMstr_Name] ON [bhp].[YeastMstr]
(
	[Name] ASC,
	[fk_YeastType] ASC,
	[fk_YeastMfr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF__YeastMstr__fk_YeastMfr]  DEFAULT ((0)) FOR [fk_YeastMfr]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF__YeastMstr__fk_YeastType]  DEFAULT ((0)) FOR [fk_YeastType]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_YeastPkgTypID]  DEFAULT ((0)) FOR [fk_YeastPkgTyp]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_Flocculation]  DEFAULT ('not avail') FOR [Flocculation]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_Attenuation]  DEFAULT ('not avail') FOR [Attenuation]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_FermTempBeg]  DEFAULT ((0)) FOR [FermTempBeg]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_FermTempEnd]  DEFAULT ((0)) FOR [FermTempEnd]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_fk_FermTempUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('F')) FOR [fk_FermTempUOM]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF__YeastMstr__NbrOfRecipesUsedIn]  DEFAULT ((0)) FOR [NbrOfRecipesUsedIn]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_PSub1]  DEFAULT ((0)) FOR [PSub1]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_PSub2]  DEFAULT ((0)) FOR [PSub2]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF__YeastMstr__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF__YeastMstr__EnteredBy]  DEFAULT (suser_sname()) FOR [EnteredBy]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_Lang]  DEFAULT (N'en_us') FOR [Lang]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_FlocculationTYpe]  DEFAULT ((0)) FOR [fk_FlocculationType]
GO

ALTER TABLE [bhp].[YeastMstr] ADD  CONSTRAINT [DF_YeastMstr_Country]  DEFAULT ((0)) FOR [fk_CountryID]
GO

ALTER TABLE [bhp].[YeastMstr]  WITH CHECK ADD  CONSTRAINT [FK_YeastMstr_Country] FOREIGN KEY([fk_CountryID])
REFERENCES [di].[Countries] ([RowID])
GO

ALTER TABLE [bhp].[YeastMstr] CHECK CONSTRAINT [FK_YeastMstr_Country]
GO

ALTER TABLE [bhp].[YeastMstr]  WITH CHECK ADD  CONSTRAINT [FK_YeastMstr_FlocculationTypes] FOREIGN KEY([fk_FlocculationType])
REFERENCES [bhp].[YeastFlocculationTypes] ([RowID])
GO

ALTER TABLE [bhp].[YeastMstr] CHECK CONSTRAINT [FK_YeastMstr_FlocculationTypes]
GO

ALTER TABLE [bhp].[YeastMstr]  WITH CHECK ADD  CONSTRAINT [FK_YeastMstr_YeastMfr] FOREIGN KEY([fk_YeastMfr])
REFERENCES [bhp].[YeastManufacturers] ([RowID])
GO

ALTER TABLE [bhp].[YeastMstr] CHECK CONSTRAINT [FK_YeastMstr_YeastMfr]
GO

ALTER TABLE [bhp].[YeastMstr]  WITH CHECK ADD  CONSTRAINT [FK_YeastMstr_YeastPkgTyp] FOREIGN KEY([fk_YeastPkgTyp])
REFERENCES [bhp].[YeastPackagingTypes] ([RowID])
GO

ALTER TABLE [bhp].[YeastMstr] CHECK CONSTRAINT [FK_YeastMstr_YeastPkgTyp]
GO

ALTER TABLE [bhp].[YeastMstr]  WITH CHECK ADD  CONSTRAINT [FK_YeastMstr_YeastType] FOREIGN KEY([fk_YeastType])
REFERENCES [bhp].[YeastTypes] ([RowID])
GO

ALTER TABLE [bhp].[YeastMstr] CHECK CONSTRAINT [FK_YeastMstr_YeastType]
GO

ALTER TABLE [bhp].[YeastMstr] ADD 
CONSTRAINT [FK_YeastMstr_PSub1] Foreign Key (PSub1) References [bhp].[YeastMstr]([RowID]);
GO

ALTER TABLE [bhp].[YeastMstr]  ADD 
CONSTRAINT [CHK_YeastMstr_PSub2] Foreign Key (PSub2) References [bhp].[YeastMstr]([RowID]);
GO

alter table bhp.YeastMstr add
Constraint FK_YeastMstr_Fk_FermTemp Foreign Key (Fk_FermTempUOM) References bhp.UOMTypes(RowID);
go

set identity_insert [bhp].[YeastMstr] On;
insert into [bhp].[YeastMstr](RowID, Name) values (0, 'pls select...');
set identity_insert [bhp].[YeastMstr] Off;
go


SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Trigger [bhp].[Trig_YeastMstr_Del_01]    Script Date: 2/26/2020 2:44:05 PM ******/
-- =============================================
-- Author:		mike
-- Create date: 21Aug2014
-- Description:	Prevent deletion of yeast master record if used by any recipes
-- =============================================
CREATE TRIGGER [bhp].[Trig_YeastMstr_Del_01] 
   ON  [bhp].[YeastMstr] 
   --With Encryption
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

    If Exists (Select * from [bhp].RecipeYeasts R Inner Join deleted d On (R.fk_YeastMstrID = d.RowID))
	Begin
		Declare @Mesg nvarchar(2000);
		Exec [di].getI18NMsg @Nbr=66035, @Lang='en_us', @Msg=@Mesg Output;
		Raiserror(@Mesg, 16, 1);
		Rollback Transaction;
	End

END
GO


SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Trigger [bhp].[Trig_YeastMstr_Del_99]    Script Date: 2/26/2020 2:45:19 PM ******/
-- =============================================
-- Author:		mike
-- Create date: 21Aug2014
-- Description:	prevent deletion of row zero
-- =============================================
CREATE TRIGGER [bhp].[Trig_YeastMstr_Del_99] 
   ON  [bhp].[YeastMstr] 
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

    If Exists (Select * from deleted where RowID = 0)
	Begin
		Declare @Mesg nvarchar(2000);
		Exec [di].[getI18NMsg] @Nbr=66034, @Lang='en_us', @Msg=@Mesg Output;
		Raiserror(@Mesg, 16, 1);
		Rollback Transaction;
	End

END
GO





