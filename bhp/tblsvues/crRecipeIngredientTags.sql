use [BHP1-RO]
go

if object_id(N'[bhp].[RecipeIngredient_Tags]',N'U') is not null
begin
	drop Table [bhp].RecipeIngredient_Tags;
	print 'table:: [bhp].[RecipeIngredient_Tags] dropped!!!';
end
go

Create Table [bhp].RecipeIngredient_Tags (
	RowID bigint not null identity(1,1),
	fk_RecipeIngredient bigint not null,
	fk_TagID bigint not null,
	Constraint PK_ReccipeIngredient_Tags_RowID primary key nonclustered(RowID)
);
go
print 'table:: [bhp].RecipeIngrediet_Tags created...';
go

alter table [bhp].RecipeIngredient_Tags add 
constraint FK_RecipeIngredientTags_Ingredient
foreign key (fk_RecipeIngredient) references [bhp].RecipeIngredients (RowID),
constraint FK_RecipeIngredientTags_Tag
foreign key (fk_TagID) references [bhp].BHPTagWords (RowID);
go
print 'foreign key constraint(s) added to [bhp].RecipeIngredient_Tags tbl...';
go