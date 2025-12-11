use [BHP1-RO]
go

begin try
	drop proc [bhp].GetAgingSchedBinderRecs;
	print 'Proc: [bhp].GetAgingSchedBinderRecs dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetAgingSchedBinderRecs doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].GetRecipeAgingSched;
	print 'Proc: [bhp].GetRecipeAgingSched dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetRecipeAgingSched doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].SetRecipeAgingSchedBinder;
	print 'Proc: [bhp].SetRecipeAgingSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].SetRecipeAgingSchedBinder doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].DelRecipeAgingSchedBinder;
	print 'Proc: [bhp].DelRecipeAgingSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].DelRecipeAgingSchedBinder doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].ChgRecipeAgingSchedBinder;
	print 'Proc: [bhp].ChgRecipeAgingSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].ChgRecipeAgingSchedBinder doesn''t exist...no prob!!!';
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeAgingSched (
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

	Select * from [bhp].vw_RecipeAgingScheduleBinder Where (RecipeID = @RecipeID);

	Return @@ERROR;
End
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetAgingSchedBinderRecs (
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

	Select * from [bhp].vw_RecipeAgingScheduleBinder;

	Return @@ERROR;
End
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].SetRecipeAgingSchedBinder (
	@SessID varchar(256),
	@RecipeID int,
	@SchedID int,
	@force bit = 1, -- if recipe already bound to a Mash sched...this'll wack that and then perform the insert...
	@BCastMode bit = 1, -- set to (0) if you don't wanna publish the burp event assoc w/this proc...
	@NuBinderID int output
)
with encryption
as
begin

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

	if Exists (Select 1 from [bhp].RecipeAgingSchedBinder WHere (fk_RecipeJrnlMstrID = @RecipeID) And (@force = 1))
	Begin
		Delete Top (1) [bhp].RecipeAgingSchedBinder Where (fk_RecipeJrnlMstrID = @RecipeID);
	End
	Else
	Begin
		If Exists (Select 1 from [bhp].RecipeAgingSchedBinder WHere (fk_RecipeJrnlMstrID = @RecipeID))
		Begin
			-- should write and audit record here...
			Set @rc = 66079; -- non-existant recipe!?
			Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
			Raiserror(@Mesg,16,1);
			Return @rc;
		End
	End

	Insert into [bhp].RecipeAgingSchedBinder (fk_RecipeJrnlMstrID, fk_AgingSchedMstrID)
	Values (@RecipeID, @SchedID);

	Set @NuBinderID = SCOPE_IDENTITY();

	--if (@BCastMode = 1 And @SchedID > 0)
	--Begin
	--	Exec [bhp].GenRecipeAgingBinderEvntMesg @bid=@NuBinderID, @evnttype='add', @sessid=@SessID, @mesg = @xml output;
	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;
	--End

	REturn @@ERROR;
End
Go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].ChgRecipeAgingSchedBinder (
	@SessID varchar(256),
	@RowID int,
	@RecipeID int,
	@SchedID int,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	DEclare @oldinfo Table (SchedID int, RecipeID int);
	Declare @oldSchedNm nvarchar(200);
	Declare @oldRecipeNm nvarchar(256);


	--Raiserror(N'proc: ChgRecipeAgingSchedBinder:: @RowID:[%d] @RecipeID:[%d] @SchedID:[%d]',0,1,@RowID,@RecipeID,@SchedID);
	
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

	If Not Exists (Select 1 from [bhp].RecipeAgingSchedBinder WHere (RowID = @RowID))
	Begin
		-- should write and audit record here...
		Set @rc = 66086; -- non-existant binder!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@RowID);
		Return @rc;
	End

	Update [bhp].RecipeAgingSchedBinder
		Set
		fk_AgingSchedMstrID = @SchedID,
		fk_RecipeJrnlMstrID = @RecipeID
	--Output Deleted.fk_AgingSchedMstrID, Deleted.fk_RecipeJrnlMstrID 
	--into @oldinfo(SchedID, RecipeID)
	Where (RowID = @RowID);

	--if (@BCastMode = 1)
	--begin
	--	select @oldSchedNm = H.Name, @oldRecipeNm=R.Name 
	--	from @oldinfo O
	--	Inner Join [bhp].AgingSchedMstr H On (O.SchedID = H.RowID)
	--	Inner Join [bhp].RecipeJrnlMstr R On (O.RecipeID = R.RowID);

	--	Exec [bhp].GenRecipeAgingBinderEvntMesg @bid=@RowID, @evnttype='chg', @sessid=@SessID, @mesg = @xml output;
		
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
create proc [bhp].DelRecipeAgingSchedBinder (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1
)
with encryption
as
begin

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

	If Exists (Select 1 from [bhp].RecipeAgingSchedBinder WHere (RowID = @RowID))
	Begin
		-- should write and audit record here...
		Set @rc = 66077; -- non-existant binder!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Delete Top (1) [bhp].RecipeAgingSchedBinder Where (RowID = @RowID);
	-- we need to maintain an association between a recipe and an aging schedule. Set to (0) is just a place holder 
	-- till it is defined.

	--if (@BCastMode = 1)
	--	Exec [bhp].GenRecipeAgingBinderEvntMesg @bid=@RowID, @evnttype='del', @sessid=@SessID, @mesg = @xml output;
	
	update [bhp].RecipeAgingSchedBinder
		set fk_AgingSchedMstrID = 0
	Where (RowID = @RowID);
	
	--if (@BCastMode = 1)
	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;

	REturn @@ERROR;
End
Go