USE [BHP1-RO]
GO

/****** Object:  Table [bhp].[YeastFlocculationTypes]    Script Date: 2/26/2020 2:31:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[YeastFlocculationTypes]') AND type in (N'U'))
DROP TABLE [bhp].[YeastFlocculationTypes]
GO

/****** Object:  Table [bhp].[YeastFlocculationTypes]    Script Date: 2/26/2020 2:31:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[YeastFlocculationTypes](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](40) NOT NULL,
 CONSTRAINT [PK_YeastFlocculationTypes_Pk_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

set identity_insert [bhp].[YeastFlocculationTypes] on;
insert [bhp].[YeastFlocculationTypes](RowID,Name) values (0,'pls select...');
set identity_insert [bhp].[YeastFlocculationTypes] off;
go

Create Trigger [bhp].[YeastFlocculationTypes_Trig_Del_99] on [bhp].[YeastFlocculationTypes]
--with encryption
for delete
as
begin
	If Exists (Select 1 from deleted where RowID=0)
	Begin
		Raiserror(N'Row ''Zero'' cannot be removed!!!',16,1);
		Rollback Transaction;
	End
end
go