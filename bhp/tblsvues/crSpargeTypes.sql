USE [BHP1-RO]
GO

/****** Object:  Table [bhp].[SpargeTypes]    Script Date: 4/24/2019 11:49:10 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[SpargeTypes]') AND type in (N'U'))
DROP TABLE [bhp].[SpargeTypes]
GO

/****** Object:  Table [bhp].[SpargeTypes]    Script Date: 4/24/2019 11:49:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[SpargeTypes](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](20) NULL,
	[AKA] [varchar](20) NULL,
	[Comment] [nvarchar](2000) NULL,
 CONSTRAINT [PK_SpargeTypes_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

set identity_insert [bhp].SpargeTypes on;
insert into [bhp].SpargeTypes (RowID,Name,AKA,Comment)
values (0,'pls select...','pls select...','DO NOT REMOVE!!!');
set identity_insert [bhp].SpargeTypes off;
go

Create Trigger [bhp].[SpargeTypes_Del_99] on [bhp].[SpargeTypes]
--with encryption
after delete
as
begin
	If Exists (Select 1 from deleted Where RowID = 0)
	Begin
		Raiserror(N'Row ''Zero'' cannot be removed!!!',16,1);
		Rollback Transaction;
	End
end
go

checkpoint
go
