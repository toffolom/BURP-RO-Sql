USE [BHP1-RO]
GO

/****** Object:  View [bhp].[vw_RecipeListn4MstrDropDwn]    Script Date: 4/10/2018 3:52:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


if object_id(N'[bhp].GetMstrRecipeListFilteredByHop',N'P') is not null
begin
	Drop Proc [bhp].GetMstrRecipeListFilteredByHop;
	Print 'Proc:: [bhp].GetMstrRecipeListFilteredByHop dropped!!!';
end
go

Create Proc [bhp].GetMstrRecipeListFilteredByHop (
	@SessID varchar(256),
	@CustID bigint = null,
	@HopCSVList varchar(2000) = null -- list of hop id's to use in the search...must be a csv list!!!
)
with encryption
as
	Declare @rc int;
	Declare @mesg nvarchar(2000);

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
	
	If Not Exists (Select * from [di].[SessionMstr] Where SessID = convert(uniqueidentifier,@SessID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Set @HopCSVList = Case When @HopCSVList = Space(0) Then Null Else @HopCSVList End;

	--Raiserror(N'proc:: GetMstrRecipeListFilteredByHop -> @CustID:[%I64d] @HopCSVList:[%s]...',0,1,@CustID, @HopCSVList);

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
							Inner Join [di].[CustMstr] C On (convert(bigint, varval) = C.RowID And E.VarNm = 'Admin UID')
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
		Inner Join [di].[CustMstr] C On (RJM.fk_CreatedBy = C.RowID)
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
							Inner Join [di].[CustMstr] C On (convert(bigint, varval) = C.RowID And E.VarNm = 'Admin UID')
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
		Inner Join [di].[CustMstr] C On (RJM.fk_CreatedBy = C.RowID)
		Where (RJM.fk_CreatedBy = Case @CustID 
				When 0 then ISNULL((Select Top (1) convert(bigint,VarVal) from [di].[Environment] Where (VarNm = 'Admin UID')),0)
				else @CustID 
			End
		And RJM.RowID > 0)
		Order By RJM.[Name];
	End

	if (@HopCSVList IS NULL)
	Begin
		Select T.* from #TmmpListn As T Order By T.Name;
	End
	Else
	Begin

		Declare @stmt nvarchar(max);
			Declare @wclause nvarchar(2000);
			Declare @tot int = 0;
			Declare @val nvarchar(50) = SPACE(0);

			Select * Into #csv From string_split(@HopCSVList, ',');
			Set @tot = @@ROWCOUNT;
			
			While Exists (Select 1 From #csv Where [value] > @val)
			Begin
				Select Top (1) @val = [value], @wclause = COALESCE(@wclause + ' OR ','') + N'HT.RowID = ' + [value] 
				From #csv
				Where ([value] > @val)
				Order By [value];
			End

		Set @stmt = N'
Select Distinct T.* 
From #TmmpListn As T
Inner Join (
SELECT RJ.RowID
	From [bhp].RecipeHopSchedBinder RHSB 
	inner join [bhp].RecipeJrnlMstr RJ On (RHSB.fk_RecipeJrnlMstrID = RJ.RowID And RJ.RowID > 0)
	Inner Join [bhp].HopSchedMstr HSM On (RHSB.fk_HopSchedMstrID = HSM.RowID)
	Inner Join [bhp].HopSchedDetails HSD On (HSM.RowID = HSD.fk_HopSchedMstrID)
	Inner Join [bhp].[HopTypesV2] HT On (HSD.fk_HopTypID = HT.RowID And HT.RowID > 0)
	Where (' + @wclause + ')
	Group BY RJ.RowID
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

exec [bhp].GetMstrRecipeListFilteredByHop @SessID='00000000-0000-0000-0000-000000000000', @CustID=NULL, @HopCSVList=''
exec [bhp].GetMstrRecipeListFilteredByHop @SessID='00000000-0000-0000-0000-000000000000', @CustID=0, @HopCSVList='23,18'
exec [bhp].GetMstrRecipeListFilteredByHop @SessID='00000000-0000-0000-0000-000000000000', @CustID=1002, @HopCSVList='23,18,55'

*/
