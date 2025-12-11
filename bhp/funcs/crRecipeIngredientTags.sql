use [BHP1-RO]
go

drop function [bhp].[fn_RecipeIngredientTags];
go

/*
** this lil guy will return a flatten listing of any bhptags associated w/this ingredient
** the param @ririd is 'recipe ingredient row id' from [bhp].RecipeIngredients tbl
*/
create function [bhp].[fn_RecipeIngredientTags] (@ririd bigint)
returns nvarchar(1000)
with encryption
as
begin
	Declare @tagid bigint;
	Declare @tags nvarchar(1000);
	Set @tagid = 0;
	While Exists (Select 1 
		From [bhp].BHPTagWords W
		Inner Join [bhp].RecipeIngredient_Tags R
		On (R.fk_TagID = W.RowID And R.fk_RecipeIngredient = @ririd)
		Where (W.RowID > @tagid)
	)
	Begin
		Select Top (1) 
			@tagid = R.fk_TagID, 
			@tags = Coalesce(@tags + ' ','') + W.[Name]
		From [bhp].BHPTagWords W
		Inner Join [bhp].RecipeIngredient_Tags R
		On (R.fk_TagID = W.RowID And R.fk_RecipeIngredient = @ririd)
		Where (W.RowID > @tagid) 
		Order by W.RowID;

	End
	Return Coalesce(@tags,N'no tag(s)...');
end
GO
print 'function:: [bhp].[fn_RecipeIngredientTags] created...';
go