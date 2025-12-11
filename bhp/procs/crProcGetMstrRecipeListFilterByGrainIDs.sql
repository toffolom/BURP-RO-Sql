USE [BHP1-RO]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


if object_id(N'[bhp].GetMstrRecipeListFilteredByGrain',N'P') is not null
begin
	Drop Proc [bhp].GetMstrRecipeListFilteredByGrain;
	Print 'Proc:: [bhp].GetMstrRecipeListFilteredByGrain dropped!!!';
end
go

Create Proc [bhp].GetMstrRecipeListFilteredByGrain (
	@SessID varchar(256),
	@CustID bigint = null,
	@GrainCSVList varchar(2000) = null -- list of hop id's to use in the search...must be a csv list!!!
)
with encryption
as
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @csv table (grain nvarchar(256));

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
			cast(Null As int) as StyleID,
			cast(Null As nvarchar(200)) as [Style],
			cast(Null As int) as FakeID
		Set fmtonly off;
		return;
	end
	
	If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @GrainCSVList = Case When @GrainCSVList = Space(0) Then Null Else @GrainCSVList End;

	--Raiserror(N'proc:: GetMstrRecipeListFilteredByGrain -> @CustID:[%I64d] @GrainCSVList:[%s]...',0,1,@CustID, @GrainCSVList);

	Create Table #TmmpListn (
		RowID int,
		[Name] nvarchar(256),
		fk_CustID bigint,
		CustName nvarchar(256),
		TotBatches int null,
		TotLikes int,
		TotDislikes int,
		StyleID int null,
		[Style] nvarchar(200) null,
		FakeID int identity(1,1)
	);
	
	If (@CustID IS NULL OR @CustID = 0)
	Begin
		Insert into #TmmpListn (RowID, [Name], fk_CustID, CustName, TotBatches, TotLikes, TotDislikes, StyleID, [Style])
		Select
			RJM.RowID, 
			RJM.Name, 
			Case RJM.fk_CreatedBy 
				When 0 then ISNULL((Select Top (1) convert(bigint,VarVal) from [di].[Environment] Where (VarNm = 'Admin UID')),0)
				else RJM.[fk_CreatedBy] 
			End As fk_CustID,
			Case RJM.[fk_CreatedBy]
				When 0 Then
					ISNULL
					(
						(
							select top (1) C.BHPUid 
							From [di].[Environment] E 
							Inner Join [di].CustMstr C On (convert(bigint, varval) = C.RowID And E.VarNm = 'Admin UID')
						)
						,C.BHPUid
					)
				Else C.BHPUid
			End As CustName, 
			RJM.totBatchesMade,
			0 As TotLikes,
			0 As TotDislikes,
			RJM.fk_BeerStyle,
			(Select Top (1) CategoryName from [bhp].AHABeerStyle Where (RowID = RJM.fk_BeerStyle)) As [Style]
		From [bhp].RecipeJrnlMstr RJM
		Inner Join [di].CustMstr C On (RJM.fk_CreatedBy = C.RowID)
		Where (RJM.RowID > 0)
		Order By RJM.[Name];
	End
	Else
	Begin
		Insert into #TmmpListn (RowID, [Name], fk_CustID, CustName, TotBatches, TotLikes, TotDislikes, StyleID, [Style])
		Select
			RJM.RowID, 
			RJM.Name, 
			Case RJM.[fk_CreatedBy] 
				When 0 then ISNULL((Select Top (1) convert(bigint,VarVal) from [di].[Environment] Where (VarNm = 'Admin UID')),0)
				else RJM.[fk_CreatedBy] 
			End,
			Case RJM.[fk_CreatedBy]
				When 0 Then
					ISNULL
					(
						(
							select top (1) C.BHPUid 
							From [di].[Environment] E 
							Inner Join [di].CustMstr C On (convert(bigint, varval) = C.RowID And E.VarNm = 'Admin UID')
						)
						,C.BHPUid
					)
				Else C.BHPUid
			End, 
			RJM.totBatchesMade,
			0,
			0,
			RJM.fk_BeerStyle,
			(Select Top (1) CategoryName from [bhp].AHABeerStyle Where (RowID = RJM.fk_BeerStyle))
		From [bhp].RecipeJrnlMstr RJM
		Inner Join [di].CustMstr C On (RJM.fk_CreatedBy = C.RowID)
		Where (RJM.fk_CreatedBy = Case @CustID 
				When 0 then ISNULL((Select Top (1) convert(bigint,VarVal) from [di].[Environment] Where (VarNm = 'Admin UID')),0)
				else @CustID 
			End
		And RJM.RowID > 0)
		Order By RJM.[Name];
	End

	if (@GrainCSVList IS NULL)
	Begin
		Select T.* From #TmmpListn As T Order By T.[Name];
	End
	Else -- looking for recipe(s) with specific grain(s). csv controls what grains your looking for in recipe(s)
	Begin
			Declare @stmt nvarchar(max);
			Declare @wclause nvarchar(2000);
			Declare @tot int = 0;
			Declare @val nvarchar(50) = SPACE(0);

			Select * Into #csv From string_split(@GrainCSVList, ',');
			Set @tot = @@ROWCOUNT;
			
			While Exists (Select 1 From #csv Where [value] > @val)
			Begin
				Select Top (1) @val = [value], @wclause = COALESCE(@wclause + ' OR ','') + N'RG.fk_GrainMstrID = ' + [value] 
				From #csv
				Where ([value] > @val)
				Order By [value];
			End

			Set @stmt = N'
Select Distinct T.* 
From #TmmpListn As T
Inner Join (
	SELECT RJ.RowID
	FROM [bhp].[RecipeGrains] RG
	inner join [bhp].[RecipeJrnlMstr] RJ On (RG.fk_RecipeJrnlMstrID = RJ.RowID And RJ.RowID > 0)
	where (' + @wclause + ')
	group by RJ.RowID
	' + case @tot when 1 then '' Else N'having count(*) > 1' End + '
) As XX
On (T.RowID = XX.RowID)
Order By T.Name;';
--print @stmt;
			exec dbo.sp_ExecuteSql @Stmt=@stmt;
		End

	Return @@ERROR;
GO

/*

exec [bhp].GetMstrRecipeListFilteredByGrain @SessID='00000000-0000-0000-0000-000000000000', @CustID=NULL, @GrainCSVList=''
exec [bhp].GetMstrRecipeListFilteredByGrain @SessID='00000000-0000-0000-0000-000000000000', @CustID=0, @GrainCSVList='16'
exec [bhp].GetMstrRecipeListFilteredByGrain @SessID='00000000-0000-0000-0000-000000000000', @CustID=1002, @GrainCSVList='23,18'

*/
