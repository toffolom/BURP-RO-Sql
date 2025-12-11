use [BHP1-RO]
go

if object_id('[bhp].[Recipe_Tags]',N'U') IS NOT NULL
Begin
	Drop Table [bhp].[Recipe_Tags];
	Print 'Table:: [bhp].[Recipe_Tags] dropped!!!';
End
go

Create Table [bhp].Recipe_Tags (
	RowID bigint not null identity(1,1),
	fk_RecipeID int not null,
	fk_TagID bigint not null,
	Constraint PK_Recipe_Tags_RowID primary key nonclustered(RowID)
);
go
print 'table:: [bhp].Recipe_Tags created...';
go

alter table [bhp].Recipe_Tags add 
constraint FK_RecipeTags_RecipeID foreign key (fk_RecipeID) references [bhp].RecipeJrnlMstr (RowID),
constraint FK_RecipeTags_TagID foreign key (fk_TagID) references [bhp].BHPTagWords (RowID);
go
print 'foreign key constraint(s) added to [bhp].Recipe_Tags tbl...';
go