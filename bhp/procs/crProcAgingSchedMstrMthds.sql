USE [BHP1-RO]
GO

/****** Object:  StoredProcedure [bhp].[GetAgingSchedMstrRecs]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[GetAgingSchedMstrRecs]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[GetAgingSchedMstrRecs];
Print 'Proc:: [bhp].GetAgingSchedMstrRecs dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[AddAgingSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[AddAgingSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[AddAgingSchedMstrRec];
Print 'Proc:: [bhp].AddAgingSchedMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgAgingSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[ChgAgingSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[ChgAgingSchedMstrRec];
Print 'Proc:: [bhp].ChgAgingSchedMstrRec dropped!!!';
END
GO

/****** Object:  StoredProcedure [bhp].[ChgAgingSchedMstrRec]    Script Date: 03/15/2011 15:59:54 ******/
IF OBJECT_ID(N'[bhp].[DelAgingSchedMstrRec]',N'P') IS NOT NULL
BEGIN
DROP PROCEDURE [bhp].[DelAgingSchedMstrRec];
Print 'Proc:: [bhp].DelAgingSchedMstrRec dropped!!!';
END
GO

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
create proc [bhp].GetAgingSchedMstrRecs (
	@SessID varchar(256),
	@HideZeroRow bit = 0 -- if we should or should NOT return the 'pls select...' row aka: zero row!!!
)
with encryption
as
begin
	Declare @SessRowID bigint;
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @admid bigint;
	Declare @SessStatus bit;

	if (1=0)
	Begin
		Select
			Cast(Null as int) as RowID,
			Cast(Null as nvarchar(200)) as Name,
			Cast(Null as bigint) as fk_CreatedBy,
			Cast(Null as int) as TotRecipesUsedIn,
			Cast(Null as nvarchar(4000)) as [Comments],
			Cast(Null as bit) as UnBind,
			Cast(Null as bit) as IsDfltForNu,
			Cast(Null as int) As DeployID,
			Cast(Null as int) As SharingMask,
			Cast(Null as varchar(200)) as SharingMaskAsCSV
		Set FmtOnly Off;
		Return;
	End
	

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @SessRowID=[RowID] from [di].SessionMstr Where (SessID=@SessID);

	exec [di].[GetEnv] @VarNm='Admin UID', @VarVal=@admid output;
	set @admid = ISNULL(@admid,0);

	Begin Try
		Drop Table #tmpList;
	End Try
	Begin Catch
	End Catch

	Create Table #tmpList (
		[RowID] int,
		[Name] nvarchar(200),
		fk_CreatedBy bigint,
		TotRecipesUsedIn int,
		[Comments] nvarchar(4000),
		UnBind bit,
		IsDfltForNu bit,
		DeployID int,
		SharingMask int,
		SharingMaskAsCSV varchar(200),
		FakeRow int identity(0,1)
	);

	Insert into #tmpList (RowID, Name, fk_CreatedBy, TotRecipesUsedIn, Comments, UnBind, IsDfltForNu, DeployID, SharingMask, SharingMaskAsCSV)
	values (0,N'pls select...',0,0,N'pls enter comment...',0,0,0,0,'Private');

	If (@SessRowID > 0)
	Begin
		
		Insert into #tmpList (
			RowID, 
			Name, 
			fk_CreatedBy, 
			TotRecipesUsedIn, 
			Comments, 
			UnBind, 
			IsDfltForNu, 
			DeployID,
			SharingMask,
			SharingMaskAsCSV
		)
		SELECT 
			ASM.[RowID]
			,ASM.[Name]
			,ASM.[fk_CreatedBy]
			,ISNULL(XX.Cnt,0)
			,ISNULL(ASM.[Comments],N'not set')
			,Convert(bit, 0)
			,ISNULL(isDfltForNu, 0)
			,ISNULL(ASM.fk_DeployInfo,0)
			,ISNULL(ASM.SharingMask,0)
			,ASM.SharingMaskAsCSV
		FROM [bhp].[AgingSchedMstr] ASM
		Inner Join [di].SessionMstr S 
		On (ASM.fk_DeployInfo = S.fk_DeployInfo And (ASM.fk_CreatedBy=S.fk_CustID OR ASM.fk_CreatedBy = @admid))
		Left Join (
			Select fk_AgingSchedMstrID, Count(*) As Cnt
			From [bhp].RecipeAgingSchedBinder
			Group By fk_AgingSchedMstrID
		) As XX
		On (ASM.RowID = XX.fk_AgingSchedMstrID)
		Where (ASM.RowID > 0 And S.SessID = @SessID)
		Order By ASM.Name;

	End
	Else -- its a '0' session...return all aging scheds!!!
	Begin

		Insert into #tmpList (
			RowID, 
			Name, 
			fk_CreatedBy, 
			TotRecipesUsedIn, 
			Comments, 
			UnBind, 
			IsDfltForNu, 
			DeployID,
			SharingMask,
			SharingMaskAsCSV
		)
		SELECT 
			ASM.[RowID]
			,ASM.[Name]
			,Case ASM.[fk_CreatedBy] 
				When 0 then 
					ISNULL(
						(
							Select Top (1) convert(bigint,VarVal) 
							from [bhp].Environment 
							Where (VarNm = 'Admin UID')
						)
						,0
					)
				else ASM.[fk_CreatedBy] 
			End
			,ISNULL(XX.Cnt,0) As TotRecipesUsedIn
			,ISNULL(ASM.[Comments],N'not set') As [Comments]
			,Convert(bit, 0) As UnBind
			,ISNULL(isDfltForNu, 0) As IsDfltForNu
			,ISNULL(ASM.fk_DeployInfo,0)
			,ISNULL(ASM.SharingMask,0)
			,ASM.SharingMaskAsCSV
		FROM [bhp].[AgingSchedMstr] ASM
		Left Join (
			Select fk_AgingSchedMstrID, Count(*) As Cnt
			From [bhp].RecipeAgingSchedBinder
			Group By fk_AgingSchedMstrID
		) As XX
		On (ASM.RowID = XX.fk_AgingSchedMstrID)
		Where (ASM.RowID > 0)
		Order By ASM.Name;

	End

	Select RowID, Name, fk_CreatedBy, TotRecipesUsedIn, Comments, UnBind, IsDfltForNu, DeployID, SharingMask, SharingMaskAsCSV
	From #tmpList
	Where (FakeRow > (case ISNULL(@HideZeroRow,0) when 1 then 0 else -1 end))
	Order By FakeRow;
	
	Return @@ERROR;
