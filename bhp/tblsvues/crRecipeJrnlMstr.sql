USE [BHP1-RO]
GO

If Object_ID(N'[bhp].[RecipeJrnlMstr]',N'U') IS NOT NULL
Begin
	Drop Table [bhp].[RecipeJrnlMstr];
	Print 'Table:: [bhp].[RecipeJrnlMstr] dropped!!!';
End
go

/****** Object:  Table [bhp].[RecipeJrnlMstr]    Script Date: 2/25/2020 10:55:27 AM ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE [bhp].[RecipeJrnlMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
	[fk_BeerStyle] [int] NULL,
	[BeerStyle]  AS ([bhp].[fn_GetAHACatName]([fk_BeerStyle])),
	[TargetQty] [numeric](6, 2) NULL,
	[fk_TargetUOM] [int] NOT NULL,
	[TargetUOM]  AS ([bhp].[fn_GetUOM]([fk_TargetUOM])),
	[BatchQty] [numeric](6, 2) NULL,
	[fk_BatchUOM] [int] NOT NULL,
	[BatchUOM]  AS ([bhp].[fn_GetUOM]([fk_BatchUOM])),
	[fk_CreatedBy] [bigint] NULL,
	[CreatedBy]  AS ([di].[fn_GetCustLoginNm]([fk_CreatedBy])),
	[isDraft] [bit] NULL,
	[totBatchesMade] [int] NULL,
	[EnteredOn] [datetime] NULL,
	[Notes] [nvarchar](4000) NULL,
	[fk_BrewerCommentary] [int] NULL,
	[TargetBoilSize] [numeric](6, 2) NULL,
	[fk_BoilSizeUOM] [int] NULL,
	[BoilSizeUOM]  AS ([bhp].[fn_GetUOM]([fk_BoilSizeUOM])),
	[fk_BrewerID] [bigint] NULL,
	[BrewerID]  AS ([di].[fn_GetCustLoginNm]([fk_BrewerID])),
	[fk_AsstBrewerID] [bigint] NULL,
	[TargetOG] [numeric](4, 3) NULL,
	[TargetFG] [numeric](4, 3) NULL,
	[TargetABV] [numeric](3, 1) NULL,
	[TargetDensity] [numeric](6, 3) NULL,
	[fk_TargetDensityUOM] [int] NOT NULL,
	[TargetDensityUOM]  AS ([bhp].[fn_GetUOM]([fk_TargetDensityUOM])),
	[TargetColor] [int] NULL,
	[fk_TargetColorUOM] [int] NULL,
	[TargetColorUOM]  AS ([bhp].[fn_GetUOM]([fk_TargetColorUOM])),
	[TargetBitterness] [int] NULL,
	[fk_TargetBitternessUOM] [int] NULL,
	[TargetBitternessUOM]  AS ([bhp].[fn_GetUOM]([fk_TargetBitternessUOM])),
	[SharingMask] [int] NULL,
	[SharingMaskAsCSV]  AS ([bhp].[fn_SharingTypesMaskToStr]([SharingMask])),
	[fk_DeployInfo] [int] NULL,
	[Tags]  AS ([bhp].[fn_RecipeTags]([RowID])),
	[fk_ClonedFrom] [int] NOT NULL,
 CONSTRAINT [PK__RecipeJrnlMstr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RecipeJrnlMstr_CustID]    Script Date: 2/25/2020 10:55:27 AM ******/
