USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_RecipeListn4MstrDropDwn]    Script Date: 4/10/2018 3:52:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


if object_id(N'[bhp].GetRecipeListn4MstrDD',N'P') is not null
begin
	Drop Proc [bhp].GetRecipeListn4MstrDD;
	Print 'Proc:: [bhp].GetRecipeListn4MstrDD dropped!!!';
end
go

Create Proc [bhp].GetRecipeListn4MstrDD (
	@SessID varchar(256),
	@CustID bigint = null,
	@StyleID int = 0
)
with encryption, execute as 'sticky'
as
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @admuid bigint;
	Declare @SessRowID bigint;
	Declare @status bit;
	Declare @sql nvarchar(max);

	if (1=0)
	begin
		select
			cast(Null As int) as RowID,
			cast(Null As nvarchar(256)) as [Name],
			cast(Null As bigint) as fk_CustID,
			cast(Null As nvarchar(256)) as CustName,
			cast(Null As int) as TotBatches,
			cast(Null As int) as TotLikes,
			cast(Null As int) as TotDislikes,
			cast(Null As nvarchar(200)) as [Style],
			cast(Null As int) as StyleID,
			cast(Null As int) as SharingMask,
			cast(Null As numeric(6,2)) As TargetBatchVol,
			cast(Null As numeric(6,2)) As TargetBoilVol,
			cast(Null As numeric(6,3)) As TargetDensity,
			cast(Null As int) As DensityUOMID,
			cast(Null As int) as TargetColor,
			cast(Null As int) as ColorUOMID,
			cast(Null As int) as TargetBitterness,
			cast(Null As int) as BitterUOMID,
			cast(Null As nvarchar(4000)) As Comments,
			cast(Null As int) As fk_ClonedFromID,
			cast(Null As int) as FakeID;
			
		Set fmtonly off;
		return;
	end

	Set @StyleID = ISNULL(@StyleID,0);
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = @SessID)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	-- NOTE: the zero row in SessMstr represents a 'admin' session!!!
	Select @SessRowID = [RowID] from [di].SessionMstr Where (SessID=@SessID);

	exec [di].GetEnv @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

	if (@admuid = 0)
		raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

	--Raiserror(N'GetRecipeListn4MstrDD:: session rowid:[%I64d] custid:[%I64d]...',0,1,@SessRowID,@custid);

	If (@CustID < 0) -- only return the 'new' row...which happens on initial login event.
	Begin
		Select 
			-99 As RowID, 
			'new...' As [Name],
			case @SessRowID
			When 0 Then @admuid
			Else (Select Top (1) CustomerNbr From di.vw_SessionInfo Where (SessionID=@SessID))
			End As fk_CustID,
			Case @SessRowID
			WHen 0 THen
				ISNULL(
					(
						select top (1) C.BHPUid 
						From di.Environment E 
						Inner Join di.vw_CustomerMstr C On (convert(bigint, varval) = C.RowID And E.VarNm = 'Admin UID')
					)
					,'N/a'
				)
			Else
				(Select Top (1) CustName from di.vw_SessionInfo Where SessionID=@SessID)
			End As CustName, 
			0 As TotBatches,
			0 As TotLikes,
			0 As TotDislikes,
			(Select Top (1) CategoryName from bhp.AHABeerStyle Where (RowID = 0)) As [Style],
			0 As StyleID,
			0 As SharingMask,
			0.00 As TargetBatchVol,
			0.00 As TargetBoilVol,
			0.00 As TargetDensity,
			0 As DensityUOMID,
			0 As TargetColor,
			0 As ColorUOMID,
			0 As TargetBitterness,
			0 As BitterUOMID,
			N'new recipe...press ''Builder'' to create!!!' As Comments,
			0 As ClonedFromID,
			0 As FakeID;
		Return 0;
	End

	-- 1st create a temp tbl to hold output
	set @Sql = N'

Create Table #TmmpListn (
	RowID int,
	[Name] nvarchar(256),
	fk_CustID bigint,
	CustName nvarchar(256),
	TotBatches int null,
	TotLikes int,
	TotDislikes int,
	[Style] nvarchar(200) null,
	StyleID int null,
	SharingMask int,
	TargetBatchVol numeric(6,2),
	TargetBoilVol numeric(6,2),
	TargetDensity numeric(6,3),
	DensityUOMID int,
	TargetColor int,
	ColorUOMID int,
	TargetBitterness int,
	BitterUOMID int,
	Comments nvarchar(4000) null,
	fk_ClonedFromID int not null,
	FakeID int identity(1,1)
);

