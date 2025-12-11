use [BHP1-RO]
go

if object_id(N'bwp.PostSubscriptionEvnt',N'P') is not null
begin
	print 'proc:: [bwp].[PostSubscriptionEvnt] dropped!!!';
	drop proc [bwp].[PostSubscriptionEvnt];
end
go

/*
** this proc is intended to be invoked by the burp router. the purpose is to
** write into this instance an event they have indicated they are interested in recv'n.
** that is, they may want to recv (as an example), new yeast settings whenever they are added
** by someone on the platform.  the event posted is a small xml fragment, time it was posted,
** a status and from whom it came from.
*/
Create Proc [bwp].[PostSubscriptionEvnt] (
	@SessID varchar(256),
	@Doc nvarchar(4000), -- xml fragment from the original event...just the <Payload> portion.
	@Type varchar(200), -- subscription event type (nameof).
	@Action varchar(30), -- one of 'add' or 'chg'.
	@DName varchar(200), -- deployment name event originated at...just for helpful referencing.
	@DeployGUID varchar(256), -- deployment unique guid value
	@Comment nvarchar(1000) = N'no comment given...',
	@NuRowID bigint output
)
with encryption
as
begin
	Declare @rc int;
	Declare @Mesg nvarchar(2000);
	Declare @SessStatus bit;
	Declare @NuPost Table ([ID] bigint);
	Declare @GlblID int; -- deployment global rowid value...
	Declare @Status varchar(50) = 'Pending';
	Declare @ignore bit = 0;
	Declare @autoAdd varchar(20);
	Declare @SessRowID bigint;
	Declare @ignoreAllMode varchar(20);
	Declare @PrefID smallint;



	exec @rc = [di].IsSessStale @SessID=@SessID, @Status=@SessStatus output, @Mesgs=@Mesg output, @UpdLst=1;

	if (@rc != 0 or @SessStatus != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].getI18NMsg @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @SessRowID=[RowID] From di.SessionMstr Where RowID=@SessID;

	If (@SessRowID != 0 OR @SessID != '00000000-0000-0000-0000-000000000000')
	Begin
		Raiserror(N'Session does NOT have permission to perform action. Request Aborted!!!',16,1);
		Return -1;
	End
	
	/*
	** get our enviro setting that'll tell us if we can automatically add a rec to the
	** Global Deployment Table (bwp.GlblDeploymentsInfo) so we can mark, future, recs
	** with status 'ignore'.
	*/
	Exec di.getEnv @VarNm='Auto add global deployment info',@VarVal=@autoAdd output, @DfltVal='yes';
	Exec di.getEnv @VarNm='Mark new Global Deployment recs ignore all mode', @VarVal=@IgnoreAllMode output, @DfltVal='No';

	Set @rc = 0;
	Set @ignore = di.fn_ISTRUE(@ignoreAllMode);

	-- check if source deployment has been registered...
	-- check if we registered to ignore ALL events from deployment
	-- check if we allow deployment subs, but are ignoring a particular event
	-- finaly check if the action is change, but we're not allowing change event processing.
	If Exists (Select 1 From bwp.vw_GlblDeploymentsInfo Where DeploymentGUID = @DeployGUID)
	Begin
		-- see if configured to 'ignore' anything from said deployment!?
		Select 
			@GlblID = G.[RowID], 
			@Status = Case G.IgnoreAll When 1 Then 'Ignored' Else @Status End
		From bwp.GlblDeploymentsInfo As G
		Where G.DeploymentGUID=@DeployGUID;

		-- see if configured to 'ignore' this event from said deployment!?
		If (@Status='Pending' 
			And 
			Exists (Select 1 
				From bwp.IgnorePublications As I
				Inner Join di.DeploymentPrefsMstr As P On (I.Fk_MstrPrefID = P.RowID)
				Where I.Fk_GlblDeployID=@GlblID And P.Name=@Type And I.IgnoreEntry=1
			))
		Begin
			Set @Status = 'Ignored';
		End

		-- see if configured to 'ignore' this event for 'awhile'
		If (@Status='Pending' 
			And 
			Exists (Select 1 
				From bwp.IgnorePublications As I
				Inner Join di.DeploymentPrefsMstr As P On (I.Fk_MstrPrefID = P.RowID)
				Where I.Fk_GlblDeployID=@GlblID And P.Name=@Type And I.IgnoreEntryForAwhile=1
				And GetDate() Between I.IgnoreFrom And I.IgnoreTill
			))
		Begin
			Set @Status = 'Ignored';
		End

		-- if still 'pending' but action is 'chg' and we don't allow change events...check that here...
		If (@Action='chg' And @Status='Pending' 
			And 
			Exists (Select 1 From di.DeploymentSubscriptions Where [PrefName]=@Type And ISNULL(AllowChgOp,0)=0))
		Begin
			Set @Status = 'Ignored';
		End
	End
	Else -- attempt to add deployment...
	Begin
		If (di.fn_ISTRUE(@autoAdd) = 1)
		Begin
			-- run mthd to add new global deployment record...must run with admin session!!!
			Exec bwp.AddGlblDeploymentRec 
				@SessID=@SessID, 
				@DeployGUID=@DeployGUID, 
				@Name=@DName, 
				@IgnoreAll=@ignore, 
				@Force=0,
				@RowID = @GlblID Output;
		End
		Else
			Set @GlblID = -1; -- refer to unknown deployment so insertion will work.
	End

	Select @PrefID = RowID from di.DeploymentPrefsMstr where [Name]=@Type;
	Set @PrefID = ISNULL(@PrefID,0);

	-- if not in our subscription list mark as 'ignored'.
	-- gui allows for viewing of 'ignored' item(s)...if so desired.
	If Not Exists (Select * from di.DeploymentSubscriptions Where Fk_PrefMstrID=@PrefID)
	Begin
		Set @Action='Ignored';
	End

	-- stuff into log. NOTE: even thou 'ignored' it'll still go into log
	-- so in the future you can browse 'ignored' events and perhaps if you decide
	-- to reverse your choice to 'ignore' all those ignored will automatically be set
	-- to 'pending'.
	Insert Into [bhp].[SubscriptionEvntPostings] (
		Doc, 
		[Fk_PrefsMstrID], 
		[Action], 
		[Status], 
		DeploymentSource, 
		DeploymentGUID,
		Comment,
		Fk_GlblDeployRowID
	)
	Output inserted.RowID Into @NuPost([ID])
	Select
		@Doc,
		@PrefID, 
		@Action,
		@Status, 
		@DName,
		@DeployGUID,
		ISNULL(@Comment, N'no comment given...'),
		@GlblID;

	Set @rc = @@ERROR;

	if (@Rc = 0)
		Select @NuRowID = [ID] from @NuPost;
	else
		Set @NuRowID = -1;

	return @RC;
end
go