CREATE NONCLUSTERED INDEX [IDX_RecipeJrnlMstr_CustID] ON [bhp].[RecipeJrnlMstr]
(
	[fk_CreatedBy] ASC,
	[fk_DeployInfo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE trigger [bhp].[RecipeJrnlMstr_Del_Trig_99] on [bhp].[RecipeJrnlMstr]
with encryption
for delete
as
Begin
	If Exists (Select * from Deleted where rowid = 0)
	Begin
		Raiserror('Row ''Zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
End
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_fk_BeerStyle]  DEFAULT ((0)) FOR [fk_BeerStyle]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF__RecipeJrnlMstr__TargetQty]  DEFAULT ((0)) FOR [TargetQty]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF__RecipeJrnlMstr__fk_TargetUOM]  DEFAULT ([bhp].[fn_getUOMIdByNm]('gal')) FOR [fk_TargetUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF__RecipeJrnlMstr__BatchQty]  DEFAULT ((0)) FOR [BatchQty]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF__RecipeJrnlMstr__fk_BatchUOM]  DEFAULT ([bhp].[fn_getUOMIdByNm]('gal')) FOR [fk_BatchUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF__RecipeJrnlMstr__CreatedBy]  DEFAULT ((0)) FOR [fk_CreatedBy]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_isDraft]  DEFAULT ((0)) FOR [isDraft]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_totBatchesMade]  DEFAULT ((0)) FOR [totBatchesMade]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF__RecipeJrnlMstr__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_BrewerCommentary]  DEFAULT ((0)) FOR [fk_BrewerCommentary]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_TargetBoilSize]  DEFAULT ((0)) FOR [TargetBoilSize]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_fk_BoilSizeUOM]  DEFAULT ((0)) FOR [fk_BoilSizeUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_fk_BrewerID]  DEFAULT ((0)) FOR [fk_BrewerID]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_fk_AsstBrewerID]  DEFAULT ((0)) FOR [fk_AsstBrewerID]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_TrgtABV]  DEFAULT ((0.0)) FOR [TargetABV]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_TrgtDensity]  DEFAULT ((0.0)) FOR [TargetDensity]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_TrgtDensityUOM]  DEFAULT ([bhp].[fn_GetUOMIdbyNm]('brix')) FOR [fk_TargetDensityUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_TargetColor_Zero]  DEFAULT ((0)) FOR [TargetColor]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_TargetColorUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('srm')) FOR [fk_TargetColorUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_TrgtBitterness_zero]  DEFAULT ((0)) FOR [TargetBitterness]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_fk_TrgtBitternessUOM]  DEFAULT ([bhp].[fn_GetUOMIdByNm]('IBU')) FOR [fk_TargetBitternessUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_SharingMask]  DEFAULT ((0)) FOR [SharingMask]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_DeployInfo]  DEFAULT ((0)) FOR [fk_DeployInfo]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] ADD  CONSTRAINT [DF_RecipeJrnlMstr_Fk_ClonedFrom]  DEFAULT ((0)) FOR [fk_ClonedFrom]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_BatchUOM] FOREIGN KEY([fk_BatchUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_BatchUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_BeerStyle] FOREIGN KEY([fk_BeerStyle])
REFERENCES [bhp].[AHABeerStyle] ([RowID])
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_BeerStyle]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_BoilSizeUOM] FOREIGN KEY([fk_BoilSizeUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_BoilSizeUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_BrewerCommentary] FOREIGN KEY([fk_BrewerCommentary])
REFERENCES [bhp].[BrewerCommentary] ([RowID])
ON DELETE CASCADE
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_BrewerCommentary]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_ClonedFrom] FOREIGN KEY([fk_ClonedFrom])
REFERENCES [bhp].[RecipeJrnlMstr] ([RowID])
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_ClonedFrom]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_TargetUOM] FOREIGN KEY([fk_TargetUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_TargetUOM]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_UOM_Bitter] FOREIGN KEY([fk_TargetBitternessUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_UOM_Bitter]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_UOM_Color] FOREIGN KEY([fk_TargetColorUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_UOM_Color]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_UOM_Density] FOREIGN KEY([fk_TargetDensityUOM])
REFERENCES [bhp].[UOMTypes] ([RowID])
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_UOM_Density]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD CONSTRAINT [FK_RecipeJrnlMstr_BrewerID] 
Foreign Key ([fk_BrewerID]) References [di].[CustMstr] (RowID);
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_BrewerID]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD CONSTRAINT [FK_RecipeJrnlMstr_AsstBrewerID] 
Foreign Key ([fk_AsstBrewerID]) References [di].[CustMstr] (RowID);
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_AsstBrewerID]
GO

ALTER TABLE [bhp].[RecipeJrnlMstr]  WITH CHECK ADD  CONSTRAINT [FK_RecipeJrnlMstr_CustID] 
Foreign Key([fk_CreatedBy]) References [di].[CustMstr] (RowID);
GO

ALTER TABLE [bhp].[RecipeJrnlMstr] CHECK CONSTRAINT [FK_RecipeJrnlMstr_CustID]
GO

set identity_Insert [bhp].[RecipeJrnlMstr] on;
insert into [bhp].[RecipeJrnlMstr] (
	[RowID],[Name]
	,[fk_BeerStyle]
	,[TargetQty],[fk_TargetUOM]
	,[BatchQty],[fk_BatchUOM]
	,[fk_CreatedBy]
	,[Notes]
	,[fk_BrewerCommentary]
	,[TargetBoilSize]
	,[fk_BoilSizeUOM]
	,[fk_BrewerID]
	,[fk_AsstBrewerID]
	,[TargetOG]
	,[TargetFG]
	,[TargetABV]
	,[TargetDensity]
	,[fk_TargetDensityUOM]
	,[TargetColor]
	,[fk_TargetColorUOM]
	,[TargetBitterness]
	,[fk_TargetBitternessUOM]
	,[SharingMask]
	,[fk_DeployInfo]
	,[fk_ClonedFrom]
)
values (0,'pls select...',0,0,0,0,0,0,'<Notes><Note nbr="1">DO NOT REMOVE!!!</Note></Notes>',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
);
set identity_Insert [bhp].[RecipeJrnlMstr] off;
go

checkpoint
go

