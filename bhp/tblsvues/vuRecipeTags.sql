use [BHP1-RO]
go

drop view [bhp].vw_RecipeTags;
go

create view [bhp].vw_RecipeTags (
	RecipeID, RecipeName, Tags, TagID, TagVal
)
--with encryption
as

	Select 
		RJ.RowID, 
		RJ.[Name],
		RJ.Tags,
		RT.fk_TagID,
		ST.[Name]
	From [bhp].RecipeJrnlMstr RJ
	Inner Join [bhp].Recipe_Tags RT On (RJ.RowID = RT.fk_RecipeID)
	Inner Join [bhp].BHPTagWords ST On (RT.fk_TagID = ST.RowID)
	Full Outer Join [bhp].GCTagWords GC On (ST.Name = GC.Tag)
	Where GC.Tag is null;

go
print 'view:: [bhp].vw_RecipeTags created...';
go