USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeExtracts_ExtractID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeExtracts]'))
ALTER TABLE [bhp].[RecipeExtracts] DROP CONSTRAINT [FK_RecipeExtracts_ExtractID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_RecipeExtracts_RecipeID]') AND parent_object_id = OBJECT_ID(N'[bhp].[RecipeExtracts]'))
ALTER TABLE [bhp].[RecipeExtracts] DROP CONSTRAINT [FK_RecipeExtracts_RecipeID]
GO

/****** Object:  Table [bhp].[RecipeExtracts]    Script Date: 02/11/2012 13:36:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[RecipeExtracts]') AND type in (N'U'))
DROP TABLE [bhp].[RecipeExtracts]
GO

drop table [bhp].[RecipeExtracts];
go

create table [bhp].RecipeExtracts (
	RowID [int] identity(1,1),
	fk_RecipeJrnlMstrID int,
	fk_ExtractMstrID int,
	QtyOrAmt [numeric](10,4),
	fk_QtyOrAmtUOM [int],
	fk_Stage int,
	StageNm as ([bhp].fn_getStageName(fk_stage)),
	OpCost [money] null,
	fk_OpCostUOM int null,
	OpCostUOM as ([bhp].[fn_getUOM](fk_OpCostUOM)),
	Comment nvarchar(2000) null
)
go

alter table [bhp].RecipeExtracts add
constraint FK_RecipeExtracts_RecipeID foreign key (fk_RecipeJrnlMstrID) references [bhp].RecipeJrnlMstr (RowID),
constraint FK_RecipeExtracts_ExtractID foreign key (fk_ExtractMstrID) references [bhp].ExtractMstr(RowID),
constraint FK_RecipeExtracts_CostUOM foreign key (fk_OpCostUOM) references [bhp].UOMTypes(RowID),
constraint FK_RecipeExtracts_fk_QtyOrAmtUOM foreign key (fk_QtyOrAmtUOM) references [bhp].UOMTypes(RowID),
constraint FK_RecipeExtracts_fk_Stage foreign key (fk_Stage) references [bhp].StageTypes(RowID),
constraint PK_RecipeExtracts_RowID primary key nonclustered (RowID),
Constraint DF_RecipeExtracts_QtyOrAmt_Zero default(0) for QtyOrAmt,
Constraint DF_RecipeExtracts_Fk_QtyOrAmtUOM default([bhp].fn_GetUOMIdByNm('lb')) for fk_QtyOrAmtUOM,
Constraint DF_RecipeExtracts_OpCost_Zero default(0) for OpCost,
Constraint DF_RecipeExtracts_Fk_OpCostUOM default([bhp].fn_GetUOMIdByNm('$')) for fk_OpCostUOM,
Constraint DF_RecipeExtracts_Comment_NoComm default(N'no comment given...') for Comment,
Constraint DF_RecipeExtracts_fk_Stage default(0) for fk_Stage;
go

set identity_insert [bhp].RecipeExtracts on;
insert into [bhp].RecipeExtracts (
	RowID, fk_RecipeJrnlMstrID, fk_ExtractMstrID, QtyOrAmt, fk_QtyOrAmtUOM, fk_Stage, Comment
)
select 
	0, -- rowid
	0, -- recipe
	0, -- extract
	0.0, -- amt
	[bhp].fn_GetUOMIdByNm('lb'),
	0, -- stage
	N'DO NOT REMOVE!!!'
set identity_insert [bhp].RecipeExtracts off;
go

create trigger RecipeExtracts_Trig_Ins_01 on [bhp].RecipeExtracts
with encryption
for insert
as
begin
	Update [bhp].ExtractMstr
		Set NbrOfRecipesUsedIn = isnull(NbrOfRecipesUsedIn,0) + 1
	From Inserted I Inner Join [bhp].ExtractMstr C
	On (I.fk_ExtractMstrID = C.RowID)
	Where (I.fk_ExtractMstrID > 0);
end
go

create trigger RecipeExtracts_Trig_Ins_02 on [bhp].RecipeExtracts 
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_OpCostUOM > 0)
		And (fk_OpCostUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsMonetary = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + Name from [bhp].UOMTypes Where (AllowedAsMonetary = 1);
		Raiserror('Cost can only be described using:[%s]...aborting!!!',16,1,@Buff);
		Rollback Transaction;
	End
end
go

create trigger RecipeExtracts_Trig_Ins_03 on [bhp].RecipeExtracts 
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_QtyOrAmtUOM > 0)
		And (fk_QtyOrAmtUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + Name from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Amount(s) can only be described using:[%s]...aborting!!!',16,1,@Buff);
		Rollback Transaction;
	End
end
go

create trigger RecipeExtracts_Trig_Del_01 on [bhp].RecipeExtracts
with encryption
for delete
as
begin
	Update [bhp].ExtractMstr
		Set NbrOfRecipesUsedIn = (NbrOfRecipesUsedIn - 1)
	From Inserted I Inner Join [bhp].ExtractMstr C
	On (I.fk_ExtractMstrID = C.RowID)
	Where (I.fk_ExtractMstrID > 0 And C.NbrOfRecipesUsedIn is not null And C.NbrOfRecipesUsedIn > 0);
end
go

create trigger RecipeExtracts_Trig_Del_99 on [bhp].RecipeExtracts
with encryption
for delete
as
begin
	If Exists (Select * from deleted where RowID = 0)
	Begin
		Raiserror('Row Zero cannot be deleted...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

create trigger RecipeExtracts_Trig_Upd_01 on [bhp].RecipeExtracts
with encryption
for update
as
begin
	If Exists (Select * from Deleted Where RowID = 0)
	Begin
		Raiserror('Row Zero cannot be modified...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

checkpoint