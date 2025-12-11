USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetRecipeBlogPosts]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetRecipeBlogPosts]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetRecipeBlogPosts];
Print 'Proc:: [bhp].GetRecipeBlogPosts dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddRecipeBlogPost]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddRecipeBlogPost]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddRecipeBlogPost];
Print 'Proc:: [bhp].AddRecipeBlogPost dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgRecipeBlogPost]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgRecipeBlogPost]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgRecipeBlogPost];
Print 'Proc:: [bhp].ChgRecipeBlogPost dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgRecipeBlogPost]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelRecipeBlogPost]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelRecipeBlogPost];
Print 'Proc:: [bhp].DelRecipeBlogPost dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetRecipeBlogPosts (
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
		P.[RowID],
		P.[fk_RecipeBlogMstrID],
		M.Name As [Head],
		P.[EnteredOn],
		P.[BlogPost] As [Post],
		P.[fk_PostedByID],
		C.BHPUid As PostedBy,
		ISNULL(P.TotLikeIt,0) As TotLikes,
		ISNULL(P.TotDontLike,0) As TotDontLikes,
		ISNULL(P.TotIndiff,0) As TotIndiffs,
		ISNULL(P.HasEmbeddedLinks,0) As HasLinks,
		ISNULL(P.HasSpam,0) As HasSpam,
		ISNULL(P.Hide,0) As [Hidden],
		ISNULL(P.fk_BlogPostCategory,0) As fk_BlogPostCategory,
		BPC.Name As Category,
		P.Title
	FROM [bhp].RecipeBlogPosts AS P 
	Inner Join [bhp].RecipeBlogMstr M On (P.fk_RecipeBlogMstrID = M.RowID)
	Inner Join [bhp].RecipeJrnlMstr RJ On (M.fk_RecipeJrnlMstrID = RJ.RowID)
	Inner Join [bhp].BlogPostCategories BPC On (P.fk_BlogPostCategory = BPC.RowID)
	Inner Join [di].CustMstr C On (P.fk_PostedByID = C.RowID)
	Where (RJ.RowID = @RecipeID And [di].[fn_IsNull](P.[BlogPost]) IS NOT NULL)
	Order By P.EnteredOn; -- And ISNULL(P.Hide,0) = 1);
	
	Return 0;
end
go

