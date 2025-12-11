USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastTypes_EnteredOn]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastTypes] DROP CONSTRAINT [DF_YeastTypes_EnteredOn]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastTypes_EnteredBy]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastTypes] DROP CONSTRAINT [DF_YeastTypes_EnteredBy]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastTypes_Lang]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastTypes] DROP CONSTRAINT [DF_YeastTypes_Lang]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_YeastTypes_Phylum]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[YeastTypes] DROP CONSTRAINT [DF_YeastTypes_Phylum]
END
GO

/****** Object:  Table [bhp].[YeastTypes]    Script Date: 2/26/2020 2:54:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[YeastTypes]') AND type in (N'U'))
DROP TABLE [bhp].[YeastTypes]
GO

/****** Object:  Table [bhp].[YeastTypes]    Script Date: 2/26/2020 2:54:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[YeastTypes](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Phylum] [nvarchar](256) NULL,
	[Lang] [nvarchar](20) NULL,
	[EnteredBy] [sysname] NULL,
	[EnteredOn] [datetime] NULL,
 CONSTRAINT [PK__YeastTypes_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[YeastTypes] ADD  CONSTRAINT [DF_YeastTypes_Phylum]  DEFAULT ('not set') FOR [Phylum]
GO

ALTER TABLE [bhp].[YeastTypes] ADD  CONSTRAINT [DF_YeastTypes_Lang]  DEFAULT ('en_us') FOR [Lang]
GO

ALTER TABLE [bhp].[YeastTypes] ADD  CONSTRAINT [DF_YeastTypes_EnteredBy]  DEFAULT (suser_sname()) FOR [EnteredBy]
GO

ALTER TABLE [bhp].[YeastTypes] ADD  CONSTRAINT [DF_YeastTypes_EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

set identity_insert [bhp].[YeastTypes] on;
insert into [bhp].[YeastTypes](RowID, Name) Values (0, 'pls select...');
set identity_insert [bhp].[YeastTypes] off;
go

/****** Object:  Trigger [bhp].[Trig_YeastTypes_Del_01]    Script Date: 2/26/2020 2:56:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		mike
-- Create date: 01Sep2014
-- Description:	Prevent deletion of row referenced in yeast master table
-- =============================================
CREATE TRIGGER [bhp].[Trig_YeastTypes_Del_01] 
   ON  [bhp].[YeastTypes] 
   --with encryption
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

    If Exists (Select * from deleted d Inner Join [bhp].YeastMstr Y On (d.RowID = Y.fk_YeastType))
	Begin
		Declare @Mesg nvarchar(2000);
		Exec [di].getI18NMsg @Nbr=66039,@Lang='en_us',@Msg=@Mesg Output;
		Raiserror(@Mesg, 16, 1);
		Rollback Transaction;
	End

END
GO

-- =============================================
-- Author:		mike
-- Create date: 01Sep2014
-- Description:	Prevent deletion of row zero
-- =============================================
CREATE TRIGGER [bhp].[Trig_YeastTypes_Del_99] 
   ON  [bhp].[YeastTypes]
   --With Encryption 
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

    If Exists (Select * from deleted Where RowID = 0)
	Begin
		Declare @Mesg nvarchar(2000);
		Exec [di].getI18NMsg @Nbr=66034,@Lang='en_us',@Msg=@Mesg Output;
		Raiserror(@Mesg, 16, 1);
		Rollback Transaction;
	End

END
GO

