use [BHP1-RO]
go

if object_id(N'tools.SetupDeployment',N'P') is not null
begin
	Drop Proc tools.SetupDeployment;
	Print 'Proc:: tools.SetupDeployment dropped!!!';
end
go

Create Proc tools.SetupDeployment (
	@SessID varchar(256),
	@DeployGUID varchar(256),
	@BusinessName varchar(200),
	@Descr nvarchar(4000) = null,
	@SysAdminEmail varchar(200),
	@UsrAdminEmail varchar(200),
	@UsrLoginPswd varchar(50), -- passwd for user admin login.
	@UsrAlias varchar(200),
	@PrimaryContactName varchar(200) = null,
	@PrimaryPh varchar(50) = null
)
with encryption
as
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @SessRowID bigint;
	Declare @rows int;

	If (di.fn_ISNULL(@DeployGUID) IS NULL or TRY_CONVERT(UNIQUEIDENTIFIER, @DeployGUID) IS NULL)
	Begin
		Raiserror(N'Param:[@DeployGUID] CANNOT be null (or must be uniqidentifier)...aborting!!!',16,1);
		Return -1;
	End

	If (di.fn_IsNull(@SysAdminEmail) is null)
	Begin
		Raiserror(N'Param:[@SysAdminEmail] CANNOT be null...aborting!!!',16,1);
		Return -1;
	End
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @SessRowID=[RowID] From di.SessionMstr Where SessID=@SessID;

	If (ISNULL(@SessRowID,-1) != 0 OR @SessID != '00000000-0000-0000-0000-000000000000')
	Begin
		Raiserror(N'Session does NOT have permission to perform action. Request Aborted!!!',16,1);
		Return -1;
	End

	If Exists (Select 1 from di.Deployments Where RowID = 0)
	Begin
		Update di.Deployments
			Set
				Fk_DeploymentType = (Select Max(BitVal) From di.DeploymentTypes),
				Name = @BusinessName,
				Descr = COALESCE(di.fn_ISNULL(@Descr),'local deployment.'),
				DeploymentID = @DeployGUID,
				fk_OwnerInfoID = 0,
				Notes = N'this is your local deployment information...DO NOT CHANGE!!!',
				Verified = 1,
				DeployedOn = GETDATE()
		Where (RowID = 0);

		Set @rc = @@ERROR;
	End
	Else
	Begin
		Set Identity_Insert di.Deployments On;

		Insert into di.Deployments (RowID, Fk_DeploymentType, Name, Descr, DeploymentID, Fk_OwnerInfoID, Notes, Verified)
		Select
			0,
			(Select Max(BitVal) From di.DeploymentTypes),
			@BusinessName,
			COALESCE(@Descr,'local deployment.'),
			@DeployGUID,
			0,
			N'this is your local deployment information...DO NOT CHANGE!!!',
			1;

		Set Identity_Insert di.Deployments Off;

		Set @rc = @@ERROR;
	End

	-- make sure the 'unknown' deplyment rec is established!!!
	If Not Exists (Select * from di.Deployments Where RowID = -1)
	Begin
		Set Identity_Insert di.Deployments On;

		Insert into di.Deployments (RowID, Fk_DeploymentType, Name, Descr, DeployedOn, DeploymentID, Fk_OwnerInfoID, Notes, Verified)
		Select
			-1,
			0,
			'unknown',
			'unknown deployment',
			0,
			'11111111-1111-1111-1111-111111111111',
			0,
			N'this is for unknown deployment event handling...DO NOT CHANGE!!!',
			0;

		Set Identity_Insert di.Deployments Off;
	End

	-- install the primary contact!!!
	If (di.fn_ISNULL(@SysAdminEmail) is not null)
	Begin

		Delete di.Contacts;

		Insert into di.Contacts(Email, [Name], Ph, IsPrimary, Fk_OwnerInfoID)
		Values(ISNULL(@SysAdminEmail,'not set'), ISNULL(@PrimaryContactName,'not set'), ISNULL(@PrimaryPh,'(000)000-0000'),1, 0);
	End

	-- remove any/all recipe(s)...must be done to remove custmstr rec(s) 1st!!!
	Declare @CurrRowID int = 0;
	Declare @RecipeNm nvarchar(256);
	While Exists (Select * from bhp.RecipeJrnlMstr Where RowID > @CurrRowID)
	Begin
		Select Top (1) 
			@CurrRowID=[RowID], @RecipeNm=[Name]
		From bhp.RecipeJrnlMstr 
		Where [RowID] > @CurrRowID 
		Order By [RowID];
		Raiserror(N'Removing Customer Recipe:[''%s''] now...',0,1,@RecipeNm);
		Exec bhp.DelCustRecipe @SessID=@SessID, @RowID=@CurrRowID, @BCastMode=0;
	End 

	-- now clear out any hop schedule(s)...
	Set @CurrRowID=0;
	Declare @SchedNm nvarchar(200);
	While Exists (Select * from bhp.HopSchedMstr Where RowID > @CurrRowID)
	Begin
		Select Top (1) 
			@CurrRowID=[RowID], @SchedNm=[Name]
		From bhp.HopSchedMstr 
		Where [RowID] > @CurrRowID 
		Order By [RowID];
		Raiserror(N'Removing Hop Schedule:[''%s''] now...',0,1,@SchedNm);
		Exec bhp.DelHopSchedMstrRec @SessID=@SessID, @UnBind=1, @RowID=@CurrRowID, @BCastMode=0;
	End

	-- now clear out any aging schedule(s)...
	Set @CurrRowID=0;
	While Exists (Select * from bhp.AgingSchedMstr Where RowID > @CurrRowID)
	Begin
		Select Top (1) 
			@CurrRowID=[RowID], @SchedNm=[Name]
		From bhp.AgingSchedMstr 
		Where [RowID] > @CurrRowID 
		Order By [RowID];
		Raiserror(N'Removing Aging Schedule:[''%s''] now...',0,1,@SchedNm);
		Exec bhp.DelAgingSchedMstrRec @SessID=@SessID, @UnBind=1, @RowID=@CurrRowID, @BCastMode=0;
	End

	-- now clear out any mash schedule(s)...
	Set @CurrRowID=0;
	While Exists (Select * from bhp.MashSchedMstr Where RowID > @CurrRowID)
	Begin
		Select Top (1) 
			@CurrRowID=[RowID], @SchedNm=[Name]
		From bhp.MashSchedMstr 
		Where [RowID] > @CurrRowID 
		Order By [RowID];
		Raiserror(N'Removing Mash Schedule:[''%s''] now...',0,1,@SchedNm);
		Exec bhp.DelMashSchedMstrRec @SessID=@SessID, @UnBind=1, @RowID=@CurrRowID, @BCastMode=0;
	End
	

	-- establish customer master rec(s)...these are passed into sproc..
	-- Clear out 1st...
	Delete di.CustMstr Where RowID > 0;
	-- make sure zero rec exists 1st...

	If Not Exists (Select * from di.CustMstr Where RowID = 0)
	Begin
		Set Identity_Insert di.CustMstr On;

		Insert into di.CustMstr(RowID, fk_DeployInfo, [Name], BHPUid, BHPPwd, 
			Hint, RoleBitMask, AllowMultiSession, AllowLogin, AllowNotices, 
			DisplayAs, Verified, EnteredOn, fk_LangID, fk_LastBeerDrank)
		Select
			0,0,'pls select...','pls select...','notset!!))',
			'this is for integrity refs', 
			(select SUM(BitVal) From di.RoleMstr), 1, 0, 0,
			'pls select...', 0, 0, 1, 0;

		Set Identity_Insert di.CustMstr Off;
	End

	Declare @Roles int;
	Declare @NuCustID bigint;

	select @Roles = BitVal From di.RoleMstr Where Name = 'Admin';

	Exec di.AddCustMstrRec @SessID=@SessID, @Name='sysadmin', @DisplayAs='administrator',@BHPUid=@SysAdminEmail,@BHPPswd='f@@Bar!!',
			@Roles=@Roles, @AllowMulti=1, @AllowLogin=0, @RowID=@NuCustID Output;

	-- now update the ENvironment table(s) to reflect the new 'Admin UID' value...
	-- 1st the bhp schema...
	Update bhp.Environment
		Set VarVal=@NuCustID
	Where (VarNm='Admin UID');
	
	Set @rows=@@ROWCOUNT;

	If (@rows = 0)
	Begin
		Insert into bhp.Environment(VarNm, VarVal, Notes)
		Values ('Admin UID',@NuCustID,'<Notes><Note nbr="1">this is administrator id found in [di].[CustMstr]</Note></Notes>');
	End

	-- then the di schema...
	Update di.Environment
		Set VarVal=@NuCustID
	Where (VarNm='Admin UID');
	
	Set @rows=@@ROWCOUNT;

	If (@rows = 0)
	Begin
		Insert into di.Environment(VarNm, VarVal, Notes)
		Values ('Admin UID',@NuCustID,'<Notes><Note nbr="1">this is administrator id found in [di].[CustMstr]</Note></Notes>');
	End

	-- add the user administrator...1st user of system.
	select @Roles = SUM(BitVal) From di.RoleMstr Where Name In ('Admin','Recipe Creator','Brewer');

	Exec di.AddCustMstrRec @SessID=@SessID, @Name=@UsrAlias, @DisplayAs='user admin',@BHPUid=@UsrAdminEmail,@BHPPswd=@UsrLoginPswd,
			@Roles=@Roles, @AllowMulti=1, @AllowLogin=1, @RowID=@NuCustID Output;

	-- set verified 'on'
	Update di.CustMstr
		Set Verified=1
	Where RowID = @NuCustID;

	-- Cleare out deployment preferences and initialize with all 'Item' class prefs...
	Truncate Table di.DeploymentPublications;
	Truncate Table di.DeploymentSubscriptions;

	Insert Into [di].[DeploymentPublications] ([Fk_PrefMstrID])
	SELECT [RowID]
	FROM [di].[DeploymentPrefsMstr] 
	Where [Name] not like '%sched' and [Name] <> 'customerRecipe' and Manditory=0;

	Insert Into [di].[DeploymentSubscriptions] ([Fk_PrefMstrID])
	SELECT [RowID]
	FROM [di].[DeploymentPrefsMstr] 
	Where [Name] not like '%sched' and [Name] not like '%Recipe';

	-- Finally clear out the Session Master table...
	Truncate Table di.SessionMstr;

	set identity_insert [di].SessionMstr on;
	insert into [di].SessionMstr(RowID, SessID, CreatedOn, ClosedOn, fk_CustID, [Lang], fk_DeployInfo)
	values (0,'00000000-0000-0000-0000-000000000000',GetDate(),0,0,N'en_us', 0);
	set identity_insert [di].SessionMstr off;

	-- Clear out publication and subscription event log(s)...
	Truncate Table bwp.BWP_Cli_Log;
	Truncate Table [bhp].[SubscriptionEvntPostings];

	
	return @rc;
End
go

Print 'Proc:: tools.SetupDeployment created!!!';
go

revoke execute on tools.SetupDeployment to [BHPApp];
go

checkpoint