';
	
	/*
	** if query being submitted is on the admin session...we show all recipe(s)
	** that are NOT in a 'private' sharing mode!!! And belong to the deployment
	** logged into!!!
	*/
	If (@SessRowID = 0)
	Begin
		Set @sql = @sql + '

Insert into #TmmpListn (
	RowID, 
	[Name], 
	fk_CustID, 
	CustName, 
	TotBatches, 
	TotLikes, 
	TotDislikes,  
	[Style],
	StyleID, 
	SharingMask,
	TargetBatchVol,
	TargetBoilVol,
	TargetDensity,
	DensityUOMID,
	TargetColor,
	ColorUOMID,
	TargetBitterness,
	BitterUOMID,
	Comments,
	fk_ClonedFromID
)
Select
	RJM.RowID, 
	RJM.Name, 
	Case RJM.[fk_CreatedBy] 
		When 0 then ISNULL((Select Top (1) convert(bigint,VarVal) from di.Environment Where (VarNm = ''Admin UID'')),0)
		else RJM.[fk_CreatedBy] 
	End,
	Case RJM.[fk_CreatedBy]
		When 0 Then
			ISNULL
			(
				(
					select top (1) C.BHPUid 
					From [di].[Environment] E 
					Inner Join [di].vw_CustomerMstr C On (convert(bigint, varval) = C.RowID And E.VarNm = ''Admin UID'')
				)
				,C.BHPUid
			)
		Else C.BHPUid
	End, 
	RJM.totBatchesMade,
	0,
	0,
	RJM.BeerStyle, --(Select Top (1) CategoryName from bhp.AHABeerStyle Where (RowID = RJM.fk_BeerStyle)),
	RJM.fk_BeerStyle,
	ISNULL(RJM.SharingMask,0),
	Coalesce(RJM.TargetQty, RJM.BatchQty,0.00),
	ISNULL(RJM.TargetBoilSize,0.00),
	ISNULL(RJM.TargetDensity,0.00),
	ISNULL(RJM.fk_TargetDensityUOM,0),
	ISNULL(RJM.TargetColor,0),
	ISNULL(RJM.fk_TargetColorUOM,0),
	ISNULL(RJM.TargetBitterness,0),
	ISNULL(RJM.fk_TargetBitternessUOM,0),
	ISNULL(RJM.Notes,N''no comments given...''),
	ISNULL(RJM.fk_ClonedFrom,0)
From bhp.RecipeJrnlMstr RJM
Inner Join [di].vw_CustomerMstr C On (RJM.fk_CreatedBy = C.RowID)
Inner Join [di].vw_SessionInfo S On (C.DeploymentRowID = S.DeploymentRowID)
Where (ISNULL(RJM.SharingMask,0) != bhp.fn_GetSharingBitValByNm(''private''))
And RJM.RowID > 0 And S.SessionID = @InSessID' +
case @StyleID When 0 Then '' Else ' And RJM.fk_BeerStyle=@InStyleID ' End + '
Order By RJM.[Name];';



	End
	Else -- get cust recipe(s) and all other recipe(s) not marked as 'private'!!!
	Begin
		Set @Sql = @Sql + '
Insert into #TmmpListn (
	RowID, 
	[Name], 
	fk_CustID, 
	CustName, 
	TotBatches, 
	TotLikes, 
	TotDislikes,  
	[Style],
	StyleID, 
	SharingMask,
	TargetBatchVol,
	TargetBoilVol,
	TargetDensity,
	DensityUOMID,
	TargetColor,
	ColorUOMID,
	TargetBitterness,
	BitterUOMID,
	Comments,
	fk_ClonedFromID
)
Select
	RJM.RowID, 
	RJM.Name, 
	Case RJM.[fk_CreatedBy] 
		When 0 then ISNULL((Select Top (1) convert(bigint,VarVal) from di.Environment Where (VarNm = ''Admin UID'')),0)
		else RJM.[fk_CreatedBy] 
	End As fk_CustID,
	Case RJM.[fk_CreatedBy]
		When 0 Then
			ISNULL
			(
				(
					select top (1) C.BHPUid 
					From di.Environment E 
					Inner Join [di].vw_CustomerMstr C On (convert(bigint, varval) = C.RowID And E.VarNm = ''Admin UID'')
				)
				,C.BHPUid
			)
		Else C.BHPUid
	End As CustName, 
	RJM.totBatchesMade,
	0,
	0,
	RJM.BeerStyle,
	RJM.fk_BeerStyle,
	ISNULL(RJM.SharingMask,0),
	Coalesce(RJM.TargetQty, RJM.BatchQty,0.00),
	ISNULL(RJM.TargetBoilSize,0.00),
	ISNULL(RJM.TargetDensity,0.00),
	ISNULL(RJM.fk_TargetDensityUOM,0),
	ISNULL(RJM.TargetColor,0),
	ISNULL(RJM.fk_TargetColorUOM,0),
	ISNULL(RJM.TargetBitterness,0),
	ISNULL(RJM.fk_TargetBitternessUOM,0),
	ISNULL(RJM.Notes,N''no comments given...''),
	ISNULL(RJM.fk_ClonedFrom,0)
