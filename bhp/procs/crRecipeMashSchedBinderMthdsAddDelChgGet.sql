use [BHP1-RO]
go

begin try
	drop proc [bhp].GetMashSchedBinderRecs;
	print 'Proc: [bhp].GetMashSchedBinderRecs dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetMashSchedBinderRecs doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].GetRecipeMashSched;
	print 'Proc: [bhp].GetRecipeMashSched dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetRecipeMashSched doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].SetRecipeMashSchedBinder;
	print 'Proc: [bhp].SetRecipeMashSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].SetRecipeMashSchedBinder doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].DelRecipeMashSchedBinder;
	print 'Proc: [bhp].DelRecipeMashSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].DelRecipeMashSchedBinder doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].ChgRecipeMashSchedBinder;
	print 'Proc: [bhp].ChgRecipeMashSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].ChgRecipeMashSchedBinder doesn''t exist...no prob!!!';
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeMashSched (
	@SessID varchar(256),
	@RecipeID int
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where (RowID = @RecipeID))
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- non-existant recipe!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select * from [bhp].vw_RecipeMashScheduleBinder Where (RecipeID = @RecipeID);

	Return @@ERROR;
End
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetMashSchedBinderRecs (
	@SessID varchar(256)
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select * from [bhp].vw_RecipeMashScheduleBinder;

	Return @@ERROR;
End
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].SetRecipeMashSchedBinder (
	@SessID varchar(256),
	@RecipeID int,
	@SchedID int,
	@force bit = 1, -- if recipe already bound to a Mash sched...this'll wack that and then perform the insert...
	@BCastMode bit = 1, -- set to (0) if you don't wanna publish the burp event in this proc!!!
	@NuBinderID int output
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where (RowID = @RecipeID))
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- non-existant recipe!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @Force = ISNULL(@Force,1);

	if Exists (Select 1 from [bhp].RecipeMashSchedBinder WHere (fk_RecipeJrnlMstrID = @RecipeID) And (@force = 1))
	Begin
		Delete Top (1) [bhp].RecipeMashSchedBinder Where (fk_RecipeJrnlMstrID = @RecipeID);
	End
	Else
	Begin
		If Exists (Select 1 from [bhp].RecipeMashSchedBinder WHere (fk_RecipeJrnlMstrID = @RecipeID))
		Begin
			-- should write and audit record here...
			Set @rc = 66079; -- non-existant recipe!?
			Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
			Raiserror(@Mesg,16,1);
			Return @rc;
		End
	End

	Insert into [bhp].RecipeMashSchedBinder (fk_RecipeJrnlMstrID, fk_MashSchedMstrID)
	Values (@RecipeID, @SchedID);

	Set @NuBinderID = SCOPE_IDENTITY();

	--if (@BCastMode = 1)
	--Begin
	--	Exec @rc = [bhp].GenRecipeMashBinderEvntMesg @bid=@NuBinderID, @evnttype='add', @SessID=@SessID, @Mesg = @xml output;
	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;
	--End

	REturn @@ERROR;
End
Go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].ChgRecipeMashSchedBinder (
	@SessID varchar(256),
	@RowID int,
	@RecipeID int,
	@SchedID int,
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	DEclare @oldinfo Table (SchedID int, RecipeID int);
	Declare @oldSchedNm nvarchar(200);
	Declare @oldRecipeNm nvarchar(256);

	--Raiserror(N'proc: ChgRecipeMashSchedBinder:: @RowID:[%d] @RecipeID:[%d] @SchedID:[%d]',0,1,@RowID,@RecipeID,@SchedID);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where (RowID = @RecipeID))
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- non-existant recipe!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select 1 from [bhp].RecipeMashSchedBinder WHere (RowID = @RowID))
	Begin
		-- should write and audit record here...
		Set @rc = 66080; -- non-existant binder!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@RowID);
		Return @rc;
	End

	Update [bhp].RecipeMashSchedBinder
		Set
		fk_MashSchedMstrID = @SchedID,
		fk_RecipeJrnlMstrID = @RecipeID
	Output Deleted.fk_MashSchedMstrID, Deleted.fk_RecipeJrnlMstrID 
	into @oldinfo(SchedID, RecipeID)
	Where (RowID = @RowID);

	--if (@BCastMode = 1)
	--begin

	--	select @oldSchedNm = H.Name, @oldRecipeNm=R.Name 
	--	from @oldinfo O
	--	Inner Join [bhp].MashSchedMstr H On (O.SchedID = H.RowID)
	--	Inner Join [bhp].RecipeJrnlMstr R On (O.RecipeID = R.RowID);

	--	Exec @rc = [bhp].GenRecipeMashBinderEvntMesg @bid=@RowID, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldSchedNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sched_Info/b:Base/b:Name)[1]
	--	');

	--	set @xml.modify('
	--		declare namespace b="http://burp.net/recipe/evnts";
	--		insert attribute old {sql:variable("@oldRecipeNm")}
	--		into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info/b:Name)[1]
	--	');

	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;
	--end

	REturn @@ERROR;
End
Go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].DelRecipeMashSchedBinder (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select 1 from [bhp].RecipeMashSchedBinder WHere (RowID = @RowID))
	Begin
		-- should write and audit record here...
		Set @rc = 66077; -- non-existant binder!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--if (@BCastMode = 1)
	--	Exec @rc = [bhp].GenRecipeMashBinderEvntMesg @bid=@RowID, @evnttype='del', @SessID=@SessID, @Mesg = @xml output;
	
	--Delete Top (1) [bhp].RecipeMashSchedBinder Where (RowID = @RowID);
	-- maintain some association at the binder level to the (0) schedule till its defined.
	update [bhp].RecipeMashSchedBinder 
		Set fk_MashSchedMstrID = 0
	Where (RowID = @RowID);
	
	--if (@BCastMode = 1)
	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;

	REturn @@ERROR;
End
Go

checkpoint
go