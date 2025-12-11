USE [BHP1-RO]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

if object_id('[bhp].[Environment]',N'U') is not null
begin
	Drop Table [bhp].[Environment];
	Print 'table:: [bhp].[Environment] dropped!!!';
end
go

CREATE TABLE [bhp].[Environment](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[VarNm] [nvarchar](200) NOT NULL,
	[VarVal] [nvarchar](4000) NOT NULL,
	[Notes] [nvarchar](4000) NULL,
 CONSTRAINT [PK_Environment_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE UNIQUE CLUSTERED INDEX [di_IDX_Environment_VarNm] ON [bhp].[Environment]
(
	[VarNm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [bhp].[Environment] ADD  CONSTRAINT [di_DF_Environment_Notes]  DEFAULT ('<Notes><Note nbr=''0''/></Notes>') FOR [Notes];
GO


set identity_insert [bhp].Environment on;
insert [bhp].Environment(RowID, VarNm, VarVal, Notes)
values (0,'dummy','dummy','<Notes><Note nbr=''1''>here for referiential integrity purposes...</Note></Notes>');
set identity_insert [bhp].Environment off;
go




checkpoint
go