From bhp.RecipeJrnlMstr RJM
Inner Join [di].vw_CustomerMstr C On (RJM.fk_CreatedBy = C.RowID)
Inner Join [di].vw_SessionInfo S On (C.DeploymentRowID = S.DeploymentRowID)
Where (RJM.fk_CreatedBy = @InCustID)
And (RJM.RowID > 0) And S.SessionID = @InSessID' +
case @StyleID When 0 Then '' Else ' And RJM.fk_BeerStyle=@InStyleID ' End + '
Union 
Select
	RJM.RowID, 
	RJM.Name, 
	Case RJM.[fk_CreatedBy] 
		When 0 then ISNULL((Select Top (1) convert(bigint,VarVal) from di.Environment Where (VarNm = ''Admin UID'')),0)
		else RJM.[fk_CreatedBy] 
	End As fk_CustID,
	Case RJM.[fk_CreatedBy]
		When 0 Then
			ISNULL
			(
				(
					select top (1) C.BHPUid 
					From di.Environment E 
					Inner Join [di].vw_CustomerMstr C On (convert(bigint, varval) = C.RowID And E.VarNm = ''Admin UID'')
				)
				,C.BHPUid
			)
		Else C.BHPUid
	End As CustName, 
	RJM.totBatchesMade,
	0,
	0,
	RJM.BeerStyle,
	RJM.fk_BeerStyle,
	ISNULL(RJM.SharingMask,0),
	Coalesce(RJM.TargetQty, RJM.BatchQty,0.00),
	ISNULL(RJM.TargetBoilSize,0.00),
	ISNULL(RJM.TargetDensity,0.00),
	ISNULL(RJM.fk_TargetDensityUOM,0),
	ISNULL(RJM.TargetColor,0),
	ISNULL(RJM.fk_TargetColorUOM,0),
	ISNULL(RJM.TargetBitterness,0),
	ISNULL(RJM.fk_TargetBitternessUOM,0),
	ISNULL(RJM.Notes,N''no comments given...''),
	ISNULL(RJM.fk_ClonedFrom,0)
From bhp.RecipeJrnlMstr RJM
Inner Join [di].vw_CustomerMstr C On (RJM.fk_CreatedBy = C.RowID)
Inner Join [di].vw_SessionInfo S On (C.DeploymentRowID = S.DeploymentRowID)
Where (RJM.fk_CreatedBy != @InCustID)
And RJM.RowID > 0 
And S.SessionID = @InSessID
And RJM.SharingMask != bhp.fn_GetSharingBitValByNm(''private'')' +
case @StyleID When 0 Then '' Else ' And RJM.fk_BeerStyle=@InStyleID ' End + '
Order By RJM.[Name];';
	End


--DoNuOnly:

-- lastly stuff in the 'new' row at top of list and return results to client.
	Set @Sql = @Sql + '

/*
** the ''new'' record for master recipe list on gui
** will attempt to preserve the login session cust id value
** so if ''new'' is selected and the recipe created...it''ll have the creators right ID value!!!
*/
set identity_insert #TmmpListn on;

