use [BHP1-RO]
go

if object_id(N'[bhp].CloneRecipeV1',N'P') is not null
begin
	print 'proc:: [bhp].CloneRecipeV1 dropped!!!';
	drop proc [bhp].CloneRecipeV1;
end
go

begin try
	drop proc [bhp].GetCustRecipes;
	print 'Proc: [bhp].GetCustRecipes dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetCustRecipes doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].GetCustRecipe;
	print 'Proc: [bhp].GetCustRecipe dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetCustRecipe doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].AddCustRecipe;
	print 'Proc: [bhp].AddCustRecipe dropped!!!';
end try
begin catch
	print 'proc: [bhp].AddCustRecipe doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].DelCustRecipe;
	print 'Proc: [bhp].DelCustRecipe dropped!!!';
end try
begin catch
	print 'proc: [bhp].DelCustRecipe doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].ChgCustRecipe;
	print 'Proc: [bhp].ChgCustRecipe dropped!!!';
end try
begin catch
	print 'proc: [bhp].ChgCustRecipe doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].EstablishRecipeBlog;
	print 'Proc: [bhp].EstablishRecipeBlog dropped!!!';
end try
begin catch
	print 'proc: [bhp].EstablishCustRecipeBlog doesn''t exist...no prob!!!';
end catch
go

create proc [bhp].GetCustRecipe (
	@SessID varchar(256),
	@CustID bigint = null,
	@RecipeID int
)
with encryption, execute as 'sticky'
as
Begin
	--Set NoCount On;

	declare @rc int;
	declare @mesg nvarchar(2000);
	declare @admuid bigint;
	declare @rows int;
	declare @vccustid varchar(50);
	declare @isok bit;
	--declare @oncloud bit;
	declare @vccloud varchar(20);
	declare @isadmsess bit;
	declare @sql nvarchar(max);
	declare @status bit;

	if (1=0)
	Begin
		Select
			cast(null as int) as RowID,
			cast(Null as nvarchar(256)) as [RecipeName],
			cast(null as int) as [fk_BeerStyle],
			cast(null as nvarchar(200)) as [BeerStyle],
			cast(null as varchar(200)) as [CustomerChoosenBeerType],
			cast(null as bigint) as CustomerID,
			cast(null as nvarchar(200)) as CustomerName,
			cast(null as nvarchar(256)) as BHPUid,
			cast(null as numeric(6,2)) as TargetBatchSize,
			cast(null as int) as TargetBatchUOM,
			cast(null as numeric(6,2)) as TargetBoilSize,
			cast(null as int) as TargetBoilSizeUOM,
			cast(null as numeric(4,3)) as TargetOG,
			cast(null as numeric(4,3)) as TargetFG,
			cast(null as numeric(3,1)) as TargetABV,
			cast(null as numeric(6,3)) as TargetDensity,
			cast(null as int) as fk_TargetDensityUOM,
			cast(null as int) as TargetColor,
			cast(null as int) as fk_TargetColorUOM,
			cast(null as int) as TargetBitterness,
			cast(null as int) as fk_TargetBitternessUOM,
			cast(null as int) as SharingMask,
			cast(null as bit) as IsDraft,
			cast(null as int) as TotBatchesMade,
			cast(null as datetime) as EnteredOn,
			cast(null as nvarchar(200)) as BlogName,
			cast(null as int) as TotBlogComments,
			cast(null as int) as BlogLikes,
			cast(null as int) as BlogDontLikes,
			cast(null as int) as BlogIndiffs,
			cast(null as nvarchar(4000)) as [Notes],
			cast(null as int) as ClonedFromID
		Set fmtonly off;
		Return 0;
	End

	Set @rc = 0;
	set @vccustid = convert(varchar, @CustID);
	set @isadmsess = 0;

	--Raiserror(N'[bhp].GetCustRecipe:: cust:[%s] recipeid:[%d]...',0,1,@vccustid,@recipeid);
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Exec [di].GetEnv @VarNm='cloud context mode',@VarVal=@vccloud output,@DfltVal=0;
	--set @oncloud = [di].[fn_ISTRUE](@vccloud);

	If Not Exists (Select * from [di].CustMstr Where (RowID = @CustID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66018; -- the customer doesn't exist!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * from [di].SessionMstr Where (SessID=@SessID) And ([RowID]=0))
	Begin
		set @isadmsess = 1;

		exec [di].GetEnv @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

		if (@admuid = 0)
			raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

		--if (ISNULL(@CustID,0) = 0)
		--	set @CustID = @admuid;
	End

	/*
	** NOTE: this code is referenced in proc below (in this script file) called CloneRecipe!!!
	*/
	set @Sql = N'
SELECT 
	RJM.[RowID],
	RJM.[Name] As RecipeName,
	ISNULL(RJM.fk_BeerStyle,0) As fk_BeerStyle,
	ISNULL(RJM.BeerStyle,0) As BeerStyle,
	''N/A'' as [CustomerChoosenBeerType], --(select [bhp].[fn_RecipeStyleToStr](RJM.RowID)) As CustomerChoosenBeerType, -- cust can set their own beer style name...
	Case RJM.[fk_CreatedBy] When 0 then @InAdminID else RJM.[fk_CreatedBy] End As CustomerID, -- aka: customer id
	Case 
		When CM.DisplayAs IS NULL Then CM.[Name]
		When CM.Name != ISNULL(CM.DisplayAs,CM.Name) Then CM.DisplayAs
		Else CM.DisplayAs 
	End As CustomerName,
	CM.BHPUid,
	ISNULL(RJM.BatchQty, 5.0) As TargetBatchSize,
	case RJM.fk_BatchUOM when 0 then [bhp].fn_GetUOMIdByNm(''gal'') else RJM.fk_BatchUOM end As TargetBatchUOM,
	ISNULL(RJM.TargetBoilSize, 7) As TargetBoilSize,
	case RJM.fk_BoilSizeUOM when 0 then [bhp].fn_GetUOMIdByNm(''gal'') else RJM.fk_BoilSizeUOM End As TargetBoilSizeUOM,
	ISNULL(RJM.TargetOG,0) As TargetOG,
	ISNULL(RJM.TargetFG,0) As TargetFG,
	ISNULL(RJM.TargetABV,0) As TargetABV,
	ISNULL(RJM.TargetDensity,0) As TargetDensity,
	case RJM.fk_TargetDensityUOM when 0 then [bhp].fn_GetUOMIdByNm(''brix'') else RJM.fk_TargetDensityUOM end As fk_TargetDensityUOM,
	ISNULL(RJM.TargetColor,0) As TargetColor,
	case RJM.fk_TargetColorUOM When 0 then [bhp].fn_GetUOMIdByNm(''srm'') else RJM.fk_TargetColorUOM End As fk_TargetColorUOM,
	ISNULL(RJM.TargetBitterness,0) As TargetBitterness,
	case RJM.fk_TargetBitternessUOM When 0 then [bhp].fn_GetUOMIdByNm(''ibu'') else RJM.fk_TargetBitternessUOM End As fk_TargetBitternessUOM,
	RJM.SharingMask,
	ISNULL(RJM.[isDraft],1) As IsDraft,
	ISNULL(RJM.[totBatchesMade],0) As TotBatchesMade,
	RJM.[EnteredOn],
	ISNULL(RBM.Name,''blog not setup'') As [BlogName],
	ISNULL((select COUNT(*) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID And [Hide]=0)),0) As TotBlogComments,
	ISNULL((select SUM(TotLikeIt) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID And [Hide]=0)),0) As BlogLikes,
	ISNULL((select SUM(TotDontLike) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID And [Hide]=0)),0) As BlogDontLikes,
	ISNULL((select SUM(TotIndiff) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID And [Hide]=0)),0) As BlogIndiffs,
	ISNULL(RJM.Notes, ''no notes (yet)!!!'') As Notes,
	RJM.fk_ClonedFrom As ClonedFromID
	FROM [di].CustMstr CM
';
	if (@isadmsess = 1) -- if admin session...don't join into sess mstr cause the deployment id is wrong.
	Begin
		Set @Sql = @Sql + '
Inner Join [di].SessionMstr S On (S.SessID = @InSessID And CM.fk_DeployInfo = S.fk_DeployInfo)
Inner Join [bhp].RecipeJrnlMstr AS RJM On (CM.RowID = RJM.fk_CreatedBy And CM.fk_DeployInfo = RJM.fk_DeployInfo)
Left Join [bhp].RecipeBlogMstr As RBM On (RBM.fk_RecipeJrnlMstrID = RJM.RowID)
--Left Join [bhp].ProductionRqstLog PL On (PL.Fk_RecipeID = RJM.RowID And PL.[Status] = ''accepted'')
Where ((CM.RowID = @InCustID or CM.RowID = @InAdminID) And RJM.RowID = @InRecipeID);
';
		
	End
	Else
	Begin
		set @sql = @sql + '
Inner Join [di].SessionMstr S On (S.SessID = @InSessID And CM.fk_DeployInfo = S.fk_DeployInfo)
Inner Join [bhp].RecipeJrnlMstr AS RJM On (CM.RowID = RJM.fk_CreatedBy And CM.fk_DeployInfo = RJM.fk_DeployInfo)
Left Join [bhp].RecipeBlogMstr As RBM On (RBM.fk_RecipeJrnlMstrID = RJM.RowID)
--Left Join [bhp].ProductionRqstLog PL On (PL.Fk_RecipeID = RJM.RowID And PL.[Status] = ''accepted'')
Where (CM.RowID = @InCustID And RJM.RowID = @InRecipeID);
';
	End

	exec @rc = [dbo].sp_ExecuteSql @Stmt=@Sql, @Params=N'@InAdminID bigint, @InCustID bigint, @InRecipeID int, @InSessID varchar(256)',
		@InAdminID=@admUID,
		@InCustID=@CustID,
		@InRecipeID=@RecipeID,
		@InSessID=@SessID;

	Return @rc;
End
Go

/*
use BHP1
go
declare @rc int;
exec @rc = [bhp].GetCustRecipe @SessID='ba13616c-bb36-4d95-ab70-e8971519ca57', @CustID=1002, @RecipeID=6110;
select @rc [@rc];
go


*/


