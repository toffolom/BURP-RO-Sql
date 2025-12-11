use [BHP1-RO]
go

drop function [bhp].fn_RecipeTags;
go

create function [bhp].[fn_RecipeTags] (@rid bigint)
returns nvarchar(1000)
with encryption
as
begin
	Declare @tagid bigint;
	Declare @tags nvarchar(1000);
	Set @tagid = 0;
	While Exists (Select 1 
		From [bhp].BHPTagWords W
		Inner Join [bhp].Recipe_Tags R
		On (R.fk_TagID = W.RowID And R.fk_RecipeID = @rid)
		Where (W.RowID > @tagid)
	)
	Begin
		Select Top (1) 
			@tagid = R.fk_TagID, 
			@tags = Coalesce(@tags + ' ','') + W.[Name]
		From [bhp].BHPTagWords W
		Inner Join [bhp].Recipe_Tags R
		On (R.fk_TagID = W.RowID And R.fk_RecipeID = @rid)
		Where (W.RowID > @tagid) 
		Order by W.RowID;

	End
	Return Coalesce(@tags,N'no tag(s)...');
end
GO
print 'function:: [bhp].[fn_RecipeTags] created...';
go