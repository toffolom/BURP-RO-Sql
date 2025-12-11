USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_BrewerCommentary_BrewerID]') AND parent_object_id = OBJECT_ID(N'[bhp].[BrewerCommentary]'))
ALTER TABLE [bhp].[BrewerCommentary] DROP CONSTRAINT [FK_BrewerCommentary_BrewerID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_BrewerCommentary_RecipeID]') AND parent_object_id = OBJECT_ID(N'[bhp].[BrewerCommentary]'))
ALTER TABLE [bhp].[BrewerCommentary] DROP CONSTRAINT [FK_BrewerCommentary_RecipeID]
GO

/****** Object:  Table [bhp].[BrewerCommentary]    Script Date: 02/17/2011 13:29:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[BrewerCommentary]') AND type in (N'U'))
DROP TABLE [bhp].[BrewerCommentary]
GO



create table [bhp].BrewerCommentary (
	RowID int identity(1,1) not null,
	fk_RecipeJrnlMstrID int not null,
	fk_BrewerID bigint not null, -- foreign key to [di].CustMstr where roleBitMask & 'Brewer' is true
	CreatedOn datetime not null,
	Commentary nvarchar(4000) not null,
	Fk_DeployInfo int not null,
	Constraint PK_BrewerCommentary_RowID primary key nonclustered (RowID)
)
go

create unique clustered index IDX_BrewerCommentary_IDS
on [bhp].BrewerCommentary (CreatedOn DESC, fk_BrewerID, fk_RecipeJrnlMstrID)
WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON);
go

alter table [bhp].BrewerCommentary add
constraint FK_BrewerCommentary_RecipeJrnlMstrID foreign key (fk_RecipeJrnlMstrID) references [bhp].RecipeJrnlMstr (RowID),
constraint FK_BrewerCommentary_BrewerID foreign key (fk_BrewerID) references [di].[CustMstr] (RowID),
Constraint FK_BrewerCommentary_DeployInfo Foreign Key (Fk_DeployInfo) References [di].[Deployments] (RowID);
go

set identity_insert [bhp].BrewerCommentary on;
insert into [bhp].BrewerCommentary (RowID, fk_RecipeJrnlMstrID, fk_BrewerID, CreatedOn, Fk_DeployInfo, Commentary)
select 0,0,0,0,0,'dummy entry...do not remove!!!';
set identity_insert [bhp].BrewerCommentary off;
go



create trigger [bhp].BrewerCommentary_Del_99 on [bhp].BrewerCommentary 
with encryption
for delete
as
begin
	If Exists (select * from deleted where (RowID = 0))
	Begin
		Raiserror('Brewer Commentary record ''zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

checkpoint