end
go

print 'Proc:: [bhp].GetAgingSchedMstrRecs created...';
go

/*
exec [bhp].GetAgingSchedMstrRecs @SessID='FE5ADA79-49CF-4B6A-9FB1-4A412E9F81A7',@HideZeroRow=0;
*/

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].AddAgingSchedMstrRec (
	@SessID varchar(256),
	@Name nvarchar(200),
	@fk_CreatedBy bigint,
	@Comment nvarchar(4000) = Null,
	@isDflt4Nu bit = 0,
	@SharingMask int = 0,
	@BCastMode bit = 1,
	@RowID int output
)
with encryption
as
begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @admuid bigint;
	Declare @xml xml;
	Declare @old nvarchar(200);
	Declare @chgs table ([RowID] int);
	Declare @curr int; -- current row;
	--Declare @cloudCtx varchar(20); 
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'AgingSched';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	exec [di].[GetEnv] @VarNm='Admin UID',@varVal=@admuid output,@dfltVal=0;

	if (@admuid = 0)
		raiserror('WARNING: environment var:[''Admin UID''] not set!!!',0,1);

	set @fk_CreatedBy = case @fk_CreatedBy when 0 then @admuid else @fk_CreatedBy end;

	--exec [di].[GetEnv] @VarNm='cloud context mode',@varVal=@cloudCtx output, @dfltVal='false';
	--if ([bhp].fn_ISTRUE(@cloudCtx) = 1)
	--	set @BCastMode = 0;
	
	/*
	** NOTE: Need to check the role mask of this user/session and verify that they can, indeed, create a aging schedule!!! Oct22-2014
	*/
	If Not Exists (Select * from [di].CustMstr Where RowID = @fk_CreatedBy)
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66018; -- this nbr represents a non-existant customer id!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End
	
	Insert Into [bhp].AgingSchedMstr (
		[Name]
		,[fk_CreatedBy]
		,[Comments]
		,[fk_DeployInfo]
		,isDfltForNu
		,SharingMask
	)
	Select
		rtrim(ltrim(@Name)),
		@fk_CreatedBy,
		ISNULL(@Comment,N'no comment given...'),
		ISNULL((Select Top (1) S.fk_DeployInfo From [di].SessionMstr S Where (S.SessID = @SessID)), -1),
		ISNULL(@isDflt4Nu,0),
		ISNULL(@SharingMask,0);
	
	Set @RowID = Scope_Identity();

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	begin
		exec @rc = [bhp].GenBurpAgingSchedMstrMesg @id=@RowID, @evnttype='add', @SessID=@SessID, @Mesg = @xml output;
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	end

	/*
	** before we're outta here...make sure only (1) row has the isDflt4Nu setting turned 'on'...
	*/
	if (@isDflt4Nu = 1)
	begin
		update [bhp].AgingSchedMstr
			set isDfltForNu = 0
		Output Deleted.RowID into @chgs(RowID)
		where (RowID != @RowID and isDfltForNu = 1);
		
		-- if anything changed we need to broadcast this out...
		If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		begin
			if exists (Select 1 from @chgs)
			begin
				set @curr = 0;
				while exists (select * from @chgs where RowID > @curr)
				begin
					select top (1) @curr = RowID from @chgs where RowID > @curr Order By RowID;
					select @old = [Name] from [bhp].AgingSchedMstr Where RowID = @curr; -- it really hasn't changed...but we need to output in xml

					exec @rc = [bhp].GenBurpAgingSchedMstrMesg @id=@curr, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

					set @xml.modify('
						declare namespace b="http://burp.net/recipe/evnts";
						insert attribute old {sql:variable("@old")}
						into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt/b:Info/b:Name)[1]
					');

					exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
				end
			end
		end
	end
	
	Return @@Error;
