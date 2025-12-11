use [BHP1-RO]
go

drop view [bhp].[vw_RecipeIngredientTags];
go


create view [bhp].vw_RecipeIngredientTags (
	RowID, RecipeID, RecipeName, Phrase, TagID, TagVal
)
--with encryption
as

	Select 
		RI.RowID, 
		RI.fk_RecipeJrnlMstrID,
		R.[Name],
		RI.Phrase,
		RT.fk_TagID,
		ST.Name
	From [bhp].RecipeIngredients RI
	Inner Join [bhp].RecipeIngredient_Tags RT On (RI.RowID = RT.fk_RecipeIngredient)
	Inner Join [bhp].BHPTagWords ST On (RT.fk_TagID = ST.RowID)
	Inner Join [bhp].RecipeJrnlMstr R On (RI.fk_RecipeJrnlMstrID = R.RowID)
	Full Outer Join [bhp].GCTagWords GC On (ST.Name = GC.Tag)
	Where GC.Tag is null;

go
print 'view:: [bhp].vw_RecipeIngredientTags created...';
go