Insert into #TmmpListn (
	RowID, 
	[Name], 
	fk_CustID, 
	CustName, 
	TotBatches, 
	TotLikes, 
	TotDislikes,  
	[Style], 
	StyleID,
	SharingMask,
	TargetBatchVol,
	TargetBoilVol,
	TargetDensity,
	DensityUOMID,
	TargetColor,
	ColorUOMID,
	TargetBitterness,
	BitterUOMID,
	Comments,
	fk_ClonedFromID,
	FakeID
)
Select 
	-99 As RowID, 
	''new...'' As [Name],
	case @InSessRowID
	When 0 Then @InAdmUID
	Else (Select Top (1) CustomerNbr From [di].vw_SessionInfo Where (SessionID=@InSessID))
	End As fk_CustID,
	Case @InSessRowID
	WHen 0 THen
		ISNULL(
			(
				select top (1) C.BHPUid 
				From di.Environment E 
				Inner Join [di].vw_CustomerMstr C On (convert(bigint, varval) = C.RowID And E.VarNm = ''Admin UID'')
			)
			,''N/a''
		)
	Else
		(Select Top (1) CustName from [di].vw_SessionInfo Where SessionID=@InSessID)
	End As CustName, 
	0 As TotBatches,
	0 As TotLikes,
	0 As TotDislikes,
	(Select Top (1) CategoryName from bhp.AHABeerStyle Where (RowID = 0)) As [Style],
	0 As StyleID,
	0 As SharingMask,
	0.00 As TargetBatchVol,
	0.00 As TargetBoilVol,
	0.00 As TargetDensity,
	0 As DensityUOMID,
	0 As TargetColor,
	0 As ColorUOMID,
	0 As TargetBitterness,
	0 As BitterUOMID,
	N''new recipe...press ''''Builder'''' to create!!!'' As Comments,
	0 As ClonedFromID,
	0 As FakeID;

Set Identity_Insert #TmmpListN off;

Select 
	RowID, 
	[Name], 
	fk_CustID, 
	CustName, 
	TotBatches, 
	TotLikes, 
	TotDislikes,  
	[Style],
	StyleID, 
	SharingMask,
	TargetBatchVol,
	TargetBoilVol,
	TargetDensity,
	DensityUOMID,
	TargetColor,
	ColorUOMID,
	TargetBitterness,
	BitterUOMID,
	Comments,
	fk_ClonedFromID,
	FakeID
From #TmmpListn 
Order By FakeID;
';
--print @sql;
	Exec @rc = dbo.sp_ExecuteSql 
		@Stmt=@Sql, 
		@Params=N'@InSessID varchar(256), @InSessRowID bigint, @InCustID bigint, @InStyleID int, @InAdmUID bigint',
		@InSessID=@SessID,
		@InSessRowID=@SessRowID,
		@InCustID=@CustID,
		@InStyleID=@StyleID,
		@InAdmUID=@admuid;

	Return @rc;
GO

/*
--use BHP1-RO
--go

Execute as user = 'BHPApp';

declare @s varchar(256);
declare @cc int;
declare @msg nvarchar(4000);
declare @sql nvarchar(max);
declare @did varchar(256); -- deployment id
declare @custNbr bigint;

select @did=DeploymentID from di.vw_DeploymentInfo where rowid = 0;

set @sql = N'exec di.BHPUserLoginV4 @user=@inUsr, @pswd=@inPswd, @lang=@inLang, @deployid=@inDID, @cc=@outCC output, @mesg=@outMsg output';

select top(0) * into #foo from di.vw_SessionInfo;

insert into #foo (
	[RowID]
	,[SessionID]
	,[CustomerNbr]
	,[CustName]
	,[LangID]
	,[Lang]
	,[CreatedOn]
	,[ClosedOn]
	,[LastActivityTS]
	,EmailAddr
	,RoleBitMask
	,[Roles]
	,DeploymentID
	,DeploymentName
	,DeploymentRowID
)
exec dbo.sp_ExecuteSql 
	@Sql=@Sql,
	@Params=N'@inUsr nvarchar(256),@inPswd nvarchar(50),@inLang nvarchar(20),@inDID varchar(256),@outCC int output, @outMsg nvarchar(4000) output',
	@inUsr='mighty',
	@inPswd='foobar',
	@inLang='en_us',
	@inDID=@did,
	@outCC=@cc output,
	@outMsg=@msg output;

select top (1) @s=SessionID, @custNbr=CustomerNbr from #foo;

exec bhp.GetRecipeListn4MstrDD @SessID=@s, @CustID=@custNbr, @StyleID=0;

exec di.BHPUserLogoutV4 @SessID=@s, @cc=@cc output, @mesg=@msg output;
select @s [Session],@cc [@cc], @msg [@Mesg];

drop table #foo;

Revert;
go

*/
