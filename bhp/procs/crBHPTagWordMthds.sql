use [BHP1-RO]
go

begin try
	drop proc [bhp].GetBHPTagWords;
	print 'Proc: [bhp].GetBHPTagWords dropped!!!';
end try
begin catch
	print 'proc: [bhp].GetBHPTagWords doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].AddBHPTagWord;
	print 'Proc: [bhp].AddBHPTagWord dropped!!!';
end try
begin catch
	print 'proc: [bhp].AddBHPTagWord doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].DelBHPTagWord;
	print 'Proc: [bhp].DelBHPTagWord dropped!!!';
end try
begin catch
	print 'proc: [bhp].DelBHPTagWord doesn''t exist...no prob!!!';
end catch
go

begin try
	drop proc [bhp].ChgBHPTagWord;
	print 'Proc: [bhp].ChgBHPTagWord dropped!!!';
end try
begin catch
	print 'proc: [bhp].ChgBHPTagWord doesn''t exist...no prob!!!';
end catch
go


create proc [bhp].GetBHPTagWords (
	@SessID varchar(256)
)
with encryption
as
Begin

	declare @rc int;
	declare @mesg nvarchar(2000);
	declare @admuid bigint;
	declare @rows int;
	Declare @status bit;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @mesgs=@mesg output, @updLst=1;

	if (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	/*
	** this lil gem will return an extra column called TotRefs that holds a running count of
	** how many recipe references there are to ea. ingredient search tag value.
	*/
	select X.RowID, X.Name, ISNULL(X.Lang,'en_us') As [Lang], ISNULL(Y.TotRefs,0) TotRefs
	from [bhp].BHPTagWords As X
	cross apply (
			select S.RowID, S.Name, 0 TotRefs
			from [bhp].BHPTagWords S 
			Left Join [bhp].RecipeIngredient_Tags R On (S.RowID = fk_RecipeIngredient and S.RowID > 0) 
			where R.fk_RecipeIngredient is null And S.RowID > 0
			Union All
			select U.RowID, U.Name, Count(*) As TotRefs
			from [bhp].BHPTagWords U 
			Inner Join [bhp].RecipeIngredient_Tags As X On (U.RowID = X.fk_RecipeIngredient And U.RowID > 0)
			Group By U.RowID, U.Name
	) As Y
	Where (X.RowID = Y.RowID)
	Order By X.Name;

	Return @@ERROR;
End
Go


create proc [bhp].AddBHPTagWord (
	@SessID nvarchar(256),
	@Name nvarchar(100),
	@RowID bigint output,
	@BCastMode bit = 1
)
with encryption
as
begin
	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @status bit;
	Declare @evntNm nvarchar(100) = 'TagWord';

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @mesgs=@mesg output, @updLst=1;

	if (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	insert into [bhp].BHPTagWords([Name],[Lang],[EnteredOn])
	values(@Name, 'en_us', getdate());

	Select @RowID = SCOPE_IDENTITY();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Exec @rc = [bhp].GenBurpBHPTagWordMesg @id = @RowID, @Evnttype='add', @SessID = @SessID, @Mesg = @xml output;
		Exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	end

	Return @@ERROR;
end
go

Create Proc [bhp].DelBHPTagWord (
	@SessID varchar(256),
	@RowID bigint,
	@BCastMode bit = 1
)
with encryption
as
begin
	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @status bit;

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @mesgs=@mesg output, @updLst=1;

	if (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select 1 From [bhp].RecipeIngredient_Tags Where (fk_TagID = @RowID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66090; -- ingredient in use by recipe(s).
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	If Exists (Select 1 From [bhp].Recipe_Tags Where (fk_TagID = @RowID))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66090; -- ingredient in use by recipe(s).
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	if (@BCastMode = 1)
		Exec @rc = [bhp].GenBurpBHPTagWordMesg @id = @RowID, @Evnttype='del', @SessID = @SessID, @Mesg = @xml output;
	
	Delete Top (1) [bhp].BHPTagWords Where (RowID = @RowID);
	
	if (@BCastMode = 1)
		Exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm='TagWord';

	Return @@ERROR;

end
go

Create proc [bhp].ChgBHPTagWord (
	@SessID varchar(256),
	@RowID bigint,
	@Name nvarchar(100),
	@BCastMode bit = 1
)
with encryption
as
Begin
	declare @rc int;
	declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table ([Name] nvarchar(100));
	Declare @old nvarchar(100);
	Declare @status bit;
	Declare @evntNm nvarchar(100) = 'TagWord';

	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @status=@status output, @mesgs=@mesg output, @updLst=1;

	if (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Update [bhp].BHPTagWords
		Set [Name] = @Name
	Output Deleted.[Name] into @oldinfo([Name])
	Where (RowID = @RowID);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		Select @old = [Name] from @oldinfo;

		Exec @rc = [bhp].GenBurpBHPTagWordMesg @id = @RowID, @Evnttype='chg', @SessID = @SessID, @Mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:Tag_Evnt/b:Tag/b:Name)[1]
		');

		Exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	end

	Return @@ERROR;
End
go

checkpoint
go
