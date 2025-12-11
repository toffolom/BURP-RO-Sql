use [BHP1-RO]
go

if object_id(N'bhp.GetGlblDeploymentRecs',N'P') is not null
Begin
	Drop Proc bhp.GetGlblDeploymentRecs;
	Print 'Proc:: bhp.GetGlblDeploymentRecs dropped!!!';
End
go

if object_id(N'bhp.SetGlblDeploymentIgnoreMode',N'P') is not null
Begin
	Drop Proc bhp.SetGlblDeploymentIgnoreMode;
	Print 'Proc:: bhp.SetGlblDeploymentIgnoreMode dropped!!!';
End
go



Create Proc bhp.GetGlblDeploymentRecs (
	@SessID varchar(256), -- must be admin session!!!
	@IncLocal bit = 0
)
With Encryption, execute as 'sticky'
As
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @SessRowID bigint;

	If (1=0)
	Begin
		Select
			Cast(Null As Int) As RowID,
			Cast(Null As Varchar(256)) As DeploymentGUID,
			Cast(Null As varchar(200)) As [Name],
			Cast(Null As Bit) As IgnoreAll,
			Cast(Null As Datetime) As SyncTimestamp,
			Cast(Null As Bit) As IsLocal;
		Return 0;
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

	--Select @SessRowID=[RowID] From di.vw_SessionInfo Where SessionID=@SessID;

	--If (@SessRowID != 0 OR @SessID != '00000000-0000-0000-0000-000000000000')
	--Begin
	--	Raiserror(N'Session does NOT have permission to perform action. Request Aborted!!!',16,1);
	--	Return -1;
	--End

	If (ISNULL(@IncLocal,0) = 0)
	Begin
		Select
			RowID,
			Convert(varchar(256), DeploymentGUID) As DeploymentGUID, 
			[Name], 
			ISNULL(IgnoreAll, 0) As IgnoreAll,
			SyncTimestamp,
			Cast(0 As Bit) As IsLocal
		From bwp.GlblDeploymentsInfo Where RowID > 0
		Order By [Name];
	End
	Else
	Begin
		Select * from 
		(
			Select
				RowID,
				Convert(varchar(256), DeploymentGUID) As DeploymentGUID, 
				[Name], 
				ISNULL(IgnoreAll, 0) As IgnoreAll,
				SyncTimestamp,
				Cast(0 As Bit) As IsLocal
			From bwp.GlblDeploymentsInfo Where RowID > 0
			Union
			Select
				RowID,
				Convert(varchar(256), DeploymentID) As DeploymentGUID, 
				[Name], 
				Cast(0 As Bit) As IgnoreAll,
				DeployedOn As SyncTimestamp,
				Cast(1 As Bit) As IsLocal
			From di.Deployments Where RowID = 0
		) As XX
		Order By XX.Name;
	End

	Return ISNULL(@rc, @@ERROR);
End
Go
Print 'Proc:: bhp.GetGlblDeploymentRecs created...';
go

Create Proc bhp.SetGlblDeploymentIgnoreMode (
	@SessID varchar(256),
	@RowID int,
	@IgnoreAll bit, -- set to (1) to ignore all publications from deployment!!!
	@RmIgnoreRecs bit = 0, -- set if you want to remove all the assoc ignore recs
	@Updt8SubPostings bit = 0 -- if you want to update any existing subscriptions (SubscriptionEvntPostings tbl) entries!?
)
With Encryption, execute as 'sticky'
As
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @Old Table([ID] int, OldIgnoreMode bit, DeployGUID uniqueidentifier);
	Declare @SessRowID bigint;
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	--Select @SessRowID=[RowID] From di.vw_SessionInfo Where SessionID=@SessID;

	--If (@SessRowID != 0 OR @SessID != '00000000-0000-0000-0000-000000000000')
	--Begin
	--	Raiserror(N'Session does NOT have permission to perform action. Request Aborted!!!',16,1);
	--	Return -1;
	--End

	Update Top (1) bwp.GlblDeploymentsInfo
		Set IgnoreAll = ISNULL(@IgnoreAll,0)
	Output deleted.RowID, deleted.IgnoreAll, deleted.DeploymentGUID Into @Old([ID],OldIgnoreMode,DeployGUID)
	Where RowID = @RowID;

	-- if switching ignore all mode 'off'...and remove all ignore recs is 'on'...wipe Ignore Publication rec(s)
	If (@IgnoreAll = 0 And @RmIgnoreRecs=1 And Exists (Select 1 From @Old Where OldIgnoreMode=1))
	Begin
		Delete bwp.IgnorePublications
		From bwp.IgnorePublications As I
		Inner Join @Old As O On (I.Fk_GlblDeployID = O.ID);
	End

	If (@Updt8SubPostings = 1)
	Begin
		Update bhp.SubscriptionEvntPostings
			Set Status = Case ISNULL(@IgnoreAll,0) When 1 Then 'Ignored' Else 'Pending' End
		From bhp.SubscriptionEvntPostings S
		Inner Join @Old O On (S.DeploymentGUID = O.DeployGUID);
	End

	Return @@ERROR;
End
go
Print 'Proc:: bhp.SetGlblDeploymentIgnoreMode created...';
go

checkpoint
go