create proc [bhp].GetCustRecipes (
	@SessID varchar(256),
	@CustID bigint
)
with encryption, execute as 'sticky'
as
Begin
	--Set NoCount On;

	declare @rc int;
	declare @mesg nvarchar(2000);
	declare @admuid bigint;
	declare @rows int;
	declare @vccustid varchar(50);
	declare @sql nvarchar(max);
	Declare @status bit;
	--declare @oncloud bit;
	--declare @vccloud nvarchar(20);

	if (1=0)
	Begin
		Select
			cast(null as int) as RowID,
			cast(Null as nvarchar(256)) as [RecipeName],
			cast(null as int) as [fk_BeerStyle],
			cast(null as nvarchar(200)) as [BeerStyle],
			cast(null as varchar(200)) as [CustomerChoosenBeerType],
			cast(null as bigint) as CustomerID,
			cast(null as nvarchar(200)) as CustomerName,
			cast(null as nvarchar(256)) as BHPUid,
			cast(null as numeric(6,2)) as TargetBatchSize,
			cast(null as int) as TargetBatchUOM,
			cast(null as numeric(6,2)) as TargetBoilSize,
			cast(null as int) as TargetBoilSizeUOM,
			cast(null as numeric(4,3)) as TargetOG,
			cast(null as numeric(4,3)) as TargetFG,
			cast(null as numeric(3,1)) as TargetABV,
			cast(null as numeric(6,3)) as TargetDensity,
			cast(null as int) as fk_TargetDensityUOM,
			cast(null as int) as TargetColor,
			cast(null as int) as fk_TargetColorUOM,
			cast(null as int) as TargetBitterness,
			cast(null as int) as fk_TargetBitternessUOM,
			cast(null as int) as SharingMask,
			cast(null as bit) as IsDraft,
			cast(null as int) as TotBatchesMade,
			cast(null as datetime) as EnteredOn,
			cast(null as nvarchar(200)) as BlogName,
			cast(null as int) as TotBlogComments,
			cast(null as int) as BlogLikes,
			cast(null as int) as BlogDontLikes,
			cast(null as int) as BlogIndiffs,
			cast(null as nvarchar(4000)) as [Notes],
			cast(null as int) as ClonedFromID
		Set fmtonly off;
		Return 0;
	End

	Set @rc = 0;
	set @vccustid = convert(varchar, @CustID);
	set @admuid = 0;
	--set @oncloud = 0; -- NOT running on cloud. call down to environ below to see if we actualy are on the cloud.

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@Rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [di].CustMstr Where (RowID = @CustID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66018; -- the customer doesn't exist!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Exec [di].GetEnv @VarNm='cloud context mode',@VarVal=@vccloud output,@DfltVal=0;
	--set @oncloud = [di].[fn_ISTRUE](@vccloud);

	set @sql = N'
SELECT 
	RJM.[RowID],
	RJM.[Name] As RecipeName,
	ISNULL(RJM.fk_BeerStyle,0) As fk_BeerStyle,
	ISNULL(RJM.BeerStyle,0) As BeerStyle,
	''N/A'' as [CustomerChoosenBeerType], --(select [bhp].[fn_RecipeStyleToStr](RJM.RowID)) As CustomerChoosenBeerType, -- cust can set their own beer style name...
	Case RJM.[fk_CreatedBy] When 0 then @InAdminId else RJM.[fk_CreatedBy] End As CustomerID, -- aka: customer id
	Case 
		When CM.DisplayAs IS NULL Then CM.[Name]
		When CM.Name != ISNULL(CM.DisplayAs,CM.Name) Then CM.DisplayAs
		Else CM.DisplayAs 
	End As CustomerName,
	CM.BHPUid,
	ISNULL(RJM.BatchQty, 5.0) As TargetBatchSize,
	case RJM.fk_BatchUOM when 0 then [bhp].fn_GetUOMIdByNm(''gal'') else RJM.fk_BatchUOM end As TargetBatchUOM,
	ISNULL(RJM.TargetBoilSize, 7) As TargetBoilSize,
	case RJM.fk_BoilSizeUOM when 0 then [bhp].fn_GetUOMIdByNm(''gal'') else RJM.fk_BoilSizeUOM End As TargetBoilSizeUOM,
	ISNULL(RJM.TargetOG,0) As TargetOG,
	ISNULL(RJM.TargetFG,0) As TargetFG,
	ISNULL(RJM.TargetABV,0) As TargetABV,
	ISNULL(RJM.TargetDensity,0) As TargetDensity,
	case RJM.fk_TargetDensityUOM when 0 then [bhp].fn_GetUOMIdByNm(''brix'') else RJM.fk_TargetDensityUOM end As fk_TargetDensityUOM,
	ISNULL(RJM.TargetColor,0) As TargetColor,
	case RJM.fk_TargetColorUOM When 0 then [bhp].fn_GetUOMIdByNm(''srm'') else RJM.fk_TargetColorUOM End As fk_TargetColorUOM,
	ISNULL(RJM.TargetBitterness,0) As TargetBitterness,
	case RJM.fk_TargetBitternessUOM When 0 then [bhp].fn_GetUOMIdByNm(''ibu'') else RJM.fk_TargetBitternessUOM End As fk_TargetBitternessUOM,
	RJM.SharingMask,
	ISNULL(RJM.[isDraft],1) As IsDraft,
	ISNULL(RJM.[totBatchesMade],0) As TotBatchesMade,
	RJM.[EnteredOn],
	ISNULL(RBM.Name,''blog not setup'') As [BlogName],
	ISNULL((select COUNT(*) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID And [Hide]=0)),0) As TotBlogComments,
	ISNULL((select SUM(TotLikeIt) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID And [Hide]=0)),0) As BlogLikes,
	ISNULL((select SUM(TotDontLike) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID And [Hide]=0)),0) As BlogDontLikes,
	ISNULL((select SUM(TotIndiff) from [bhp].RecipeBlogPosts Where (fk_RecipeBlogMstrID = RBM.RowID And [Hide]=0)),0) As BlogIndiffs,
	ISNULL(RJM.Notes, ''no notes (yet)!!!'') As Notes,
	RJM.fk_ClonedFrom As ClonedFromID
	FROM [di].CustMstr CM
	--Inner Join [di].Deployments D On (CM.fk_DeployInfo = D.RowID)
	Inner Join [di].SessionMstr S On (CM.fk_DeployInfo = S.fk_DeployInfo)
	Inner Join [bhp].RecipeJrnlMstr AS RJM On (CM.RowID = RJM.fk_CreatedBy And RJM.fk_DeployInfo = S.fk_DeployInfo)
	Left Join [bhp].RecipeBlogMstr As RBM On (RBM.fk_RecipeJrnlMstrID = RJM.RowID)
	--Left Join [bhp].ProductionRqstLog PL On (PL.Fk_RecipeID = RJM.RowID And PL.[Status] = ''accepted'')
';


	exec [di].GetEnv @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;
	
	-- see if we're in an admin session!?
	If Exists (Select * from [di].SessionMstr Where (SessID=@SessID) And ([RowID]=0))
	Begin
		
		if (@admuid = 0)
		Begin
			raiserror('WARNING: environment var:[''Admin UID''] not set!!!',16,1);
			return -1;
		End

		Set @Sql = @Sql + N'
Where (RJM.fk_CreatedBy = @InCustID or RJM.fk_CreatedBy = @InAdminID);';

		--Exec [dbo].sp_ExecuteSql @Stmt=@Sql, @Params=N'@InAdminID bigint, @InCustID bigint', @InAdminID=@admuid, @InCustID=@CustID;
	End
	Else
	Begin
		Set @Sql = @Sql + N'
Where (RJM.fk_CreatedBy = @InCustID);';

		--Exec [dbo].sp_ExecuteSql @Stmt=@Sql, @Params=N'@InAdminID bigint, @InCustID bigint', @InAdminID=@admuid, @InCustID=@CustID;
	End

	Exec [dbo].sp_ExecuteSql @Stmt=@Sql, @Params=N'@InAdminID bigint, @InCustID bigint', @InAdminID=@admuid, @InCustID=@CustID;