End
go

Print 'Proc:: [bhp].AddAgingSchedMstrRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].DelAgingSchedMstrRec (
	@SessID varchar(256),
	@RowID int,
	@UnBind bit = 0, -- will force the deletion of the aging schedule detail rec(s) assoc w/this parent id.
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @vcun varchar(20);
	Declare @xml xml;
	Declare @stepFrag xml;
	Declare @stepDoc xml;
	Declare @currow int;
	--Declare @cloudCtx varchar(20);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = 'AgingSched';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	set @Unbind = coalesce(@Unbind,0);

	Set @vcun = case @Unbind When 1 then 'true' else 'false' end;

	--Raiserror('[bhp].DelAgingSchedMstrRec:: @RowID:[%d] @unbind:[%s]...',0,1,@RowID,@vcun);
	

	
	If Exists (Select * from [bhp].RecipeAgingSchedBinder Where (fk_AgingSchedMstrID = @RowID And @UnBind = 0))
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66046; -- this means aging schedule is used by some customer recipe(s)!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--exec [di].[GetEnv] @VarNm='cloud context mode',@varval=@cloudCtx output, @DfltVal='false';
	--if ([bhp].fn_ISTRUE(@cloudCtx) = 1)
	--	set @BCastMode = 0;
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		exec @rc = [bhp].GenBurpAgingSchedMstrMesg @id=@RowID, @evnttype='del', @SessID=@SessID, @Mesg = @xml output;
	
	Update [bhp].RecipeAgingSchedBinder
		Set fk_AgingSchedMstrID = 0
	Where (fk_AgingSchedMstrID = @RowID);

	/*
	** walk thru any child rec(s) and gen a burp belch msg for ea. and stuff into this burp belch mesg...
	*/
	if (@BCastMode = 1)
	begin
		Set @currow = 0;
		While Exists (Select * from [bhp].AgingSchedDetails Where (RowID > @currow) And (fk_AgingSchedMstrID = @RowID))
		Begin
			Select Top (1) @currow = RowID
			From [bhp].AgingSchedDetails 
			Where (RowID > @currow) And (fk_AgingSchedMstrID = @RowID)
			Order By RowID;

			Exec [bhp].GenBurpAgingSchedStepMesg @id=@currow, @evnttype='del', @SessID=@SessID, @Mesg = @stepDoc output;

			with xmlnamespaces('http://burp.net/recipe/evnts' as b, default 'http://burp.net/recipe/evnts')
			select @stepFrag = @stepDoc.query('(/Burp_Belch/Payload/AgingSched_Evnt/Step_Info)');

			set @xml.modify('
				declare namespace b="http://burp.net/recipe/evnts";
				insert sql:variable("@stepFrag") as last into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt)[1]
			');

		End
	End

	Delete [bhp].AgingSchedDetails Where (fk_AgingSchedMstrID = @RowID);
	
	Delete [bhp].AgingSchedMstr Where (RowID = @RowID);
	
	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))if (@BCastMode = 1)
		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	
	Return @@Error;
	
