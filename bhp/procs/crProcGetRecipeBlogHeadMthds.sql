USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetRecipeBlogHead]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetRecipeBlogHead]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetRecipeBlogHead];
Print 'Proc:: [bhp].GetRecipeBlogHead dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[SetRecipeBlogHead]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[SetRecipeBlogHead]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[SetRecipeBlogHead];
Print 'Proc:: [bhp].SetRecipeBlogHead dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgRecipeBlogHead]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgRecipeBlogHead]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgRecipeBlogHead];
Print 'Proc:: [bhp].ChgRecipeBlogHead dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgRecipeBlogHead]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelRecipeBlogHead]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelRecipeBlogHead];
Print 'Proc:: [bhp].DelRecipeBlogHead dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeBlogHead (
	@SessID varchar(256),
	@RecipeID int
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
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
		M.[RowID],
		M.[Name],
		M.[fk_RecipeJrnlMstrID],
		R.[Name] as RecipeName,
		ISNULL(M.[TotPosts], 0) As [TotPosts],
		M.[EnteredOn]
	FROM [bhp].RecipeBlogMstr M
	INNER Join [bhp].RecipeJrnlMstr R On (M.fk_RecipeJrnlMstrID = R.RowID)
	Where (R.RowID = @RecipeID);
	
	Return 0;
end
go

/*
execute as user = 'BHPApp';
exec bhp.GetRecipeBlogHead @SessID='00000000-0000-0000-0000-000000000000', @RecipeID=3;
revert;

*/

print 'Proc:: [bhp].GetRecipeBlogHead created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].SetRecipeBlogHead (
	@SessID varchar(256),
	@RecipeID int,
	@Name nvarchar(200),
	@Force bit = 1, -- default is that if a blog head is already setup...wack it.  if not..raiserror
	@HeadID int output -- generated rowid value
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	--Declare @admuid bigint;
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

	If Not Exists (Select * from [bhp].RecipeJrnlMstr Where (RowID = @RecipeID))
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- non-existant recipe!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @Force = ISNULL(@Force,1);

	/*
	** if force is 'on'...clean-out any blog rec(s) for this recipe!!!!
	*/
	If (@Force = 1)
	Begin

		Delete [bhp].BlogPostLinks
		From [bhp].BlogPostLinks BPL
		Inner Join [bhp].RecipeBlogPosts RBP On (BPL.fk_BlogPostID = RBP.RowID)
		Inner Join [bhp].RecipeBlogMstr RBM On (RBP.fk_RecipeBlogMstrID = RBM.RowID And RBM.fk_RecipeJrnlMstrID = @RecipeID);

		Delete [bhp].BlogPostComments
		From [bhp].BlogPostComments BPC
		Inner Join [bhp].RecipeBlogPosts RBP On (BPC.fk_BlogPostID = RBP.RowID)
		Inner Join [bhp].RecipeBlogMstr RBM On (RBP.fk_RecipeBlogMstrID = RBM.RowID And RBM.fk_RecipeJrnlMstrID = @RecipeID);
		
		Delete [bhp].RecipeBlogPosts 
		From [bhp].RecipeBlogPosts RBC 
		Inner Join [bhp].RecipeBlogMstr RBM On (RBM.fk_RecipeJrnlMstrID = @RecipeID And RBC.fk_RecipeBlogMstrID = RBM.RowID);

		Delete [bhp].RecipeBlogMstr Where (fk_RecipeJrnlMstrID = @RecipeID);
	End
	Else -- test that blog doesnt exist already...if so...raiserror and get outta here
	Begin
		If Exists (Select * from [bhp].RecipeBlogMstr Where (fk_RecipeJrnlMstrID = @RecipeID))
		Begin
			-- should write and audit record here...
			Set @rc = 66075; -- blog already established...parameter @force not set to (1)
			Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
			Raiserror(@Mesg,16,1);
			Return @rc;
		End
	End
	
	Insert into [bhp].RecipeBlogMstr ([Name], fk_RecipeJrnlMstrID, TotPosts, EnteredOn)
	Values (@Name, @RecipeID, 0, Getdate());
	
	Set @HeadID = Scope_Identity();
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].SetRecipeBlogHead created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelRecipeBlogHead (
	@SessID varchar(256),
	@RowID int, -- unique identifier of row to delete (primary key value).
	@rmAll bit = 1 -- this'll issue all the corresponding del stmts on foreign keys!!!
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
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
	
	If Exists (
		Select *
		From [bhp].BlogPostComments BPC
		Inner Join [bhp].RecipeBlogPosts RBP On (BPC.fk_BlogPostID = RBP.RowID)
		Inner Join [bhp].RecipeBlogMstr RBM On (RBP.fk_RecipeBlogMstrID = RBM.RowID And RBM.RowID = @RowID And ISNULL(@rmAll,1) = 0)
	)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66088; -- param @rmAll not set to (1)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (
		Select *
		From [bhp].RecipeBlogPosts RBP
		Inner Join [bhp].RecipeBlogMstr RBM On (RBP.fk_RecipeBlogMstrID = RBM.RowID And RBM.RowID = @RowID And ISNULL(@rmAll,1) = 0)
	)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66088; -- param @rmAll not set to (1)
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	/*
	** Okay...this far...remove everything!!!
	*/
	Delete [bhp].BlogPostLinks
	From [bhp].BlogPostLinks BPL
	Inner Join [bhp].RecipeBlogPosts RBP On (BPL.fk_BlogPostID = RBP.RowID)
	Inner Join [bhp].RecipeBlogMstr RBM On (RBM.RowID = RBP.fk_RecipeBlogMstrID And RBM.RowID = @RowID);

	Delete [bhp].BlogPostComments
	From [bhp].BlogPostComments BPC
	Inner Join [bhp].RecipeBlogPosts RBP On (BPC.fk_BlogPostID = RBP.RowID)
	Inner Join [bhp].RecipeBlogMstr RBM On (RBP.fk_RecipeBlogMstrID = RBM.RowID And RBM.RowID = @RowID);

	Delete [bhp].RecipeBlogPosts
	From [bhp].RecipeBlogPosts RBP
	Inner Join [bhp].RecipeBlogMstr RBM On (RBP.fk_RecipeBlogMstrID = RBM.RowID And RBM.RowID = @RowID);

	Delete [bhp].RecipeBlogMstr Where (RowID = @RowID);
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelRecipeBlogHead created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
**
** NOTE: we can only change the blog head name!!!
** maybe the totPosts...but that should be done in admin mode
*/
Create Proc [bhp].ChgRecipeBlogHead (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(200),
	@RecipeID int = null
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @revisedBy bigint;
	--Declare @admuid bigint;
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

	If (@RowID Is Null)
	Begin
		Raiserror('Parameter:[@RowID] must be provided...aborting!!!',16,1);
		Return -1;
	End
	


	--exec [di].[GetEnv] @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

	--if (@admuid = 0)
	--	raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

	--Select @revisedBy = fk_CustID From [di].SessionMstr Where (SessID = convert(uniqueidentifier,@SessID));

	--Set @revisedBy = ISNULL(@revisedBy,0);

	--set @revisedBy = 
	--	case ISNULL(@revisedBy,0) when 0 then @admuid 
	--	else @revisedBy 
	--	end;
	
	Update [bhp].RecipeBlogMstr
		Set
			Name = ISNULL(@Name, [Name]),
			fk_RecipeJrnlMstrID = ISNULL(@RecipeID, fk_RecipeJrnlMstrID)
	Where (RowID = @RowID);
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgRecipeBlogHead created...';
go

checkpoint
go