use [BHP1-RO]
go

begin try
	drop proc [bhp].GetRecipeTags;
	print 'proc: [bhp].GetRecipeTags dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].GetRecipeTags doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].AddRecipeTag;
	print 'proc: [bhp].AddRecipeTag dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].AddRecipeTag doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].DelRecipeTag;
	print 'proc: [bhp].DelRecipeTag dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].DelRecipeTag doesn''t exist...no prob!!!',0,1);
end catch
go

begin try
	drop proc [bhp].ChgRecipeTag;
	print 'proc: [bhp].ChgRecipeTag dropped!!!';
end try
begin catch
	raiserror(N'proc: [bhp].ChgRecipeTag doesn''t exist...no prob!!!',0,1);
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeTags (
	@SessID varchar(256),
	@RecipeID int
)
with encryption
as
begin

	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @status bit;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@Rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	SELECT 
		RT.RowID,
		RT.fk_RecipeID As RecipeID,
		RT.fk_TagID As TagID,
		W.Name As Word
	FROM [bhp].RecipeJrnlMstr M
	Inner join [bhp].Recipe_Tags RT ON (M.RowID = RT.fk_RecipeID And M.RowID = @RecipeID)
	Inner Join [bhp].BHPTagWords W On (RT.fk_TagID = W.RowID)
	Full Outer Join [bhp].GCTagWords GC On (W.Name = GC.Tag)
	Where GC.Tag is null;

	return @@ERROR;
end
go

create proc [bhp].AddRecipeTag (
	@SessID varchar(256),
	@RecipeID int,
	@TagID bigint,
	@RowID bigint output,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @status bit;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@Rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].BHPTagWords Where RowID = @TagID)
	Begin
		-- should write and audit record here...
		Set @rc = 66085; -- unkn bhp tag word id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where (RowID = @RecipeID))
	Begin
		-- should write and audit record here...
		Set @rc = 66105; -- can't find reference up to the parent here...so i can avoid a nasty sql ref integrity error!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@RecipeID);
		Return @rc;
	End
	
	insert into [bhp].Recipe_Tags(fk_RecipeID, fk_TagID)
	values (@RecipeID, @TagID);

	Set @RowID = SCOPE_IDENTITY();

	--if (@BCastMode = 1)
	--begin
	--	Exec @rc = [bhp].GenRecipeTagMesg @rowid=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;
	--end

	return @@ERROR;
end
go

create proc [bhp].DelRecipeTag (
	@SessID varchar(256),
	@RowID bigint,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @status bit;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@Rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--if (@BCastMode = 1)
	--	Exec @rc = [bhp].GenRecipeTagMesg @rowid=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @xml output;
	
	Delete Top (1) [bhp].Recipe_Tags Where (RowID = @RowID);
	
	--if (@BCastMode = 1)
	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;

	return @@ERROR;
end
go

create proc [bhp].ChgRecipeTag (
	@SessID varchar(256),
	@RowID bigint,
	@RecipeID bigint,
	@TagID bigint,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @xml xml;
	--Declare @info Table (tagID bigint); -- grab the old ingredient tag word id.
	--Declare @oldWord nvarchar(100);
	Declare @status bit;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@Rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].BHPTagWords Where RowID = @TagID)
	Begin
		-- should write and audit record here...
		Set @rc = 66085; -- unkn bhp tag word id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Update [bhp].Recipe_Tags
		Set
			fk_RecipeID = @RecipeID,
			fk_TagID = @TagID
	--Output Deleted.fk_TagID into @info(tagID)
	Where (RowID = @RowID);

	--if (@BCastMode = 1)
	--begin
	--	select @oldWord=I.Name
	--	from @info O
	--	Inner Join [bhp].BHPTagWords I On (I.RowID = O.tagID);

	--	Exec @rc = [bhp].GenRecipeTagMesg @rowid=@RowID, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;
		
	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldWord")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Tags/b:Tag/b:Value)[1]
	--	');

	--	Exec [bhp].SendBurpRecipeMesg @msg=@xml;
	--end

	return @@ERROR;
end
go

checkpoint
go