print 'Proc:: [bhp].GetRecipeBlogPosts created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddRecipeBlogPost (
	@SessID varchar(256),
	@fk_RecipeBlogMstrID int,
	@Post nvarchar(4000),
	@CreatedBy bigint,
	@HasLinks bit = 0,
	@HasSpam bit = 0,
	@IsHidden bit = 0,
	@fk_Category int = null,
	@title varchar(200),
	@NuPostID int output -- generated rowid value
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	declare @admuid bigint;
	Declare @undefCat int;
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

	If Not Exists (Select * from [di].CustMstr Where (RowID = @CreatedBy))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66018; -- the customer doesn't exist!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].BlogPostCategories Where RowID = ISNULL(@fk_Category,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66089; -- this nbr represents unknown blog posting category
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	exec [di].[GetEnv] @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

	if (@admuid = 0)
		raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

	set @CreatedBy = 
		case ISNULL(@CreatedBy,0) when 0 then @admuid 
		else @CreatedBy 
		end;
	
	-- try to find a 'undefined' category entry...
	Select @undefCat = [RowID] from [bhp].BlogPostCategories
	WHere (left([Name],5) = 'Undef') or ([Name] = 'unset') or ([Name] = 'not set') or ([Name] = 'n/a');

	--TODO: post mesg into Que regarding a new posting for the given category...so subscribers can recv
	-- notification(s) of a posting in a category their interested in...
	Insert into [bhp].RecipeBlogPosts (
		fk_RecipeBlogMstrID,
		EnteredOn,
		BlogPost,
		fk_PostedByID,
		HasEmbeddedLinks,
		HasSpam,
		Hide,
		LastRevisedBy,
		LastRevisedOn,
		fk_BlogPostCategory,
		Title
	)
	Values 
	(
		@fk_RecipeBlogMstrID,
		GetDate(),
		@Post,
		@CreatedBy,
		ISNULL(@HasLinks,0),
		ISNULL(@HasSpam,0),
		ISNULL(@IsHidden,0),
		0,
		0,
		COALESCE(@fk_Category, @undefCat, 0),
		@title
	);
	
	Set @NuPostID = Scope_Identity();

	/*
	** this lil C# sql srvr extension (xfn_*) routine will regex the post and retrieve a list of all the embedded links
	*/
	--insert into [bhp].BlogPostLinks (fk_BlogPostID, [Link], [LinkTyp])
	--select @NuPostID, [Link], [Type]
	--FROM [master].[bhp].[xfn_GetBlogLinks] (@Post);

	-- if anything was written...update status to reflect that we've got links embedded!!!
	--if exists (Select * from [bhp].BlogPostLinks Where (fk_BlogPostID = @NuPostID))
	--Begin

	--	update [bhp].RecipeBlogPosts
	--		set HasEmbeddedLinks = 1
	--	Where (RowID = @NuPostID);

	--	-- todo: need to post a mesg to queue that a post has links...kick off a crawler to verify links are good!!!

	--End
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddRecipeBlogPost created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelRecipeBlogPost (
	@SessID varchar(256),
	@RowID int -- unique identifier of row to delete (primary key value).
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

	Delete [bhp].BlogPostLinks Where (fk_BlogPostID = @RowID);

	Delete [bhp].BlogPostComments Where (fk_BlogPostID = @RowID);
	
	Delete Top (1) [bhp].RecipeBlogPosts Where (RowID = @RowID);
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelRecipeBlogPost created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgRecipeBlogPost (
	@SessID varchar(256),
	@RowID int,
	@Post nvarchar(4000),
	@HasLinks bit = 0,
	@HasSpam bit = 0,
	@IsHidden bit = 0,
	@fk_Category int = null,
	@title varchar(200)
)
with encryption
as
begin
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @revisedBy bigint;
	Declare @admuid bigint;
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
	


	If Not Exists (Select * from [bhp].BlogPostCategories Where RowID = ISNULL(@fk_Category,0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66089; -- this nbr represents unknown blog posting category
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	exec [di].[GetEnv] @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

	if (@admuid = 0)
		raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

	Select @revisedBy = fk_CustID From [di].SessionMstr Where (SessID = convert(uniqueidentifier,@SessID));

	Set @revisedBy = ISNULL(@revisedBy,0);

	set @revisedBy = 
		case @revisedBy when 0 then @admuid 
		else @revisedBy 
		end;
	
	Update [bhp].RecipeBlogPosts
		Set
			BlogPost = @Post,
			--HasEmbeddedLinks = ISNULL(@HasLinks, 0),
			HasSpam = ISNULL(@HasSpam, 0),
			[Hide] = ISNULL(@IsHidden, 0),
			LastRevisedBy = @revisedBy,
			LastRevisedOn = GETDATE(),
			fk_BlogPostCategory = ISNULL(@fk_Category, fk_BlogPostCategory),
			Title = @title
	Where (RowID = @RowID);

	/*
	** this lil C# sql srvr extension routine will regex the post and retrieve a list of all the embedded links
	*/
	--If Exists (select * FROM [master].[bhp].[xfn_GetBlogLinks](@Post))
	--Begin

	--	Delete [bhp].BlogPostLinks Where (fk_BlogPostID = @RowID);

	--	insert into [bhp].BlogPostLinks (fk_BlogPostID, [Link], [LinkTyp])
	--	select @RowID, [Link], [Type] 
	--	FROM [master].[bhp].[xfn_GetBlogLinks] (@Post);

	--End

	-- if anything was written...update status to reflect that we've got links embedded!!!
	--if exists (Select * from [bhp].BlogPostLinks Where (fk_BlogPostID = @RowID))
	--Begin

	--	update [bhp].RecipeBlogPosts
	--		set HasEmbeddedLinks = 1
	--	Where (RowID = @RowID);
		
	--	-- todo: need to post a mesg to queue that a post has links...kick off a crawler to verify links are good!!!
	--	-- and to datamine what links peeps are posting...

	--End
	
	Return @@ERROR;
End
go

Print 'Proc:: [bhp].ChgRecipeBlogPost created...';
go

checkpoint
go

/*
execute as user = 'BHPApp';
exec [bhp].GetRecipeBloghead @SessID='00000000-0000-0000-0000-000000000000',@RecipeID=2;
revert;


*/