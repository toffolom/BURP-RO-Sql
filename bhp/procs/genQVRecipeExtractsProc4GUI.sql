USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[genQVRecipeExtracts]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[genQVRecipeExtracts]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].genQVRecipeExtracts;
Print 'Proc:: [bhp].genQVRecipeExtracts dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].genQVRecipeExtracts (
	@SessID varchar(256),
	@rid int -- recipe id value
)
with encryption
as
begin
	--set nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @SessStatus bit;
	
	exec @rc = [di].IsSessStale @SessID=@SessID, @AutoClose=1, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		Raiserror(@Mesg,0,1);
		Return @rc;
	End
	
	SELECT 
		E.[RowID]
		,E.[Name]
		,[KnownAs1]
		,[KnownAs2]
		,[KnownAs3]
		,ISNULL([fk_ExtractMfrID],0) As [fk_ExtractMfrID]
		--,[ExtractMfrNm]
		,ISNULL([NbrOfRecipesUsedIn],0) As [NbrOfRecipesUsedIn]
		,ISNULL([fk_SolidUOM],0) As [fk_SolidUOM]
		--,[SolidUOM]
		,ISNULL([BegSolidsAmt],0.00) As [BegSolidsAmt]
		,ISNULL([EndSolidsAmt],0.00) As [EndSolidsAmt]
		,ISNULL([fk_ColorUOM],0) As [fk_ColorUOM]
		--,[ColorUOM]
		,ISNULL([BegColorAmt],0.00) As [BegColorAmt]
		,ISNULL([EndColorAmt],0.00) As [EndColorAmt]
		,ISNULL([fk_BitternessUOM],0) As [fk_BitternessUOM]
		--,[BitternessUOM]
		,ISNULL([BegBitternessAmt],0.00) As [BegBitternessAmt]
		,ISNULL([EndBitternessAmt],0.00) As [EndBitternessAmt]
		,ISNULL([IsHopped],0) As IsHopped
		,ISNULL([fk_HopUOM],0) As [fk_HopUOM]
		--,[HopUOM]
		,ISNULL([HopAmt],0.00) As [HopAmt]
		,ISNULL([IsDiastatic],0) As [IsDiastatic]
		--,[EnteredOn]
		--,[EnteredBy]
		,ISNULL(E.Comment, 'no comment given...') As Comment
	FROM [bhp].ExtractMstr E
	Inner Join [bhp].RecipeExtracts RY On (E.RowID = RY.fk_ExtractMstrID)
	--Inner Join [bhp].YeastManufacturers YM On (YM.RowID = Y.fk_YeastMfr)
	Where (RY.fk_RecipeJrnlMstrID = @rid)
	ORDER BY Name;
	
	Return @@Error;
end
go

print 'Proc:: [bhp].genQVRecipeExtracts created...';
go


revoke execute on [bhp].genQVRecipeExtracts to [Public];
go


checkpoint
