USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_MashTypeMstr_EndTempAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashTypeMstr] DROP CONSTRAINT [DF_MashTypeMstr_EndTempAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_MashTypeMstr_BegTempAmt]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashTypeMstr] DROP CONSTRAINT [DF_MashTypeMstr_BegTempAmt]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[DF_MashTypeMstr_fk_TempUOM]') AND type = 'D')
BEGIN
ALTER TABLE [bhp].[MashTypeMstr] DROP CONSTRAINT [DF_MashTypeMstr_fk_TempUOM]
END
GO

/****** Object:  Table [bhp].[MashTypeMstr]    Script Date: 3/4/2020 11:04:17 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[MashTypeMstr]') AND type in (N'U'))
DROP TABLE [bhp].[MashTypeMstr]
GO

/****** Object:  Table [bhp].[MashTypeMstr]    Script Date: 3/4/2020 11:04:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[MashTypeMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[fk_TempUOM] [int] NOT NULL,
	[TempUOM]  AS ([bhp].[fn_GetUOM]([fk_TempUOM])),
	[BegTempAmt] [numeric](6, 2) NULL,
	[EndTempAmt] [numeric](6, 2) NULL,
	[Comments] [nvarchar](4000) NULL,
 CONSTRAINT [PK__MashTypeMstr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [bhp].[MashTypeMstr] ADD  CONSTRAINT [DF_MashTypeMstr_fk_TempUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('F')) FOR [fk_TempUOM]
GO

ALTER TABLE [bhp].[MashTypeMstr] ADD  CONSTRAINT [DF_MashTypeMstr_BegTempAmt]  DEFAULT ((0)) FOR [BegTempAmt]
GO

ALTER TABLE [bhp].[MashTypeMstr] ADD  CONSTRAINT [DF_MashTypeMstr_EndTempAmt]  DEFAULT ((0)) FOR [EndTempAmt]
GO

set identity_Insert [bhp].[MashTypeMstr] on;
insert into [bhp].[MashTypeMstr] (RowID,[Name],Comments) Values (0,'pls select...','DO NOT REMOVE!!!');
set identity_Insert [bhp].[MashTypeMstr] off;
go

/****** Object:  Trigger [bhp].[MashTypeMstr_Del_99]    Script Date: 3/4/2020 11:04:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashTypeMstr_Del_99] on [bhp].[MashTypeMstr]
--with encryption
for delete
as
begin
	if exists (select * from deleted where rowid = 0)
	begin
		Raiserror('Mash Type Master record ''zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	end
end
GO

ALTER TABLE [bhp].[MashTypeMstr] ENABLE TRIGGER [MashTypeMstr_Del_99]
GO

/****** Object:  Trigger [bhp].[MashTypeMstr_Ins_01]    Script Date: 3/4/2020 11:04:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [bhp].[MashTypeMstr_Ins_01] on [bhp].[MashTypeMstr]
--with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_TempUOM > 0)
		And (fk_TempUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsTemperature = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',',SPACE(0)) + [Name] From [bhp].UOMTypes Where (AllowedAsTemperature = 1);
		Raiserror('Mashing Temp(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
GO

ALTER TABLE [bhp].[MashTypeMstr] ENABLE TRIGGER [MashTypeMstr_Ins_01]
GO

