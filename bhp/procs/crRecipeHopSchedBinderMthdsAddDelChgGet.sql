use [BHP1-RO]
go

begin try
	drop proc [bhp].GetHopSchedBinderRecs;
	print 'Proc: [bhp].GetHopSchedBinderRecs dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetHopSchedBinderRecs doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].GetRecipeHopSched;
	print 'Proc: [bhp].GetRecipeHopSched dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetRecipeHopSched doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].SetRecipeHopSchedBinder;
	print 'Proc: [bhp].SetRecipeHopSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].SetRecipeHopSchedBinder doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].DelRecipeHopSchedBinder;
	print 'Proc: [bhp].DelRecipeHopSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].DelRecipeHopSchedBinder doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].ChgRecipeHopSchedBinder;
	print 'Proc: [bhp].ChgRecipeHopSchedBinder dropped!!!';
end try
begin catch
	print 'proc: [bhp].ChgRecipeHopSchedBinder doesn''t exist...no prob!!!';
end catch
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeHopSched (
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

	Select * from [bhp].vw_RecipeHopScheduleBinder Where (RecipeID = @RecipeID);

	Return @@ERROR;
End
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetHopSchedBinderRecs (
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

	Select * from [bhp].vw_RecipeHopScheduleBinder;

	Return @@ERROR;
End
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].SetRecipeHopSchedBinder (
	@SessID varchar(256),
	@RecipeID int,
	@SchedID int,
	@force bit = 1, -- if recipe already bound to a hop sched...this'll wack that and then perform the insert...
	@NuBinderID int output,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @Tbl Table ([ID] int);
	
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

	if Exists (Select 1 from [bhp].RecipeHopSchedBinder WHere (fk_RecipeJrnlMstrID = @RecipeID) And (@force = 1))
	Begin
		Delete Top (1) [bhp].RecipeHopSchedBinder Where (fk_RecipeJrnlMstrID = @RecipeID);
	End
	Else
	Begin
		If Exists (Select 1 from [bhp].RecipeHopSchedBinder WHere (fk_RecipeJrnlMstrID = @RecipeID))
		Begin
			-- should write and audit record here...
			Set @rc = 66076; -- wack bit not 'on' and recipe already bound to a sched...abort!!!
			Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
			Raiserror(@Mesg,16,1);
			Return @rc;
		End
	End

	Insert into [bhp].RecipeHopSchedBinder (fk_RecipeJrnlMstrID, fk_HopSchedMstrID)
	Output Inserted.RowID Into @Tbl
	Values (@RecipeID, @SchedID);

	Select @NuBinderID = [ID] From @Tbl;

	--if (@BCastMode = 1 And @SchedID > 0)
	--Begin
	--	Exec [bhp].GenRecipeHopBinderEvntMesg @bid=@NuBinderID, @evnttype='add', @sessid=@SessID, @mesg = @xml output;
	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;
	--End

	REturn @@ERROR;
End
Go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].ChgRecipeHopSchedBinder (
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
	--Declare @xml xml;
	--DEclare @oldinfo Table (SchedID int, RecipeID int);
	--Declare @oldSchedNm nvarchar(200);
	--Declare @oldRecipeNm nvarchar(256);

	--Raiserror(N'proc: ChgRecipeHopSchedBinder:: @RowID:[%d] @RecipeID:[%d] @SchedID:[%d]',0,1,@RowID,@RecipeID,@SchedID);
	
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

	If Not Exists (Select * from [bhp].HopSchedMstr Where (RowID = @SchedID))
	Begin
		-- should write and audit record here...
		Set @rc = 66020; -- non-existant schedule!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@SchedID);
		Return @rc;
	End

	If Not Exists (Select 1 from [bhp].RecipeHopSchedBinder WHere (RowID = @RowID))
	Begin
		-- should write and audit record here...
		Set @rc = 66077; -- non-existant binder!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@RowID);
		Return @rc;
	End

	Update [bhp].RecipeHopSchedBinder
		Set
		fk_HopSchedMstrID = @SchedID,
		fk_RecipeJrnlMstrID = @RecipeID
	--Output Deleted.fk_HopSchedMstrID, Deleted.fk_RecipeJrnlMstrID 
	--into @oldinfo(SchedID, RecipeID)
	Where (RowID = @RowID); 

	--select @oldSchedNm = H.Name, @oldRecipeNm=R.Name 
	--from @oldinfo O
	--Inner Join [bhp].HopSchedMstr H On (O.SchedID = H.RowID)
	--Inner Join [bhp].RecipeJrnlMstr R On (O.RecipeID = R.RowID);

	--if (@BCastMode = 1)
	--Begin

	--	Exec [bhp].GenRecipeHopBinderEvntMesg @bid=@RowID, @evnttype='chg', @sessid=@SessID, @mesg = @xml output;

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

	--End

	REturn @@ERROR;
End
Go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].DelRecipeHopSchedBinder (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1
)
with encryption
as
begin

	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @xml xml;
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select 1 from [bhp].RecipeHopSchedBinder WHere (RowID = @RowID))
	Begin
		-- should write and audit record here...
		Set @rc = 66077; -- non-existant binder!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--if (@BCastMode = 1)
	--	Exec [bhp].GenRecipeHopBinderEvntMesg @bid=@RowID, @evnttype='del', @sessid=@SessID, @mesg = @xml output;
	
	-- we don't remove the binder entry...but rather...map it to the 'pls select...' (row - 0) binding!!!
	Update [bhp].RecipeHopSchedBinder
		Set fk_HopSchedMstrID = 0
	Where (RowID = @RowID);
	
	--if (@BCastMode = 1)
	--	Exec [bhp].SendBurpRecipeMesg @msg = @xml;

	REturn @@ERROR;
End
Go