--	Raiserror(N'proc:[bhp].GetCustRecipes:: custid:[%I64d] adm:[%I64d]
--sql:[%s]',0,1,@sql,@custID,@admuid);

	Return @@ERROR;
End
Go

Create proc [bhp].EstablishRecipeBlog (
	@SessID varchar(256),
	@RecipeID int,
	@HeadName varchar(200),
	@Force bit = 1, -- default is that if a blog head is already setup...wack it.  if not..raiserror
	@NuBlogHeadID int output
)
with encryption
as
Begin
	--Set NoCount On;

	declare @rc int;
	declare @mesg nvarchar(2000);
	declare @status bit;

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

	-- this far...drop rec into blog and create the head.
	insert into [bhp].RecipeBlogMstr ([Name], fk_RecipeJrnlMstrID, TotPosts, EnteredOn)
	values (@HeadName, @RecipeID, 0, GETDATE());

	Set @NuBlogHeadID = SCOPE_IDENTITY();

	-- insert the 1st commentary rec...but hide it.
	--insert into [bhp].RecipeBlogPosts (
	--	fk_RecipeBlogMstrID, 
	--	EnteredOn, 
	--	BlogPost, 
	--	fk_PostedByID, 
	--	Hide, 
	--	LastRevisedBy, 
	--	LastRevisedOn, 
	--	fk_BlogPostCategory,
	--	fk_DeployInfo
	--)
	--select 
	--	@NuBlogHeadID, 
	--	GETDATE(), 
	--	N'entry to est. blog tree!!!', 
	--	(
	--		Select Top (1) fk_CreatedBy 
	--		From [bhp].RecipeJrnlMstr 
	--		Where (RowID = @RecipeID)
	--	),
	--	1,
	--	0,
	--	0,
	--	0,
	--	ISNULL((select top(1) fk_DeployInfo From [di].SessionMstr Where (SessID = @SessID)),-1);

	Return @@ERROR;
End
go


/*
Declare @return_value int;
Declare @rowid int;
EXEC	@return_value = [bhp].[AddCustRecipe]
		@SessID = N'00000000-0000-0000-0000-000000000000',
		@CustID = 1002,
		@RecipeName = N'foobar - 2',
		@fk_BeerStyle = 32,
		@TrgtBatchAmt = 5.75,
		@fk_TrgtBatchUOM = 0,
		@TrgtBoilAmt = 7,
		@fk_TrgtBoilUOM = 0,
		@isDraft = 1,
		@TrgtOG = 1.064,
		@TrgtFG = 1.012,
		@TrgtABV = 5.5,
		@TrgtDensity = 56,
		@fk_TrgtDensityUOM = 0,
		@TrgtColorAmt = 77,
		@fk_TrgtColorUOM = 0,
		@TrgtBitternessAmt = 80,
		@fk_TrgtBitterUOM = 0,
		@Notes = N'test note',
		@CloneID=0,
		@RowID = @RowID OUTPUT

SELECT	@RowID as N'@RowID'

SELECT	'Return Value' = @return_value

NOTE: Sharing Mask is not allowed to be set upon creation...they always default to 'private' at first.
	afterwards they can be changed to whatever user wants...
*/
create proc [bhp].AddCustRecipe (
	@SessID nvarchar(256),
	@CustID bigint,
	@RecipeName nvarchar(256),
	@fk_BeerStyle int,
	@TrgtBatchAmt numeric(6,2) = 0,
	@fk_TrgtBatchUOM int = 0,
	@TrgtBoilAmt numeric(6,2) = 0, 
	@fk_TrgtBoilUOM int = 0, 
	@isDraft bit = 1,
	@TrgtOG numeric(4,3) = 0,
	@TrgtFG numeric(4,3) = 0,
	@TrgtABV numeric(3,1) = 0,
	@TrgtDensity numeric(6,3) = 0, 
	@fk_TrgtDensityUOM int = 0,
	@TrgtColorAmt int = 0,
	@fk_TrgtColorUOM int = 0, 
	@TrgtBitternessAmt int = 0,
	@fk_TrgtBitterUOM int = 0,
	@Notes nvarchar(4000),
	@RowID int output,
	@BCastMode bit = 1,
	@CloneID int = 0
)
with encryption
as
begin
	--Set NoCount On;

	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @BlogID int;
	Declare @BlogNm varchar(200);
	Declare @admuid bigint;
	Declare @xml xml;
	Declare @styleDoc xml;
	Declare @sharingDoc xml;
	Declare @custDoc xml;
	Declare @notesDoc xml;
	Declare @fragDoc xml;
	Declare @MashSchedDoc xml;
	Declare @AgeSchedDoc xml;
	Declare @SessSrc xml;
	Declare @WtrProfileDoc xml;
	Declare @NuInfo Table ([ID] int);
	Declare @cName nvarchar(256); -- recipe name we are cloned from (if > 0...else empty string)
	--Declare @isCloud varchar(40);
	Declare @status bit;
	Declare @evntnm varchar(200) = 'CustomerRecipe';

	Set @CloneID = ISNULL(@CloneID,0);

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@Rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * from [di].SessionMstr Where (SessID=@SessID) And ([RowID]=0))
	Begin
		exec [di].GetEnv @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

		if (@admuid = 0)
			raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

		if (@CustID = 0 or @CustID IS NULL)
			set @CustID = @admuid;
	End

	If Not Exists (Select * from [di].CustMstr Where (RowID = @CustID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66018; -- the customer doesn't exist!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * 
		from [bhp].RecipeJrnlMstr M
		Inner Join [di].SessionMstr S On (S.fk_DeployInfo = M.fk_DeployInfo)
		Where (M.[Name] = @RecipeName And S.SessID = @SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66096; -- recipe name already used by deployment
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].AHABeerStyle Where (RowID = @fk_BeerStyle))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66072; -- this nbr represents an unknown beer style!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_VolumnUOM Where (RowID = @fk_TrgtBatchUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66055; -- this batch size volume fk is not a valid volume foreign key value
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_VolumnUOM Where (RowID = @fk_TrgtBoilUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66055; -- this batch size volume fk is not a valid volume foreign key value
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_WeightUOM Where (RowID = @fk_TrgtDensityUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66056; -- this batch size volume fk is not a valid volume foreign key value
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_ColorUOM Where (RowID = @fk_TrgtColorUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66073; -- the foreign key value for color is NOT a color key
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_BitternessUOM Where (RowID = @fk_TrgtBitterUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66074; -- the foreign key value for color is NOT a color key
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].GetEnv @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!


	Select @cName = 
		case @CloneID 
		when 0 then '' 
		else rtrim(ltrim([Name]))
		end
	from [bhp].RecipeJrnlMstr Where (RowID=@CloneID);

	insert into [bhp].RecipeJrnlMstr (
		[Name]
		,[fk_BeerStyle]
		,[TargetQty]
		,[fk_TargetUOM]
		,[BatchQty]
		,[fk_BatchUOM]
		,[fk_CreatedBy]
		,[isDraft]
		,[Notes]
		,[fk_BrewerCommentary]
		,[TargetBoilSize]
		,[fk_BoilSizeUOM]
		,[fk_BrewerID]
		,[fk_AsstBrewerID]
		,[TargetOG]
		,[TargetFG]
		,[TargetABV]
		,[TargetDensity]
		,[fk_TargetDensityUOM]
		,[TargetColor]
		,[fk_TargetColorUOM]
		,[TargetBitterness]
		,[fk_TargetBitternessUOM]
		,[SharingMask]
		,[fk_DeployInfo]
		,[fk_ClonedFrom] -- this is a recursive key!!!
	)
	Output Inserted.RowID into @NuInfo([ID])
	select 
		@RecipeName,
		@fk_BeerStyle,
		@TrgtBatchAmt, -- target size not used...defaulting to batch size.
		case @fk_TrgtBatchUOM when 0 then [bhp].fn_GetUOMIdByNm('gal') else @fk_TrgtBatchUOM end,
		@TrgtBatchAmt, -- this is the amt shown in view: [bhp].vw_CustomerREcipes
		case @fk_TrgtBatchUOM when 0 then [bhp].fn_GetUOMIdByNm('gal') else @fk_TrgtBatchUOM end,
		@CustID,
		ISNULL(@isDraft,1),
		COALESCE(@Notes,'no comment given...'),
		0, -- brewer commentary not setup on creation.
		@TrgtBoilAmt,
		case @fk_TrgtBoilUOM when 0 then [bhp].fn_GetUOMIdByNm('gal') else @fk_TrgtBoilUOM end,
		Case When [di].fn_ISBrewer(@CustID) = 1 Then @CustID Else 0 End, -- presume brewer id if cust is a brewer!?
		0, -- assit brewery not set on creation.
		ISNULL(@TrgtOG,0),
		ISNULL(@TrgtFG,0),
		ISNULL(@TrgtABV,0),
		ISNULL(@TrgtDensity,0),
		case @fk_TrgtDensityUOM when 0 then [bhp].fn_GetUOMIdByNm('brix') else @fk_TrgtDensityUOM end,
		ISNULL(@TrgtColorAmt,0),
		case @fk_TrgtColorUOM when 0 then [bhp].fn_GetUOMIdByNm('srm') else @fk_TrgtColorUOM end,
		ISNULL(@TrgtBitternessAmt,0),
		case @fk_TrgtBitterUOM when 0 then [bhp].fn_GetUOMIdByNm('ibu') else @fk_TrgtBitterUOM end,
		[bhp].fn_GetSharingBitValByNm('private'), -- initially recipes are created as 'private'.
		ISNULL((select top(1) fk_DeployInfo From [di].SessionMstr Where (SessID = @SessID)),-1),
		@CloneID;

	Select @RowID = [ID] from @NuInfo;

	-- load up or burp event message(s)...if broadcast mode is on
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenRecipeTrgtsMesg @rid=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @xml output;
		exec @rc = [bhp].GenRecipeStyleMesg @rid=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @styleDoc output;
		exec @rc = [bhp].GenRecipeSharingMesg @rid=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @sharingDoc output;
		exec @rc = [bhp].GenRecipeCreatorMesg @rid=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @custDoc output;
		exec @rc = [bhp].GenRecipeNotesMesg @rid=@RowID, @evnttype='add', @SessID=@SessID, @mesg = @notesDoc output;
		--Exec [bhp].GenSessSrcMesg @SessID = @SessID, @Mesg = @SessSrc output;

		-- stuff in session source node
		--set @xml.modify('
		--	declare namespace b="http://burp.net/recipe/evnts";
		--	insert sql:variable("@SessSrc") as first into (/b:Burp_Belch)[1]
		--');

		-- now consolidate all the frags into one big ole doc...
		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @styleDoc.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Style_Info)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @sharingDoc.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sharing_Flags)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @custDoc.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Creator_Info)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @notesDoc.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Notes)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		-- add in the CLONE_INFO node
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert (
				<b:Clone_Info id=''{sql:variable("@CloneID")}''>{sql:variable("@cName")}</b:Clone_Info>
			) as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

	End

	/*
	** We need to support the binder till the schedule (hop) is bound up properly...
	*/
	If Not Exists (Select * from [bhp].RecipeHopSchedBinder Where (fk_RecipeJrnlMstrID = @RowID))
	Begin
		insert into [bhp].RecipeHopSchedBinder (fk_HopSchedMstrID, fk_RecipeJrnlMstrID)
		Values (0,@RowID);
	End

	/*
	** We need to support the mash binder till the schedule (mash) is bound up properly...
	** NOTE: if a 'default' mash is established we'll bind to that!!!
	*/
	If Not Exists (Select * from [bhp].RecipeMashSchedBinder Where (fk_RecipeJrnlMstrID = @RowID))
	Begin
		Declare @nuMashSchedID int;
		Declare @dfltMSchedID int;

		Set @dfltMSchedID = 0;

		If Exists (Select * from [bhp].MashSchedMstr Where (isDfltForNu = 1))
		Begin
			Select @dfltMSchedID = RowID From [bhp].MashSchedMstr M Where (M.isDfltForNu = 1);
		End
		
		-- bind up to a mash schedule...
		Exec [bhp].SetRecipeMashSchedBinder @SessID=@SessID, @RecipeID=@RowID, @SchedID=@dfltMSchedID, @force=1, @BCastMode=0, @NuBinderID = @nuMashSchedID output;

		If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Begin
			-- gen the sched_info mesg
			Exec @rc = [bhp].GenRecipeMashBinderEvntMesg @bid=@nuMashSchedID, @evnttype='add', @SessID=@SessID, @Mesg = @MashSchedDoc output;

			-- extract just the node we need...
			with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
			select @fragDoc = @MashSchedDoc.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sched_Info)');

			-- stuff the node into the bigger doc...
			set @xml.modify('
				declare namespace b="http://burp.net/recipe/evnts";
				insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
			');
		End
	End

	/*
	** We need to support the aging binder till the schedule (aging) is bound up properly...
	** NOTE: if a default for new recipes is established...we'll use that!!!
	*/
	If Not Exists (Select * from [bhp].RecipeAgingSchedBinder Where (fk_RecipeJrnlMstrID = @RowID))
	Begin
		Declare @nuAgeSchedID int;
		Declare @dfltAgeSchedID int;

		Set @dfltAgeSchedID = 0;

		if Exists (Select * from [bhp].AgingSchedMstr where isDfltForNu = 1)
		Begin
			Select Top (1) @dfltAgeSchedID = RowID From [bhp].AgingSchedMstr Where (isDfltForNu = 1);
		End

		Exec [bhp].SetRecipeAgingSchedBinder @SessID=@SessID, @RecipeID=@RowID, @SchedID=@dfltAgeSchedID, @force=1, @BCastMode=0, @NuBinderID=@nuAgeSchedID output;

		If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Begin
			-- gen the sched_info mesg
			Exec @rc = [bhp].GenRecipeAgingBinderEvntMesg @bid=@nuAgeSchedID, @evnttype='add', @SessID=@SessID, @Mesg = @AgeSchedDoc output;

			-- extract just the node we need...
			with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
			select @fragDoc = @AgeSchedDoc.query('(/Burp_Belch/Payload/Recipe_Evnt/Sched_Info)');

			-- stuff the node into the bigger doc...
			set @xml.modify('
				declare namespace b="http://burp.net/recipe/evnts";
				insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
			');
		End
	End

	Set @BlogNm = @RecipeName + ' blog...';

	/*
	** go ahead and setup the blog tree...create one entry that is 'hidden' so tree is established!!!
	** NOTE: todo...make this decision either a parameter to 'addcustrecipe' or look into enviro tbl for how to handle!!!
	*/
	exec @rc = [bhp].EstablishRecipeBlog @SessID=@SessID, @RecipeID=@RowID, @HeadName=@BlogNm, @force=1, @NuBlogHeadID=@BlogID output;

	/*
	** setup a dummy water profile here...
	** NOTE: if a default is setup for new recipes...we'll bind to that!!!
	*/
	If Not Exists (Select * from [bhp].RecipeWaterProfile Where (fk_RecipeJrnlMstrID = @RowID))
	Begin
		Declare @wtrID int;
		Set @wtrID = 0;

		If Exists (Select * from [bhp].FamousWaterProfiles Where (isDfltForNu = 1))
		Begin
			Select Top (1) @wtrID = RowID From [bhp].FamousWaterProfiles Where isDfltForNu = 1;
		End

		Insert into [bhp].RecipeWaterProfile (
			[fk_RecipeJrnlMstrID]
			,[Calcium]
			,[fk_CalciumUOM]
			,[Magnesium]
			,[fk_MagnesiumUOM]
			,[Sodium]
			,[fk_SodiumUOM]
			,[Sulfate]
			,[fk_SulfateUOM]
			,[Chloride]
			,[fk_ChlorideUOM]
			,[Bicarbonate]
			,[fk_BicarbonateUOM]
			,[Ph]
			,[fk_PhUOM]
			,[fk_InitilizedByFamousWtrID]
			,[Comments]
		)
		Select
			@RowID
			,[Calcium]
			,[fk_CalciumUOM]
			,[Magnesium]
			,[fk_MagnesiumUOM]
			,[Sodium]
			,[fk_SodiumUOM]
			,[Sulfate]
			,[fk_SulfateUOM]
			,[Chloride]
			,[fk_ChlorideUOM]
			,[Bicarbonate]
			,[fk_BicarbonateUOM]
			,[Ph]
			,[fk_PhUOM]
			,[RowID]
			,Case @wtrID When 0 
				Then N'no water profile info provided...minerals all defaulted to ''0'' value(s)...'
				Else
					(Select N'initialized from profile:[''' + Name +''']...' from [bhp].FamousWaterProfiles Where (RowID = @wtrID))
			End
		From [bhp].FamousWaterProfiles Where (RowID = @wtrID);

		If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm) And @WtrID > 0)
		Begin
			-- gen the sched_info mesg
			Exec @rc = [bhp].GenRecipeWaterProfileMesg @rid=@RowID, @evnttype='add', @SessID=@SessID, @Mesg = @WtrProfileDoc output;

			-- extract just the node we need...
			with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
			select @fragDoc = @WtrProfileDoc.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Profile_Info)');

			-- stuff the node into the bigger doc...
			set @xml.modify('
				declare namespace b="http://burp.net/recipe/evnts";
				insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
			');
		End

	End

	-- now publish the burp message that we've created a new recipe...
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='Customer-Recipe';

	Return @rc;
end
go

Create Proc [bhp].DelCustRecipe (
	@SessID varchar(256),
	@RowID int,
	@BCastMode bit = 1 -- broadcast event mode!?
)
with encryption
as
begin
	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @styleDoc xml;
	Declare @sharingDoc xml;
	Declare @fragDoc xml;
	Declare @custDoc xml;
	Declare @notesDoc xml;
	Declare @sesssrc xml;
	Declare @isCloud varchar(30);
	Declare @ProdMsg xml;
	--Declare @inProdBit smallint;
	Declare @status bit;
	Declare @evntNm varchar(200) = 'CustomerRecipe';

	--Select @inProdBit = BitVal From [bhp].SharingTypes WHere Descr = 'In Production';

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@Rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if not exists (select 1 from [bhp].RecipeJrnlMstr Where RowID=@RowID)
	begin
		Raiserror(N'unable to find recipe w/id:[%d] to remove...no action taken!!!',0,1,@RowID);
		return 0;
	end

	--If Exists (
	--	Select 1 from 
	--	[bhp].ProductionRqstLog L 
	--	Inner Join [bhp].RecipeJrnlMstr R On (L.Fk_RecipeID = R.RowID And R.RowID = @RowID)
	--	Where L.[Status] = 'accepted'
	--	And ((R.SharingMask & @inProdBit) = @inProdBit)
	--)
	--Begin
	--	Declare @rnm varchar(256);
	--	Select @rnm = [Name] from [bhp].RecipeJrnlMstr Where RowID=@RowID;
	--	Set @rc = 66107; -- recipe is in production...cannot be changed
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1,@rnm);
	--	Return @rc;
	--End

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].GetEnv @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenRecipeTrgtsMesg @rid=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @xml output;
		exec @rc = [bhp].GenRecipeStyleMesg @rid=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @styleDoc output;
		exec @rc = [bhp].GenRecipeSharingMesg @rid=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @sharingDoc output;
		exec @rc = [bhp].GenRecipeCreatorMesg @rid=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @custDoc output;
		exec @rc = [bhp].GenRecipeNotesMesg @rid=@RowID, @evnttype='del', @SessID=@SessID, @mesg = @notesDoc output;
		--Exec [bhp].GenSessSrcMesg @SessID = @SessID, @Mesg = @SessSrc output;

		---- stuff in session source node
		--set @xml.modify('
		--	declare namespace b="http://burp.net/recipe/evnts";
		--	insert sql:variable("@SessSrc") as first into (/b:Burp_Belch)[1]
		--');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @styleDoc.query('(/Burp_Belch/Payload/Recipe_Evnt/Style_Info)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @sharingDoc.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sharing_Flags)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @custDoc.query('(/Burp_Belch/Payload/Recipe_Evnt/Creator_Info)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @notesDoc.query('(/Burp_Belch/Payload/Recipe_Evnt/Notes)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');
	End

	/*
	** Gotta cleanup up any foreign key (kids) out there...blogs, brewer comm's, etc...
	*/
	Delete [bhp].BlogPostComments 
	From [bhp].BlogPostComments BC
	inner join [bhp].RecipeBlogPosts BP On (BP.RowID = BC.fk_BlogPostID) 
	Inner Join [bhp].RecipeBlogMstr RBM On (BP.fk_RecipeBlogMstrID = RBM.RowID)
	WHere (RBM.fk_RecipeJrnlMstrID = @RowID);

	Delete [bhp].RecipeBlogPosts 
	From [bhp].RecipeBlogPosts RBC 
	Inner Join [bhp].RecipeBlogMstr RBM On (RBM.fk_RecipeJrnlMstrID = @RowID And RBC.fk_RecipeBlogMstrID = RBM.RowID);

	Delete Top (1) [bhp].RecipeBlogMstr Where (fk_RecipeJrnlMstrID = @RowID);

	Delete Top (1) [bhp].BrewerCommentary Where (fk_RecipeJrnlMstrID = @RowID);

	Delete Top (1) [bhp].RecipeMashSchedBinder Where (fk_RecipeJrnlMstrID = @RowID);

	Delete Top (1) [bhp].RecipeWaterProfile WHere (fk_RecipeJrnlMstrID = @RowID);

	Delete [bhp].RecipeYeasts Where (fk_RecipeJrnlMstrID = @RowID);

	Delete Top (1) [bhp].RecipeAgingSchedBinder Where (fk_RecipeJrnlMstrID = @RowID);

	Delete [bhp].RecipeExtracts Where (fk_RecipeJrnlMstrID = @RowID);

	Delete [bhp].RecipeGrains Where (fk_RecipeJrnlMstrID = @RowID);

	Delete Top (1) [bhp].RecipeHopSchedBinder Where (fk_RecipeJrnlMstrID = @RowID);

	Delete [bhp].RecipeIngredient_Tags
	From [bhp].RecipeIngredient_Tags RT
	Inner Join [bhp].RecipeIngredients RI On (RI.fk_RecipeJrnlMstrID = @RowID And RI.RowID = RT.fk_RecipeIngredient);

	Delete [bhp].RecipeIngredients Where (fk_RecipeJrnlMstrID = @RowID);

	/*
	** if request to move this recipe has been sent...BUT...the request hasn't been reviewed yet
	** we need to mesg the review process that this request is not longer valid...as the
	** recipe has been removed from system!!!
	*/
	--if exists (select 1 from [bhp].ProductionRqstLog Where Fk_RecipeID = @RowID And [Status] = 'initiated')
	--begin
	--	Declare @plogid int;
	--	Select @plogid = RowID from [bhp].ProductionRqstLog Where Fk_RecipeID = @RowID And [Status] = 'initiated';
	--	-- TODO: figure out how to the get parameter @Reason populated!!!
	--	-- so the drop rqst has a bit of context as to why it is being dropped
	--	Exec [bhp].GenProdRqstMesg @SessID=@SessID, @LogID=@plogid, @Action='drop', @Mesg=@ProdMsg output;
	--	Exec [bhp].SendDropRecipeRevueRqst @msg=@ProdMsg; -- send notice over to reviewer console to drop request
	--end

	--Delete [bhp].ProductionRqstLog Where (Fk_RecipeID = @RowID); -- should only be (1) rec!!!

	-- if anyone is cloned from this recipe...gotta break that link!!!
	If Exists (Select 1 from [bhp].RecipeJrnlMstr Where (fk_ClonedFrom = @RowID))
	begin
		Update [bhp].RecipeJrnlMstr
			set fk_ClonedFrom = 0
		Where (fk_ClonedFrom = @RowID);
	end

	Delete Top (1) [bhp].RecipeJrnlMstr Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='Customer-Recipe';

	Return @@ERROR;

end
go

Create proc [bhp].ChgCustRecipe (
	@SessID varchar(256),
	@RowID int,
	@RecipeName nvarchar(256),
	@fk_BeerStyle int,
	@TrgtBatchAmt numeric(6,2),
	@fk_TrgtBatchUOM int,
	@TrgtBoilAmt numeric(6,2), 
	@fk_TrgtBoilUOM int, 
	@isDraft bit,
	@TrgtOG numeric(4,3),
	@TrgtFG numeric(4,3),
	@TrgtABV numeric(3,1),
	@TrgtDensity numeric(6,3), 
	@fk_TrgtDensityUOM int,
	@TrgtColorAmt int,
	@fk_TrgtColorUOM int, 
	@TrgtBitternessAmt int,
	@fk_TrgtBitterUOM int,
	@SharingBitMask int = 0,
	@Notes nvarchar(4000),
	@BCastMode bit = 1
)
with encryption
as
Begin

	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @xml xml;
	Declare @styleDoc xml;
	Declare @sharingDoc xml;
	Declare @fragDoc xml;
	Declare @custDoc xml;
	Declare @notesDoc xml;
	Declare @mv2ProdBit smallint;
	Declare @inProdBit smallint;
	Declare @SessSrc xml;
	Declare @old nvarchar(256); -- holds the old recipe name...
	Declare @isCloud varchar(40);
	Declare @rnm varchar(256); -- recipe name
	Declare @oldsmask int; -- the old sharing bitmask value
	Declare @evntNm varchar(200) = 'CustomerRecipe';
	--Declare @plogid int;
	--Declare @ProdMsg xml;
	--Declare @hbyteLst nvarchar(max);
	--Declare @hbyteCols xml;
	--Declare @hbytesArgs varbinary(2000); -- holds all the passed args from hashbytes
	--Declare @hbytesRow varbinary(2000); -- holds row data (before) update from hashbytes

	--Declare @plog Table (RowID int);

	Declare @oTbl Table (
		RowID int,
		SMask int,
		[Name] nvarchar(256)
	);

	Set @isDraft = Coalesce(@isDraft, 1);
	Set @SharingBitMask = ISNULL(@SharingBitMask,0);

	Select @mv2ProdBit = BitVal From [bhp].SharingTypes WHere Descr = 'Move To Production';
	Select @inProdBit = BitVal From [bhp].SharingTypes WHere Descr = 'In Production';

	Set @mv2ProdBit = ISNULL(@mv2ProdBit, 16); -- hack...FIX THIS!!!
	Set @inProdBit = ISNULL(@inProdBit,64); -- emergency hack!!!

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@Rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	-- changes to recipe are NOT ALLOWED because recipe is in production.
	-- you might be able to clone the recipe thou...and start a new branch!?
	--If Exists (Select 1 
	--	From [bhp].ProductionRqstLog L
	--	Where L.Fk_RecipeID=@RowID 
	--	And L.[Status]='accepted'
	--	And ((@SharingBitMask & @inProdBit) != @inProdBit)
	--)
	--begin
	--	Select @rnm=[Name] from [bhp].RecipeJrnlMstr Where RowID=@RowID;
	--	Set @rc = 66108; -- recipe cannot be modified
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1,@rnm);
	--	Return @rc;
	--end

	/*
	** TODO: allow changes if only the sharing bits are being modified!!!
	** this'll will be tough to implement, but worthwhile as a recipe owner
	** might want to change the sharing on a production recipe WITHOUT CHANGING
	** any of the other components of the recipe...therein lies how this'll be done.
	** WIll use hashbytes to interrogate the dbms row and the args passed in...
	** if they're the same and the sharing mask is only difference, then we can proceed.
	** However, the 'in production','internal' must remain 'on' and 'private' must be 'off'.
	** The GUI enforces this rule, so we should never experience that situation!!!
	*/
	--If Exists (Select 1 
	--	from [bhp].ProductionRqstLog 
	--	WHere (Fk_RecipeID=@RowID And [Status] in ('accepted','under review'))
	--)
	--begin
	--	-- 1st gen a hashbyte value for the row in the dbms.
	--	Select @hbytesRow = HASHBYTES(
	--		'md5',
	--		ISNULL(RTRIM(Name),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,fk_BeerStyle)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),BatchQty)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,fk_BatchUOM)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),isDraft)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),TargetBoilSize)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,fk_BoilSizeUOM)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),TargetOG)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),TargetFG)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),TargetABV)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),TargetDensity)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,fk_TargetDensityUOM)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,TargetColor)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,fk_TargetColorUOM)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,TargetBitterness)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,fk_TargetBitternessUOM)),SPACE(0))
	--		)
	--	From [bhp].RecipeJrnlMstr
	--	Where (RowID = @RowID);

	--	-- next gen hashbyte value for the args passed in...
	--	Select @hbytesArgs = HASHBYTES(
	--		'md5',
	--		ISNULL(RTRIM(@RecipeName),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,@fk_BeerStyle)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),@TrgtBatchAmt)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,@fk_TrgtBatchUOM)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),@isDraft)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),@TrgtBoilAmt)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,@fk_TrgtBoilUOM)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),@TrgtOG)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),@TrgtFG)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),@TrgtABV)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar(255),@TrgtDensity)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,@fk_TrgtDensityUOM)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,@TrgtColorAmt)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,@fk_TrgtColorUOM)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,@TrgtBitternessAmt)),SPACE(0))+','+
	--		ISNULL(RTRIM(CONVERT(varchar,@fk_TrgtBitterUOM)),SPACE(0))
	--	);

	--	if (@hbytesArgs != @hbytesRow)
	--	begin
	--		Select @rnm=[Name] from [bhp].RecipeJrnlMstr Where RowID=@RowID;
	--		Set @rnm = ISNULL(@rnm, @RecipeName);
	--		Set @rc = 66108; -- recipe cannot be modified
	--		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--		Raiserror(@Mesg,16,1,@rnm);
	--		Return @rc;
	--	end
	--end

	-- changes to recipe are NOT ALLOWED because recipe is currently being reviewed by production/ops.
	-- you might be able to clone the recipe thou...and start a new branch!?
	--If Exists (Select 1 
	--	from [bhp].ProductionRqstLog 
	--	Where Fk_RecipeID=@RowID 
	--	And [Status]='under review'
	--	And ((@SharingBitMask & @inProdBit) != @inProdBit)
	--)
	--begin
	--	Select @rnm=[Name] from [bhp].RecipeJrnlMstr Where RowID=@RowID;
	--	Set @rc = 66109; -- recipe cannot be modified its under review!!!
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1,@rnm);
	--	Return @rc;
	--end

	If Not Exists (Select * from [bhp].AHABeerStyle Where (RowID = @fk_BeerStyle))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66072; -- this nbr represents an unknown beer style!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_VolumnUOM Where (RowID = @fk_TrgtBatchUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66055; -- this batch size volume fk is not a valid volume foreign key value
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_VolumnUOM Where (RowID = @fk_TrgtBoilUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66055; -- this batch size volume fk is not a valid volume foreign key value
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_WeightUOM Where (RowID = @fk_TrgtDensityUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66056; -- this batch size volume fk is not a valid volume foreign key value
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_ColorUOM Where (RowID = @fk_TrgtColorUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66073; -- the foreign key value for color is NOT a color key
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (Select * from [bhp].vw_BitternessUOM Where (RowID = @fk_TrgtBitterUOM))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66074; -- the foreign key value for color is NOT a color key
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select * 
		from [bhp].RecipeJrnlMstr M
		Inner Join [di].SessionMstr S On (S.fk_DeployInfo = M.fk_DeployInfo)
		Where (M.[Name] = @RecipeName And S.SessID = @SessID And M.RowID != @RowID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66096; -- recipe name already used by deployment
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].GetEnv @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!

	Update [bhp].RecipeJrnlMstr
		Set
		[Name] = Coalesce(@RecipeName, [Name])
		,[fk_BeerStyle] = Coalesce(@fk_BeerStyle, fk_BeerStyle)
		,[BatchQty] = Coalesce(@TrgtBatchAmt, BatchQty)
		,[fk_BatchUOM] = Coalesce(@fk_TrgtBatchUOM, fk_BatchUOM)
		,[isDraft] = @isDraft
		,[Notes] = Coalesce(@Notes, Notes, N'No comments provided...')
		,[TargetBoilSize] = Coalesce(@TrgtBoilAmt, TargetBoilSize)
		,[fk_BoilSizeUOM] = Coalesce(@fk_TrgtBoilUOM, fk_BoilSizeUOM)
		,[TargetOG] = Coalesce(@TrgtOG, TargetOG, 0.0)
		,[TargetFG] = Coalesce(@TrgtFG, TargetFG, 0.0)
		,[TargetABV] = Coalesce(@TrgtABV, TargetABV, 0.0)
		,[TargetDensity] = Coalesce(@TrgtDensity, TargetDensity, 0)
		,[fk_TargetDensityUOM] = Coalesce(@fk_TrgtDensityUOM, fk_TargetDensityUOM, [bhp].fn_GetUOMIdByNm('brix'))
		,[TargetColor] = Coalesce(@TrgtColorAmt, TargetColor, 0)
		,[fk_TargetColorUOM] = Coalesce(@fk_TrgtColorUOM, fk_TargetCOlorUOM, [bhp].fn_GetUOMIdByNm('srm'))
		,[TargetBitterness] = Coalesce(@TrgtBitternessAmt, TargetBitterness, 0)
		,[fk_TargetBitternessUOM] = Coalesce(@fk_TrgtBitterUOM, fk_TargetBitternessUOM, [bhp].fn_GetUOMIdByNm('ibu'))
		,[SharingMask] = case @SharingBitMask When 0 THen [bhp].fn_GetSharingBitValByNm('private') Else @SharingBitMask End
	Output Deleted.RowID, Deleted.SharingMask, deleted.Name Into @oTbl(RowID,SMask,[Name])
	Where (RowID = @RowID);

	--Select @old = [Name], @oldsmask = SMask From @oTbl;

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		exec @rc = [bhp].GenRecipeTrgtsMesg @rid=@RowID, @evnttype='chg', @SessID=@SessID, @mesg = @xml output;
		exec @rc = [bhp].GenRecipeStyleMesg @rid=@RowID, @evnttype='chg', @SessID=@SessID, @mesg = @styleDoc output;
		exec @rc = [bhp].GenRecipeSharingMesg @rid=@RowID, @evnttype='chg', @SessID=@SessID, @mesg = @sharingDoc output;
		--exec @rc = [bhp].GenRecipeCreatorMesg @rid=@RowID, @evnttype='chg', @SessID=@SessID, @mesg = @custDoc output;
		exec @rc = [bhp].GenRecipeNotesMesg @rid=@RowID, @evnttype='chg', @SessID=@SessID, @mesg = @notesDoc output;
		--Exec [bhp].GenSessSrcMesg @SessID = @SessID, @Mesg = @SessSrc output;

		---- stuff in session source node
		--set @xml.modify('
		--	declare namespace b="http://burp.net/recipe/evnts";
		--	insert sql:variable("@SessSrc") as first into (/b:Burp_Belch)[1]
		--');

		-- stuff in the old recipe name...
		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Info/b:Name)[1]
		');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @styleDoc.query('(/Burp_Belch/Payload/Recipe_Evnt/Style_Info)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @sharingDoc.query('(/b:Burp_Belch/b:Payload/b:Recipe_Evnt/b:Sharing_Flags)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		--with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		--select @fragDoc = @custDoc.query('(/Burp_Belch/Payload/Recipe_Evnt/Creator_Info)');

		--set @xml.modify('
		--	declare namespace b="http://burp.net/recipe/evnts";
		--	insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		--');

		with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
		select @fragDoc = @notesDoc.query('(/Burp_Belch/Payload/Recipe_Evnt/Notes)');

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert sql:variable("@fragDoc") as last into (/b:Burp_Belch/b:Payload/b:Recipe_Evnt)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='Customer-Recipe';
	End

	-- if the 'move to production' bit is 'on'...
	-- we need to create a log entry and post a ssb msg so the reviewer service can get 
	-- started.
	-- NOTE: this Chg proc is called by the ops recipe mgmt srvc via the 'replication'
	-- service.  So here we need to only create the log if the 'in production' bit is NOT set.
	-- NOTE: the move to prod bit should be 'off' when the 'in production' bit is 'on'...
	-- but just in case we include the check below...
	--if (
	--	((@SharingBitMask & @mv2ProdBit) = @mv2ProdBit) 
	--	And
	--	((@SharingBitMask & @inProdBit) != @inProdBit)
	--)
	--Begin

	--	If Not Exists (Select 1 
	--		from [bhp].ProductionRqstLog 
	--		Where Fk_RecipeID=@RowID 
	--		And [Status] in ('initiated','under review','accepted')
	--	)
	--	begin
	--		--Delete [bhp].ProductionRqstLog Where Fk_RecipeID = @RowID;

	--		Insert [bhp].ProductionRqstLog(RequestedBy, Fk_DeployInfo, Fk_RecipeID, [Status])
	--		Output inserted.RowID into @plog(RowID)
	--		Select R.fk_CreatedBy, R.fk_DeployInfo, R.RowID, 'initiated'
	--		From [bhp].RecipeJrnlMstr R
	--		Where (R.RowID = @RowID);

	--		select @plogid = RowID from @plog;

	--		exec [bhp].GenProdRqstMesg @SessID=@SessID, @LogID=@plogid, @Action='new', @Mesg=@ProdMsg output;
	--		exec [bhp].SendRecipeRevueRqst @msg=@ProdMsg;
	--	end
		
	--End
	-- if curr mask has move to prod 'off', but old mask had it 'on'...
	-- And the 'in production' bit IS NOT SET...then cleanup log
	-- NOTE: if this far we know the status is either 'initialized' or 'declined'...
	-- okay to change recipe!!!
	--Else If (
	--	((@SharingBitMask & @mv2ProdBit) != @mv2ProdBit) 
	--	And ((@oldsmask & @mv2ProdBit) = @mv2ProdBit)
	--	And ((@SharingBitMask & @inProdBit) != @inProdBit)
	--)
	--Begin
	--	if exists (select 1 from [bhp].ProductionRqstLog Where Fk_RecipeID = @RowID)
	--	begin
	--		Select @plogid = RowID from [bhp].ProductionRqstLog Where Fk_RecipeID = @RowID;
	--		Exec [bhp].GenProdRqstMesg @SessID=@SessID, @LogID=@plogid, @Action='drop', @Mesg=@ProdMsg output;
	--		Delete [bhp].ProductionRqstLog Where (Fk_RecipeID = @RowID); -- should only be (1) rec!!!
	--		Exec [bhp].SendDropRecipeRevueRqst @msg=@ProdMsg; -- send notice over to reviewer console
	--	end
	--End

	Return @@ERROR;
End
go

/*
** This big ole proc clones a recipe. given the vast array of params...you can customize
** exactly what you'd like to clone.  By default everything about a recipe is cloned.
** However, you can specify things like schedules be cloned instead of being referenced.
** This is useful if you plan to modify the recipe!!!
*/
create proc [bhp].CloneRecipeV1 (
	@SessID varchar(256),
	@RecipeID int, -- recipe from which you are cloning
	@NuName nvarchar(256),
	@NuNotes nvarchar(4000) = null,
	@BCastMode bit = 1,
	@CloneHops bit = 1,
	@CloneYeasts bit = 1,
	@CloneGrains bit = 1,
	@CloneExtracts bit = 1,
	@CloneWater bit = 1,
	@CloneAging bit = 1,
	@CloneMash bit = 1,
	@CloneAdjuncts bit = 1,
	@CloneHopSchedAsNu bit = 0,
	@NuVolumeAmt numeric(6,2) = 0,
	@NuRecipeID int output -- the new cloned recipe id
)
with encryption
as
begin
	Declare @cloneBitVal smallint;
	Declare @currrow int; -- used to walk thru rowid values (int)
	Declare @currbrow bigint; -- used to walk thru rowid values (bigint);
	Declare @RecipeNm nvarchar(256);
	Declare @rc int;
	declare @mesg nvarchar(2000);
	declare @admuid bigint;
	declare @rows int;
	--declare @isok bit;
	Declare @CustID bigint;
	Declare @fk_BeerStyle int;
	Declare @TrgtBatchAmt numeric(6,2);
	Declare @fk_TrgtBatchUOM int;
	Declare @TrgtBoilAmt numeric(6,2); 
	Declare @fk_TrgtBoilUOM int; 
	Declare @isDraft bit;
	Declare @TrgtOG numeric(4,3);
	Declare @TrgtFG numeric(4,3);
	Declare @TrgtABV numeric(3,1);
	Declare @TrgtDensity numeric(6,3); 
	Declare @fk_TrgtDensityUOM int;
	Declare @TrgtColorAmt int;
	Declare @fk_TrgtColorUOM int; 
	Declare @TrgtBitternessAmt int;
	Declare @fk_TrgtBitterUOM int;
	Declare @Notes nvarchar(4000);
	--Declare @isCloud varchar(50);  -- this only gets populated when running on the cloud instance!!!
	Declare @status bit;
	Declare @evntNm varchar(200) = 'CustomerRecipe';

	Raiserror(N'[bhp].CloneRecipe:: recipeid:[%d] nu/name:[%s]...',0,1,@recipeid,@nuname);

	exec @rc = [di].IsSessStale @SessID=@SessID, @AutoClose=0, @Status=@status output, @mesgs=@mesg output, @UpdLst=1;
	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	-- this bit must be set in sharingmask to proceed w/cloning operation
	-- NOTE: the GUI checks this before we're here...but just in case!!!
	Select @cloneBitVal=BitVal From [bhp].SharingTypes Where Descr = 'Allow Clone';

	--set @BCastMode = ISNULL(@BCastMode,1);
	--exec [di].GetEnv @VarNm=N'cloud context mode',@varVal=@isCloud output, @dfltVal='off';
	--if ([di].[fn_ISTRUE](@isCloud) = 1)
	--	set @BCastMode = 0; -- if running on cloud don't broadcast!!!


	If Exists (Select 1 from [di].SessionMstr Where (SessID=@SessID) And ([RowID]=0))
	Begin
		exec [di].GetEnv @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

		if (@admuid = 0)
			raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);
	End

	If Not Exists (Select 1 from [bhp].RecipeJrnlMstr Where (RowID = @RecipeID))
	Begin
		-- should write and audit record here...
		Set @rc = 66007; -- non-existant recipe!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Not Exists (
		Select 1 
		from [bhp].RecipeJrnlMstr R
		Where (R.RowID = @RecipeID And (@cloneBitVal = (R.SharingMask & @cloneBitVal)))
	)
	Begin
		-- should write and audit record here...
		Declare @nm varchar(256); -- recipe name
		Select TOp (1) @nm = [Name] from [bhp].RecipeJrnlMstr Where (RowID = @RecipeID);
		Set @rc = 66106; -- recipe doesn't have sharing bit set 'on' allowing cloning!?
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@nm);
		Return @rc;
	End
	
	-- make sure name isn't in use already!?
	If Exists (
		Select 1 
		from [bhp].RecipeJrnlMstr M1
		Inner Join [bhp].RecipeJrnlMstr M2 On (M1.fk_DeployInfo = M2.fk_DeployInfo And M1.RowID = @RecipeID)
		Where (M2.[Name] = @NuName)
	)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66096; -- recipe name already used by deployment
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	SELECT 
		@recipeNm = RJM.[Name],
		@fk_BeerStyle = ISNULL(RJM.fk_BeerStyle,0),
		@CustID = Case RJM.[fk_CreatedBy] When 0 then @admuid else RJM.[fk_CreatedBy] end, -- aka: customer id
		@TrgtBatchAmt = ISNULL(RJM.BatchQty, 5.0),
		@fk_TrgtBatchUOM = case RJM.fk_BatchUOM when 0 then [bhp].fn_GetUOMIdByNm('gal') else RJM.fk_BatchUOM end,
		@TrgtBoilAmt = ISNULL(RJM.TargetBoilSize, 7),
		@fk_TrgtBoilUOM = case RJM.fk_BoilSizeUOM when 0 then [bhp].fn_GetUOMIdByNm('gal') else RJM.fk_BoilSizeUOM End,
		@TrgtOG = ISNULL(RJM.TargetOG,0),
		@TrgtFG = ISNULL(RJM.TargetFG,0),
		@TrgtABV = ISNULL(RJM.TargetABV,0),
		@TrgtDensity = ISNULL(RJM.TargetDensity,0),
		@fk_TrgtDensityUOM = case RJM.fk_TargetDensityUOM when 0 then [bhp].fn_GetUOMIdByNm('brix') else RJM.fk_TargetDensityUOM end,
		@TrgtColorAmt = ISNULL(RJM.TargetColor,0),
		@fk_TrgtColorUOM = case RJM.fk_TargetColorUOM When 0 then [bhp].fn_GetUOMIdByNm('srm') else RJM.fk_TargetColorUOM End,
		@TrgtBitternessAmt = ISNULL(RJM.TargetBitterness,0),
		@fk_TrgtBitterUOM = case RJM.fk_TargetBitternessUOM When 0 then [bhp].fn_GetUOMIdByNm('ibu') else RJM.fk_TargetBitternessUOM End,
		@isDraft = ISNULL(RJM.[isDraft],1),
		@notes = isnull(RJM.Notes, 'no notes (yet)!!!')
	  FROM [bhp].RecipeJrnlMstr AS RJM
	  Where (RJM.RowID = @RecipeID);

	  Set @rc = @@ROWCOUNT;

	  if (@rc = 0)
		Raiserror(N'unable to find recipe:[%d]...wtf!!!',16,1,@recipeID);

	Set @NuNotes = [di].[fn_IsNull](@NuNotes);
	If (@NuNotes is not null)
		Set @Notes = @NuNotes;


	/*
	** now call the 1st recipe creation procedure...this'll gen a new recipe id value!!!
	** NOTE: this proc creates mash,hop,water and aging binder entries. The entries will be 
	** set to '0' for hop binder (aka: no hop sched), 
	** set to the 'isDflt4Nu' rec from aging & mash.
	** and wtr will be set to 'isDflt4Nu' as well.
	** NOTE: if the 'isNu4dflt' value is not set in anyof the mstr schedules definitions...'0' is used.
	*/
	EXEC @rc = [bhp].AddCustRecipe
		@SessID = @SessID
		,@CustID = @CustID
		,@RecipeName = @NuName
		,@fk_BeerStyle = @fk_BeerStyle
		,@TrgtBatchAmt = @TrgtBatchAmt
		,@fk_TrgtBatchUOM = @fk_TrgtBatchUOM
		,@TrgtBoilAmt = @TrgtBoilAmt
		,@fk_TrgtBoilUOM = @fk_TrgtBoilUOM
		,@isDraft = @isDraft
		,@TrgtOG = @TrgtOG
		,@TrgtFG = @TrgtFG
		,@TrgtABV = @TrgtABV
		,@TrgtDensity = @TrgtDensity
		,@fk_TrgtDensityUOM = @fk_TrgtDensityUOM
		,@TrgtColorAmt = @TrgtColorAmt
		,@fk_TrgtColorUOM = @fk_TrgtColorUOM
		,@TrgtBitternessAmt = @TrgtBitternessAmt
		,@fk_TrgtBitterUOM = @fk_TrgtBitterUOM
		,@Notes = @Notes
		,@BCastMode = 0
		,@CloneID = @RecipeID
		,@RowID = @NuRecipeID OUTPUT;

	Raiserror(N'Recipe:[%s] target(s) cloned...',0,1,@RecipeNm);
	
	-- process any grains found on this recipe
	if (ISNULL(@CloneGrains,1) = 1)
	begin
		if exists (Select 1 
			from [bhp].RecipeGrains 
			where fk_RecipeJrnlMstrID=@RecipeID
		)
		begin
			Declare @nugrainrowid int;
			Declare @grainid int;
			Declare @grainuom int;
			Declare @grainstgid int;
			Declare @grainqty numeric(10,4);
			Declare @graincomment nvarchar(4000);
			Declare @grains nvarchar(4000);

			set @currrow = 0;
			while exists (Select 1 from [bhp].RecipeGrains where (fk_RecipeJrnlMstrID=@RecipeID And RowID > @currrow))
			begin
				Select Top (1)
					@currrow=[RowID],
					@grainid=fk_GrainMstrID,
					@grainuom=ISNULL(fk_GrainUOM,0),
					@grainstgid=ISNULL(fk_Stage,0),
					@grainqty=ISNULL(QtyOrAmount,0),
					@graincomment=ISNULL(Comment,N'no comment given...'),
					@grains=COALESCE(@grains + ',','') + GrainName
				from [bhp].RecipeGrains 
				Where (fk_RecipeJrnlMstrID=@RecipeID And RowID>@currrow)
				Order By RowID;

				EXECUTE @RC = [bhp].[AddRecipeGrain] 
					@SessID = @SessID
					,@fk_RecipeJrnlMstrID = @NuRecipeID
					,@fk_GrainMstrID = @grainid
					,@fk_GrainUOM = @grainuom
					,@fk_StageID = @grainstgid
					,@QtyOrAmt = @grainqty
					,@Comment = @graincomment
					,@BCastMode = 0
					,@RowID = @nugrainrowid OUTPUT;

				

			end -- endof while exists recipe grain(s)
			
			if (@grains is not null)
				Raiserror(N'Recipe Grain(s):[''%s''] cloned...',0,1,@grains);
		end
	end

	-- process any yeast(s) found on this recipe
	if (ISNULL(@CloneYeasts,1) = 1)
	begin
		if exists (Select 1 
			from [bhp].RecipeYeasts 
			where fk_RecipeJrnlMstrID=@RecipeID
		)
		begin
			Declare @nuyeastrowid int;
			Declare @yeastid int;
			Declare @yeastuom int;
			Declare @yeaststgid int;
			Declare @yeastqty numeric(10,4);
			Declare @yeastcomment nvarchar(4000);
			Declare @yeasts nvarchar(4000);

			set @currrow = 0;
			while exists (Select 1 from [bhp].RecipeYeasts where (fk_RecipeJrnlMstrID=@RecipeID And RowID > @currrow))
			begin
				Select Top (1)
					@currrow=RY.[RowID],
					@yeastid=RY.fk_YeastMstrID,
					@yeastuom=ISNULL(RY.fk_YeastUOM,0),
					@yeaststgid=ISNULL(RY.fk_Stage,0),
					@yeastqty=ISNULL(RY.QtyOrAmount,0),
					@yeastcomment=ISNULL(RY.Comment,N'no comment given...'),
					@yeasts=COALESCE(@yeasts + ',','') + Y.[Name]
				from [bhp].RecipeYeasts RY Inner join [bhp].YeastMstr Y On (RY.fk_YeastMstrID=Y.RowID)
				Where (RY.fk_RecipeJrnlMstrID=@RecipeID And RY.RowID>@currrow)
				Order By RY.RowID;

				EXECUTE @RC = [bhp].[AddRecipeYeast] 
					@SessID = @SessID
					,@fk_RecipeJrnlMstrID = @NuRecipeID
					,@fk_YeastMstrID = @yeastid
					,@fk_YeastUOM = @yeastuom
					,@fk_StageID = @yeaststgid
					,@QtyOrAmt = @yeastqty
					,@Comment = @yeastcomment
					,@BCastMode = 0
					,@RowID = @nuyeastrowid OUTPUT;

				

			end -- endof while exists recipe yeast(s)
			
			if (@yeasts is not null)
				Raiserror(N'recipe yeast(s):[''%s''] cloned...',0,1,@yeasts);
		end
	end

	-- process any extract(s) found on this recipe
	if (ISNULL(@CloneExtracts,1) = 1)
	begin
		if exists (Select 1 
			from [bhp].RecipeExtracts 
			where fk_RecipeJrnlMstrID=@RecipeID
		)
		begin
			Declare @nuextractrowid int;
			Declare @extractid int;
			Declare @extractuom int;
			Declare @extractstgid int;
			Declare @extractqty numeric(10,4);
			Declare @extractcomment nvarchar(4000);
			Declare @extracts nvarchar(4000);

			set @currrow = 0;
			while exists (Select 1 from [bhp].RecipeExtracts where (fk_RecipeJrnlMstrID=@RecipeID And RowID > @currrow))
			begin
				Select Top (1)
					@currrow=RE.[RowID],
					@extractid=RE.fk_ExtractMstrID,
					@extractuom=ISNULL(RE.fk_QtyOrAmtUOM,0),
					@extractstgid=ISNULL(RE.fk_Stage,0),
					@extractqty=ISNULL(RE.QtyOrAmt,0),
					@extractcomment=ISNULL(RE.Comment,N'no comment given...'),
					@extracts=COALESCE(@extracts + ',','') + E.[Name]
				from [bhp].RecipeExtracts RE Inner Join [bhp].ExtractMstr E On (RE.fk_ExtractMstrID=E.RowID)
				Where (RE.fk_RecipeJrnlMstrID=@RecipeID And RE.RowID>@currrow)
				Order By RE.RowID;

				EXECUTE @RC = [bhp].[AddRecipeExtract] 
					@SessID = @SessID
					,@fk_RecipeJrnlMstrID = @NuRecipeID
					,@fk_ExtractMstrID = @extractid
					,@fk_UOM = @extractuom
					,@fk_StageID = @extractstgid
					,@QtyOrAmt = @extractqty
					,@Comment = @extractcomment
					,@BCastMode = 0
					,@RowID = @nuextractrowid OUTPUT;

				

			end -- endof while exists recipe extract(s)
			
			if (@extracts is not null)
				Raiserror(N'recipe extract(s):[''%s''] cloned...',0,1,@extracts);
		end
	end

	if (ISNULL(@CloneWater,1) = 1)
	begin
		-- should only be (1) wtr profile record!!!
		if exists (select 1 
			from [bhp].RecipeWaterProfile 
			where fk_RecipeJrnlMstrID=@RecipeID And fk_RecipeJrnlMstrID = @NuRecipeID
		)
		begin
			declare @calcium numeric(4,1);
			declare @calciumUOMID int;
			declare @magnesium numeric(4,1);
			declare @magnesiumUOMID int;
			declare @sodium numeric(4,1);
			declare @sodiumUOMID int;
			declare @sulfate numeric(4,1);
			declare @sulfateUOMID int;
			declare @chloride numeric(4,1);
			declare @chloridUOMID int;
			declare @bicarb numeric(4,1);
			declare @bicarbUOMID int;
			declare @ph numeric(3,1);
			declare @phUOMID int;
			declare @famousID int;
			declare @wtrComments nvarchar(2000);
			declare @nuRecipeWtrProfID int;
			declare @currRecipeWtrProfID int; -- a recipe can only have (1) wtr profile!!!

			-- when a recipe is created (via addcustrecipe), it'll auto create a water profile
			-- record...could be a '0' record or, if a default is established...a default wtr profile
			-- grab the rowid for the 'new' recipe wtr profile here!!!
			select @currRecipeWtrProfID = RowID 
			from [bhp].RecipeWaterProfile 
			where fk_RecipeJrnlMstrID=@NuRecipeID;
		
			set @currrow=0;
			while exists (select 1 from [bhp].RecipeWaterProfile where fk_RecipeJrnlMstrID=@RecipeID and RowID>@currrow)
			begin
				Select Top (1)
					@currrow=[RowID]
					,@calcium = ISNULL([Calcium],0)
					,@calciumUOMID = ISNULL([fk_CalciumUOM], [bhp].fn_GetUOMIdByNm('ppm'))
					,@magnesium = ISNULL([Magnesium],0)
					,@magnesiumUOMID = ISNULL([fk_MagnesiumUOM], [bhp].fn_GetUOMIdByNm('ppm'))
					,@Sodium = ISNULL([Sodium],0)
					,@sodiumUOMID = ISNULL([fk_SodiumUOM], [bhp].fn_GetUOMIdByNm('ppm'))
					,@Sulfate = ISNULL([Sulfate],0)
					,@SulfateUOMID = ISNULL([fk_SulfateUOM], [bhp].fn_GetUOMIdByNm('ppm'))
					,@Chloride = ISNULL([Chloride],0)
					,@Chloride = ISNULL([fk_ChlorideUOM], [bhp].fn_GetUOMIdByNm('ppm'))
					,@bicarb = ISNULL([Bicarbonate],0)
					,@bicarbUOMID = ISNULL([fk_BicarbonateUOM], [bhp].fn_GetUOMIdByNm('ppm'))
					,@ph = ISNULL([Ph],0)
					,@phUOMID = ISNULL([fk_PhUOM], [bhp].fn_GetUOMIdByNm('ph'))
					,@famousID = ISNULL([fk_InitilizedByFamousWtrID],0)
					,@wtrcomments = ISNULL([Comments],'no comments given..')
				from [bhp].RecipeWaterProfile 
				Where (fk_RecipeJrnlMstrID=@RecipeID And RowID>@currrow)
				Order By RowID;

				EXECUTE @RC = [bhp].[ChgRecipeWaterProfile] 
					@SessID=@SessID
					,@RowID=@currRecipeWtrProfID
					,@Calcium=@calcium
					,@fk_CalciumUOM=@calciumUOMID
					,@Magnesium=@magnesium
					,@fk_MagnesiumUOM=@magnesiumUOMID
					,@Sodium=@sodium
					,@fk_SodiumUOM=@sodiumUOMID
					,@Sulfate=@sulfate
					,@fk_SulfateUOM=@sulfateUOMID
					,@Chloride=@chloride
					,@fk_ChlorideUOM=@chloridUOMID
					,@Bicarbonate=@bicarb
					,@fk_BicarbonateUOM=@bicarbUOMID
					,@Ph=@ph
					,@fk_PhUOM=@phUOMID
					,@fk_FamousWtrProfileID=@famousID
					,@Comments=@wtrComments
					,@BCastMode=0;

				Raiserror(N'recipe water profile cloned...',0,1);

			end -- endof while

		end -- endof if wtr profile
	end

	-- should only be (1) aging binder record!!!
	if (ISNULL(@CloneAging,1) = 1)
	begin
		if exists (Select 1 from [bhp].RecipeAgingSchedBinder where fk_RecipeJrnlMstrID=@RecipeID and fk_AgingSchedMstrID > 0)
		begin
			declare @ageSchedID int;
			declare @currAgeBinderID int; -- a recipe can only have (1) binding record!!!

			set @currrow=0;

			-- when a recipe is created (via addcustrecipe), it'll auto create a aging binding reference
			-- record to the '0' record or, if a default is established...a default aging profile
			-- is grabbed as the 'new' recipe aging profile here!!!
			select @currAgeBinderID=RowID 
			from [bhp].RecipeAgingSchedBinder 
			where fk_RecipeJrnlMstrID=@NuRecipeID;

			while exists (select 1 from [bhp].RecipeAgingSchedBinder where fk_RecipeJrnlMstrID=@RecipeID and RowID>@currrow)
			begin
				select top (1)
					@currrow=[RowID],
					@ageSchedID=fk_AgingSchedMstrID
				from [bhp].RecipeAgingSchedBinder Where (fk_RecipeJrnlMstrID=@RecipeID and RowID>@currrow)
				order by RowID;

				exec [bhp].ChgRecipeAgingSchedBinder 
					@SessID=@SessID, 
					@RowID=@currAgeBinderID, 
					@RecipeID=@NuRecipeID, 
					@SchedID=@ageSchedID, 
					@BCastMode=0;

			end -- endof while exists
			
			Raiserror(N'recipe aging schedule cloned...',0,1);
		end -- endof if aging sched binder
		
	end

	/*
	** Change hop schedule binding over to recipes hop schedule...if they have one!!!
	** NOTE: if the @clonehopschedasnu is set, then we 1st clone the hop schedule associated w/the recipe
	** and then bind up to the newly created (cloned) hop schedule INSTEAD OF creating a reference
	** to the schedule!!!
	*/
	if (ISNULL(@CloneHops,1) = 1)
	begin
		if exists (Select 1 
			from [bhp].RecipeHopSchedBinder 
			where fk_RecipeJrnlMstrID=@RecipeID And fk_HopSchedMstrID > 0
		)
		begin
			declare @hopSchedID int;
			declare @NuRecipeHopSchedBinderID int; -- a recipe can only have (1) binding record!!!
			declare @nuSchedID int;

			set @currrow=0;

			-- when a recipe is created (via addcustrecipe), it'll auto create a hop binding association
			-- record...by default it is a '0' record...otherwise known as...'no hop sched' defined yet!!!
			select @NuRecipeHopSchedBinderID=RowID 
			from [bhp].RecipeHopSchedBinder 
			where fk_RecipeJrnlMstrID=@NuRecipeID;
		
			-- if this is 'off'...then we just changed the binding for clone to reference the
			-- hop schedule...if 'on', then we clone the schedule, change its name, and establish
			-- a reference to that for the recipe
			if (ISNULL(@CloneHopSchedAsNu,0) = 0) 
			begin
				while exists (select 1 
					from [bhp].RecipeHopSchedBinder 
					where fk_RecipeJrnlMstrID=@RecipeID and RowID>@currrow
				)
				begin
					select top (1)
						@currrow=[RowID],
						@hopSchedID=fk_HopSchedMstrID
					from [bhp].RecipeHopSchedBinder Where (fk_RecipeJrnlMstrID=@RecipeID and RowID>@currrow)
					order by RowID;

					exec [bhp].ChgRecipeHopSchedBinder 
						@SessID=@SessID, 
						@RowID=@NuRecipeHopSchedBinderID, 
						@RecipeID=@NuRecipeID, 
						@SchedID=@hopSchedID, 
						@BCastMode=0;
						
					Raiserror(N'recipe set to reference hop schedule from recipe:[%s]...',0,1,@recipeNm);

				end -- endof while exists
			end
			else -- we need to clone the hop schedule 1st...then bind to that reference!!!
			begin
				-- get sched id to clone/copy
				Select @hopSchedID=fk_HopSchedMstrID 
				from [bhp].RecipeHopSchedBinder 
				WHere fk_RecipeJrnlMstrID=@RecipeID;
			
				-- copy/clone. NOTE: name will become: 'sched name -clone[timestamp]'...
				exec @rc = [bhp].CloneHopSched 
					@SessID=@SessID, 
					@SchedID=@hopSchedID, 
					@NuName=Null, -- proc will gen a name...eg: 'schedname - clone[timestmp]'
					@NuRowID=@nuSchedID output, 
					@BCastMode=0;

				Raiserror(N'hop schedule is cloned...',0,1);

				-- now bind to the copy/clone, or change reference if you will
				exec [bhp].ChgRecipeHopSchedBinder 
						@SessID=@SessID, 
						@RowID=@NuRecipeHopSchedBinderID, 
						@RecipeID=@NuRecipeID, 
						@SchedID=@nuSchedID, 
						@BCastMode=0;
				Raiserror(N'recipe set to reference cloned hop schedule...',0,1);
			end
		end -- endof if hop sched binder
		
	end

	if (ISNULL(@CloneMash,1) = 1)
	begin
		if exists (Select 1 
			from [bhp].RecipeMashSchedBinder 
			where fk_RecipeJrnlMstrID=@RecipeID And fk_MashSchedMstrID > 0
		)
		begin
			declare @mashSchedID int;
			declare @currMashBinderID int; -- a recipe can only have (1) binding record!!!

			set @currrow=0;
			select @currMashBinderID=RowID from [bhp].RecipeMashSchedBinder where fk_RecipeJrnlMstrID=@NuRecipeID;

			while exists (select 1 from [bhp].RecipeMashSchedBinder where fk_RecipeJrnlMstrID=@RecipeID and RowID>@currrow)
			begin
				select top (1)
					@currrow=[RowID],
					@mashSchedID=fk_MashSchedMstrID
				from [bhp].RecipeMashSchedBinder Where (fk_RecipeJrnlMstrID=@RecipeID and RowID>@currrow);

				exec [bhp].ChgRecipeMashSchedBinder 
					@SessID=@SessID, 
					@RowID=@currMashBinderID, 
					@RecipeID=@NuRecipeID, 
					@SchedID=@mashSchedID, 
					@BCastMode=0;

			end -- endof while exists
			Raiserror(N'recipe set to reference mash schedule from recipe:[%s]...',0,1,@recipeNm);
		end -- endof if mash sched binder
	end

	if (ISNULL(@CloneAdjuncts,1) = 1)
	begin
		if exists (select 1 from [bhp].RecipeIngredients where fk_RecipeJrnlMstrID=@RecipeID)
		begin
			declare @currTagRec bigint;
			declare @nuRecipeIngredientTagRec bigint;
			declare @nuRecipeIngredID bigint;
			declare @ingredQty numeric(10,4);
			declare @ingredStgID int;
			declare @ingredComment nvarchar(4000);
			declare @ingredUOMID int;
			declare @tagID bigint;
			declare @phrase nvarchar(1000);

			set @currbrow = 0;

			while exists (
				select 1 
				from [bhp].RecipeIngredients 
				where fk_RecipeJrnlMstrID=@RecipeID and RowID > @currbrow
			)
			begin
				select top (1)
					@currbrow = RowID,
					@ingredQty= ISNULL(QtyOrAmount,0.00),
					@ingredStgID = ISNULL(fk_Stage,0),
					@ingredUOMID = ISNULL(fk_IngredientUOM,0),
					@ingredComment = ISNULL(Comment, N'no comment given...'),
					@phrase = Phrase
				from [bhp].RecipeIngredients where fk_RecipeJrnlMstrID=@RecipeID and RowID > @currbrow
				Order By RowID;

				exec [bhp].AddRecipeIngredientV2
					@SessID=@SessID,
					@RecipeID=@NuRecipeID,
					@QtyOrAmt=@ingredQty,
					@fk_IngredientUOM=@ingredUOMID,
					@fk_StageID=@ingredStgID,
					@Comment=@ingredComment,
					@Phrase = @phrase,
					@BCastMode=0,
					@RowID=@nuRecipeIngredID output;

				set @currTagRec=0;
				while exists (select 1 
					from [bhp].RecipeIngredient_Tags
					where fk_RecipeIngredient=@currbrow and RowID>@currTagRec
				)
				begin
					Select Top (1)
						@currTagRec=RowID,
						@tagID=fk_TagID
					from [bhp].RecipeIngredient_Tags
					where fk_RecipeIngredient=@currbrow and RowID>@currTagRec
					Order By RowID;

					exec [bhp].AddRecipeIngredientTag
						@SessID=@SessID,
						@fk_RecipeIngredient=@nuRecipeIngredID,
						@fk_TagID=@tagID,
						@RowID=@nuRecipeIngredientTagRec output,
						@BCastMode=0;
				end -- endof while exists recipe ingredient binder entries...

			end -- endof recipe ingredients

		end -- endof if recipe has ingredients
		Raiserror(N'recipe ingredients cloned...',0,1);
	end

	return @rc;
end
go

checkpoint
go
