use [BHP1-RO]
go

if OBJECT_ID(N'[bhp].genQVRecipeGrains',N'P') IS NOT NULL
Begin
	drop proc [bhp].genQVRecipeGrains;
	print 'proc:: [bhp].[genQVRecipeGrains] dropped!!!';
End
Go

/*
** synopsis: generates a result that contains a (given recipe id (@rid)) entries...NOTE: can be empty.
*/
create proc [bhp].genQVRecipeGrains (
	@SessID varchar(256),
	@rid int -- recipe id value (from recipejrnlmstr tbl).
)
with encryption
as
begin
	--set nocount on;

	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @SessStatus bit;

	exec @rc = [di].IsSessStale @SessID=@SessID, @AutoClose=1, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		Raiserror(@Mesg,0,1);
		Return @rc;
	End

--SELECT OBJECT_NAME(@@PROCID) [procnm], SYSTEM_USER, USER, name, type, usage FROM sys.user_token;

	--If Not Exists (Select * from [di].SessionMstr Where SessID = convert(uniqueidentifier,@SessID))
	--Begin
	--	-- should write and audit record here...someone trying to read data w/o logging in!?
	--	Set @rc = 66006; -- this nbr represents users is not logged in.
	--	Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
	--	Raiserror(@Mesg,16,1);
	--	Return @rc;
	--End
	
	/*
	** NOTE: this query taken right outta proc: [bhp].GetGrainMasterRecs...
	** NOTE: this proc is then added to the DS in VS so i can get just the grains by a given recipe.
	*/
	SELECT
		G.[RowID]
		,G.[Name]
		,G.[degLStart]
		,G.[degLEnd]
		,ISNULL(G.[SRM],0.0) As SRM
		/*
		** degEBC is computed. Formula is: ((2.65)*[degLStart]-(1.2))
		** problem is that if degLStart is zero the outcome is -1.2...we can't drop the table at this point
		** too much bother...just fix it here...mjt 19Aug2014
		** to fix we'll compute it here when we pull out and fix the situation.
		*/
		,Case ISNULL(G.degLStart,0)
			When 0 Then 0.0
			Else (((2.65) * G.degLStart) - 1.2) 
		End As degEBC 
		,ISNULL(G.[fk_GrainType],0) As fk_GrainType
		-- ,[GrainType]
		,ISNULL(G.[RowSize],0) As RowSize
		,ISNULL(G.[KnownAs1], 'not set') As KnownAs1
		,ISNULL(G.[KnownAs2], 'not set') As KnownAs2
		,ISNULL(G.[KnownAs3], 'not set') As KnownAs3
		,ISNULL(G.[fk_GrainMfr],0) As fk_GrainMfr
		,ISNULL(G.[NbrOfRecipesUsedIn],0) As NbrOfrecipesUsedIn
		,G.[fk_CountryID]
		,ISNULL(G.[isModified],1) As isModified
		,ISNULL(G.[isUnderModified],0) As isUnderModified
		,G.[EnteredOn]
		,G.[EnteredBy]
		,ISNULL(G.PotentialGravityBeg,0.00) As PotentialGravityBeg
		,ISNULL(G.PotentialGravityEnd,0.00) As PotentialGravityEnd
		,ISNULL(G.[Comment],'not set') As Comment
	From [bhp].RecipeGrains As RG 
	Inner Join [bhp].RecipeJrnlMstr M On (M.RowID = RG.fk_RecipeJrnlMstrID And M.RowID = @rid)
	Inner Join [bhp].GrainMstr G On (RG.fk_GrainMstrID = G.RowID);


	return ISNULL(@rc, 1);

End
go

print 'proc:: [bhp].genQVRecipeGrains created...'
go

revoke execute on [bhp].[genQVRecipeGrains] to [public];
go

--If Exists (Select * from sys.certificates where name = 'RecipeRepoCert')
--Begin
--	Begin Try
--		ADD SIGNATURE TO OBJECT::genQVRecipeGrains
--		BY CERTIFICATE [RecipeRepoCert]
--		WITH PASSWORD = 'eye4got@@';

--		print 'signature added to proc using cert:[RecipeRepoCert]...';
--	End Try
--	Begin Catch
--		declare @e nvarchar(1028)
--		set @e = ERROR_MESSAGE();
--		raiserror('%s',0,1,@e);
--	End Catch
--End
--go