End
go

Print 'Proc:: [bhp].DelAgingSchedMstrRec created...';
go

/*
** use this guid for testing...
** '00000000-0000-0000-0000-000000000000'
*/
Create Proc [bhp].ChgAgingSchedMstrRec (
	@SessID varchar(256),
	@RowID int,
	@Name nvarchar(200),
	@fk_CreatedBy bigint,
	@Comment nvarchar(4000) = Null,
	@isDflt4Nu bit = 0,
	@SharingMask int,
	@BCastMode bit = 1
)
with encryption
as
begin
	--Set Nocount on;
	
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @xml xml;
	Declare @oldinfo Table ([Name] nvarchar(200));
	Declare @old nvarchar(200);
	Declare @chgs table ([RowID] int);
	Declare @curr int; -- current row;
	--Declare @cloudCtx varchar(20);
	Declare @SessStatus bit;
	Declare @evntNm nvarchar(100) = N'AgingSched';

	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
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
	
	If (Not Exists (Select * from [bhp].AgingSchedMstr Where RowID = @RowID And RowID > 0))
	Begin
		-- should write and audit record here...someone trying to change an unknown hop type!?
		Set @rc = 66020; -- this nbr represents an uknown hop schedule id
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@RowID);
		Return @rc;
	End
	

	
	If ((@fk_CreatedBy Is Not Null) And (Not Exists (Select * from [di].vw_CustomerMstr Where RowID = @fk_CreatedBy)))
	Begin
		-- should write and audit record here...someone trying use a non-monetary uom value
		Set @rc = 66018; -- this nbr represents a non-existant customer id!!!
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--exec [di].[GetEnv] @VarNm='cloud context mode',@varval=@cloudCtx output, @DfltVal='false';
	--if ([bhp].fn_ISTRUE(@cloudCtx) = 1)
	--	set @BCastMode = 0;

		
	Update Top (1) [bhp].AgingSchedMstr
	Set
		[Name]=@Name,
		[fk_CreatedBy]=ISNULL(@fk_CreatedBy,0),
		[Comments]=ISNULL(@Comment,'Not Set'),
		isDfltForNu = ISNULL(@isDflt4Nu,0),
		SharingMask = ISNULL(@SharingMask,0)
	Output deleted.Name into @oldinfo([Name])
	Where (RowID=@RowID And RowID > 0);

	If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
	Begin
		Select @old = [Name] From @oldinfo;
	
		exec @rc = [bhp].GenBurpAgingSchedMstrMesg @id=@RowID, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

		set @xml.modify('
			declare namespace b="http://burp.net/recipe/evnts";
			insert attribute old {sql:variable("@old")}
			into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt/b:Info/b:Name)[1]
		');

		exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
	End

	/*
	** before we're outta here...make sure only (1) row has the isDflt4Nu setting turned 'on'...
	*/
	if (@isDflt4Nu = 1)
	begin
		update [bhp].AgingSchedMstr
			set isDfltForNu = 0
		Output Deleted.RowID into @chgs(RowID)
		where (RowID != @RowID and isDfltForNu = 1);
		
		If (@BCastMode = 1 And Exists (Select 1 from [di].[vw_DeploymentPublications] Where [Name]=@evntNm))
		Begin
			-- if anything changed we need to broadcast this out...
			if exists (Select 1 from @chgs)
			begin
				set @curr = 0;
				while exists (select * from @chgs where RowID > @curr)
				begin
					select top (1) @curr = RowID from @chgs where RowID > @curr Order By RowID;
					select @old = [Name] from [bhp].AgingSchedMstr Where RowID = @curr; -- it really hasn't changed...but we need to output in xml

					exec @rc = [bhp].GenBurpAgingSchedMstrMesg @id=@curr, @evnttype='chg', @SessID=@SessID, @Mesg = @xml output;

					set @xml.modify('
						declare namespace b="http://burp.net/recipe/evnts";
						insert attribute old {sql:variable("@old")}
						into (/b:Burp_Belch/b:Payload/b:AgingSched_Evnt/b:Info/b:Name)[1]
					');

					exec [bhp].[PostToBWPRouter] @inMsg=@xml, @msgNm=@evntNm;
				end
			end
		End
	end
	
	Return @rc;
End
go

Print 'Proc:: [bhp].ChgAgingSchedMstrRec created...';
go

checkpoint