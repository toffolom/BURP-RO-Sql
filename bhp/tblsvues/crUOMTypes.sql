USE [BHP1-RO]
GO

If Object_ID(N'[bhp].[UOMTypes]',N'U') IS NOT NULL
Begin
	Drop Table [bhp].[UOMTypes];
	Print 'Table:: [bhp].[UOMTypes] dropped!!!';
End
go

/****** Object:  Table [bhp].[UOMTypes]    Script Date: 2/25/2020 11:02:17 AM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[UOMTypes]') AND type in (N'U'))
BEGIN
CREATE TABLE [bhp].[UOMTypes](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[UOM] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Lang] [nvarchar](20) NULL,
	[AllowedAsTimeMeasure] [bit] NULL,
	[AllowedAsVolumnMeasure] [bit] NULL,
	[AllowedAsTemperature] [bit] NULL,
	[AllowedAsContainer] [bit] NULL,
	[AllowedAsColorMeasure] [bit] NULL,
	[AllowedAsBitterMeasure] [bit] NULL,
	[AllowedAsWeightMeasure] [bit] NULL,
	[AllowedAsMonetary] [bit] NULL,
	[EnteredOn] [datetime] NULL,
	[Comment] [varchar](1000) NULL,
	[MaxVal] [varchar](50) NULL,
	[MinVal] [varchar](50) NULL,
 CONSTRAINT [PK__UOMTypes__RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IDX_UOMTypes_UOM]    Script Date: 2/25/2020 11:02:17 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_UOMTypes_UOM] ON [bhp].[UOMTypes]
(
	[UOM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[UOMTypes] ADD  
CONSTRAINT [DF_UOMTypes_Lang]  DEFAULT ('en_us') FOR [Lang],
CONSTRAINT [DF_UOMTypes_AllowedAsTimeMeasure]  DEFAULT ((0)) FOR [AllowedAsTimeMeasure],
CONSTRAINT [DF_UOMTypes_AllowedAsQtyMeasure]  DEFAULT ((0)) FOR [AllowedAsVolumnMeasure],
CONSTRAINT [DF_UOMTypes_AllowedAsTemperature]  DEFAULT ((0)) FOR [AllowedAsTemperature],
CONSTRAINT [DF_UOMTypes_AllowedAsContainer]  DEFAULT ((0)) FOR [AllowedAsContainer],
CONSTRAINT [DF_UOMTypes_AllowedAsColorMeasure]  DEFAULT ((0)) FOR [AllowedAsColorMeasure],
CONSTRAINT [DF_UOMTypes_AllowedAsBitterMeasure]  DEFAULT ((0)) FOR [AllowedAsBitterMeasure],
CONSTRAINT [DF_UOMTypes_AllowedAsWeightMeasure]  DEFAULT ((0)) FOR [AllowedAsWeightMeasure],
CONSTRAINT [DF_UOMTypes_AllowedAsMonetaryMeasure]  DEFAULT ((0)) FOR [AllowedAsMonetary],
CONSTRAINT [DF_UOMTypes_EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

set identity_Insert [bhp].[UOMTypes] on;
insert into [bhp].[UOMTypes]([RowID]
      ,[UOM]
      ,[Name]
      ,[Lang]
      ,[AllowedAsTimeMeasure]
      ,[AllowedAsVolumnMeasure]
      ,[AllowedAsTemperature]
      ,[AllowedAsContainer]
      ,[AllowedAsColorMeasure]
      ,[AllowedAsBitterMeasure]
      ,[AllowedAsWeightMeasure]
      ,[AllowedAsMonetary]
      ,[EnteredOn]
      ,[Comment]
      ,[MaxVal]
      ,[MinVal])
values (0, 'pls select...','pls select...','en_us',1,1,1,1,1,1,1,1,getdate(),N'<Notes><Note nbr="1">DO NOT REMOVE!!!</Note></Notes>',0,0);
set identity_Insert [bhp].[UOMTypes] off;
go

create trigger [bhp].[UOMTypes_Del_Trig_99] on [bhp].[UOMTypes]
with encryption
for delete
as
Begin
	If Exists (Select * from Deleted where RowID = 0)
	Begin
		Raiserror('Row ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
End
GO

ALTER TABLE [bhp].[UOMTypes] ENABLE TRIGGER [UOMTypes_Del_Trig_99]
GO



