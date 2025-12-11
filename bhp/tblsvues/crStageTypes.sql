USE [BHP1-RO]
GO

If Object_ID(N'[bhp].[StageTypes]',N'U') IS NOT NULL
Begin
	Drop Table [bhp].[StageTypes];
	Print 'Table:: [bhp].[StageTypes] dropped!!!';
End
Go

/****** Object:  Table [bhp].[StageTypes]    Script Date: 2/25/2020 11:16:50 AM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [bhp].[StageTypes](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Lang] [nvarchar](20) NULL,
	[AllowedInHopSched] [bit] NULL,
	[AllowedInYeastSched] [bit] NULL,
	[AllowedInMashSched] [bit] NULL,
	[AllowedInAgingSched] [bit] NULL,
	[AKA1] [nvarchar](100) NULL,
	[AKA2] [nvarchar](100) NULL,
	[AKA3] [nvarchar](100) NULL,
	[EnteredOn] [datetime] NULL,
	[Comment] [nvarchar](1000) NULL,
 CONSTRAINT [PK__StageTypes_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_StageTypes_Name]    Script Date: 2/25/2020 11:16:50 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_StageTypes_Name] ON [bhp].[StageTypes]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[StageTypes] ADD  
CONSTRAINT [DF_StageTypes_Lang]  DEFAULT ('en_us') FOR [Lang],
CONSTRAINT [DF_StageTypes_AllowedInHopSched]  DEFAULT ((0)) FOR [AllowedInHopSched],
CONSTRAINT [DF_StageTypes_AllowedInYeastSched]  DEFAULT ((0)) FOR [AllowedInYeastSched],
CONSTRAINT [DF_StageTypes_AllowedInMashSched]  DEFAULT ((0)) FOR [AllowedInMashSched],
CONSTRAINT [DF_StageTypes_AllowedInAgingSched]  DEFAULT ((0)) FOR [AllowedInAgingSched],
CONSTRAINT [DF__StageType__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

set identity_insert [bhp].[StageTypes] on;
insert into [bhp].[StageTypes](RowID, Name, AllowedInAgingSched, AllowedInHopSched, AllowedInMashSched, AllowedInYeastSched, Comment)
values (0,'pls select...',1,1,1,1,N'<Notes><Note nbr="1">DO NOT REMOVE!!!</Note></Notes>')
set identity_insert [bhp].[StageTypes] off;
go


create trigger [bhp].[StageTypes_Del_Trig_99] on [bhp].[StageTypes] for delete
as
begin
	If Exists (Select * from Deleted where rowid = 0)
	Begin
		Raiserror('Row ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
GO

ALTER TABLE [bhp].[StageTypes] ENABLE TRIGGER [StageTypes_Del_Trig_99]
GO

