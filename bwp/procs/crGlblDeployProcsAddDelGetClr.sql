use [BHP1-RO]
go

if object_id(N'bwp.AddGlblDeploymentRec',N'P') is not null
Begin
	Drop Proc bwp.AddGlblDeploymentRec;
	Print 'Proc:: bwp.AddGlblDeploymentRec dropped!!!';
End
go

if object_id(N'bwp.DelGlblDeploymentRec',N'P') is not null
Begin
	Drop Proc bwp.DelGlblDeploymentRec;
	Print 'Proc:: bwp.DelGlblDeploymentRec dropped!!!';
End
go

if object_id(N'bwp.GetGlblDeploymentRecs',N'P') is not null
Begin
	Drop Proc bwp.GetGlblDeploymentRecs;
	Print 'Proc:: bwp.GetGlblDeploymentRecs dropped!!!';
End
go

if object_id(N'bwp.ClrGlblDeploymentRecs',N'P') is not null
Begin
	Drop Proc bwp.ClrGlblDeploymentRecs;
	Print 'Proc:: bwp.ClrGlblDeploymentRecs dropped!!!';
End
go

if object_id(N'bwp.SetGlblDeploymentIgnoreMode',N'P') is not null
Begin
	Drop Proc bwp.SetGlblDeploymentIgnoreMode;
	Print 'Proc:: bwp.SetGlblDeploymentIgnoreMode dropped!!!';
End
go

if object_id(N'bwp.AddSubscriptionIgnoreRec',N'P') is not null
Begin
	Drop Proc bwp.AddSubscriptionIgnoreRec;
	Print 'Proc:: bwp.AddSubscriptionIgnoreRec dropped!!!';
End
go

if object_id(N'bwp.ChgSubscriptionIgnoreRec',N'P') is not null
Begin
	Drop Proc bwp.ChgSubscriptionIgnoreRec;
	Print 'Proc:: bwp.ChgSubscriptionIgnoreRec dropped!!!';
End
go

if object_id(N'bwp.DelSubscriptionIgnoreRec',N'P') is not null
Begin
	Drop Proc bwp.DelSubscriptionIgnoreRec;
	Print 'Proc:: bwp.DelSubscriptionIgnoreRec dropped!!!';
End
go

if object_id(N'bwp.GetSubscriptionIgnoreRecs',N'P') is not null
Begin
	Drop Proc bwp.GetSubscriptionIgnoreRecs;
	Print 'Proc:: bwp.GetSubscriptionIgnoreRecs dropped!!!';
End
go

Create Proc bwp.AddGlblDeploymentRec (
	@SessID varchar(256),
	@DeployGUID varchar(256),
	@Name varchar(200),
	@IgnoreAll bit,
	@Force bit = 0, -- set to (1) if you wish to perform a delete 1st if exists!!!
	@RowID int output
)
With Encryption
As
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @SessRowID bigint;
	Declare @Nu Table ([ID] int);
	
	Exec @rc = [di].[IsSessStale] @SessID=@SessID, @Status=@Status output, @Mesgs=@Mesg output, @UpdLst=1;

	If (@rc != 0 or @status != 0)
	Begin
		-- should write and audit record here...someone trying to read data w/o logging in!?
		Set @rc = 66006; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1);
		Return @rc;
	End

	Select @SessRowID=[RowID] From di.vw_SessionInfo Where SessionID=@SessID;

	If (@SessRowID != 0 OR @SessID != '00000000-0000-0000-0000-000000000000')
	Begin
		Raiserror(N'Session does NOT have permission to perform action. Request Aborted!!!',16,1);
		Return -1;
	End

	Set @Force = ISNULL(@Force,0);
	Set @IgnoreAll = ISNULL(@IgnoreAll,0);

	If Exists (Select 1 from bwp.GlblDeploymentsInfo Where DeploymentGUID=@DeployGUID And @Force = 0)
	Begin
		Set @rc = -1;
		Raiserror(N'Global Deployment:[''%s''] exists! Specify @force to remove. Request Aborted!!!',16,1,@Name);
		Return @rc;
	End

	If (@Force = 1 And Exists (Select 1 from bwp.GlblDeploymentsInfo Where DeploymentGUID=@DeployGUID))
	Begin
		-- this has a cascade delete action so the bwp.IgnorePublications table is cleared out too!!!
		Delete bwp.GlblDeploymentsInfo Where DeploymentGUID=@DeployGUID;
	End

	Insert into bwp.GlblDeploymentsInfo(DeploymentGUID,Name,IgnoreAll,SyncTimestamp)
	Output Inserted.RowID Into @Nu
	Values (@DeployGUID, @Name, @IgnoreAll,GETDATE());

	Select @RowID = [ID] From @Nu;

	/*
	** Preload ignore rec(s)...everything is allowed!!!
	*/
	Insert Into bwp.IgnorePublications(Fk_GlblDeployID,Fk_MstrPrefID,IgnoreEntry,IgnoreEntryForAwhile,IgnoreFrom,IgnoreTill)
	Select
		NU.ID,P.RowID,0,0,0,0
	From di.vw_DeploymentPrefsMstr P
	Cross Apply ( 
		Select [ID] From @Nu 
	) As NU
	Where (P.Domain = 'element' And P.RowID > 0);

	Return @@ERROR;
End
go
Print 'Proc:: bwp.AddGlblDeploymentRec created...';
go

Create Proc bwp.DelGlblDeploymentRec (
	@SessID varchar(256),
	@RowID int
)
With Encryption
as
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @NuRow Table ([ID] int);
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

	Select @SessRowID=[RowID] From di.vw_SessionInfo Where SessionID=@SessID;

	If (@SessRowID != 0 OR @SessID != '00000000-0000-0000-0000-000000000000')
	Begin
		Raiserror(N'Session does NOT have permission to perform action. Request Aborted!!!',16,1);
		Return -1;
	End

	-- the referential key will cascade down to the bwp.IgnorePublications table!!!
	Delete bwp.GlblDeploymentsInfo Where RowID=@RowID;

	Return @@ERROR;
End
go
Print 'Proc:: bwp.DelGlblDeploymentRec created...';
go

Create Proc bwp.ClrGlblDeploymentRecs (
	@SessID varchar(256) -- must be admin session!!!
)
With Encryption
As
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @NuRow Table ([ID] int);
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

	Select @SessRowID=[RowID] From di.vw_SessionInfo Where SessionID=@SessID;

	If (@SessRowID != 0 OR @SessID != '00000000-0000-0000-0000-000000000000')
	Begin
		Raiserror(N'Session does NOT have permission to perform action. Request Aborted!!!',16,1);
		Return -1;
	End

	-- the ref integrity will cascade into bwp.IgnorePublication table too!!!
	Delete bwp.GlblDeploymentsInfo;
	Set @rc = @@ROWCOUNT;
	Raiserror(N'[%d] Global Deployment rec(s) removed!!!',0,1,@rc);

	Return @@ERROR;
End
Go
print 'Proc:: bwp.ClrGlblDeploymentRecs created!!!';
go

Create Proc bwp.GetGlblDeploymentRecs (
	@SessID varchar(256), -- must be admin session!!!
	@IncLocal bit = 0
)
With Encryption
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
Print 'Proc:: bwp.GetGlblDeploymentRecs created...';
go

Create Proc bwp.SetGlblDeploymentIgnoreMode (
	@SessID varchar(256),
	@RowID int,
	@IgnoreAll bit, -- set to (1) to ignore all publications from deployment!!!
	@RmIgnoreRecs bit = 0, -- set if you want to remove all the assoc ignore recs
	@Updt8SubPostings bit = 0 -- if you want to update any existing subscriptions (SubscriptionEvntPostings tbl) entries!?
)
With Encryption
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
			Set Status = Case @IgnoreAll When 1 Then 'Ignored' Else 'Pending' End
		From bhp.SubscriptionEvntPostings S
		Inner Join @Old O On (S.DeploymentGUID = O.DeployGUID);
	End

	Return @@ERROR;
End
go
Print 'Proc:: bwp.SetGlblDeploymentIgnoreMode created...';
go

Create Proc bwp.AddSubscriptionIgnoreRec (
	@SessID varchar(256),
	@Fk_GlblRowID int,
	@Fk_PrefMstrID int,
	@IgnoreEntry bit,
	@IgnoreEntryForAwhile bit,
	@IgnoreFrom datetime = 0, -- will dflt to current datetime
	@IgnoreTill datetime = 0, -- will dflt to current datetime + 50 yrs.
	@NuRowID int output
)
With Encryption
As
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
	Declare @NuRow Table ([ID] int);
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

	Insert Into bwp.IgnorePublications(Fk_GlblDeployID, Fk_MstrPrefID, IgnoreEntry, IgnoreEntryForAwhile, IgnoreFrom, IgnoreTill)
	Output Inserted.RowId into @NuRow([ID])
	Select 
		@Fk_GlblRowID, 
		@Fk_PrefMstrID,
		ISNULL(@IgnoreEntry,0),
		ISNULL(@IgnoreEntryForAwhile,0),
		ISNULL(@IgnoreFrom,0), 
		ISNULL(@IgnoreTill,0);

	Select @NuRowID = [ID] From @NuRow;
	Set @NuRowID = ISNULL(@NuRowID, -1); -- incase of error.

	Return @@ERROR;
End
go
Print 'Proc:: bwp.AddSubscriptionIgnoreRec created...';
go

Create Proc bwp.DelSubscriptionIgnoreRec (
	@SessID varchar(256),
	@RowID int
)
With Encryption
As
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
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

	Delete bwp.IgnorePublications Where RowId = @RowID;

	Return @@ERROR;
End
go
Print 'Proc:: bwp.DelSubscriptionIgnoreRec created...';
go

Create Proc bwp.ChgSubscriptionIgnoreRec (
	@SessID varchar(256),
	@RowID int,
	@Fk_PrefMstrID int,
	@IgnoreEntry bit,
	@IgnoreForAwhile bit,
	@IgnoreFrom datetime = 0,
	@IgnoreTill datetime = 0 
)
With Encryption
As
Begin
	Declare @rc int;
	Declare @mesg nvarchar(2000);
	Declare @status bit;
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

	Update bwp.IgnorePublications
		Set 
		Fk_MstrPrefID=@Fk_PrefMstrID,
		IgnoreEntry=ISNULL(@IgnoreEntry,0),
		IgnoreEntryForAwhile=ISNULL(@IgnoreForAwhile,0),
		IgnoreFrom=ISNULL(@IgnoreFrom,0), 
		IgnoreTill=ISNULL(@IgnoreTill,0)
	Where RowID=@RowID;

	Return @@ERROR;
End
go
Print 'Proc:: bwp.ChgSubscriptionIgnoreRec created...';
go

Create Proc bwp.GetSubscriptionIgnoreRecs (
	@SessID varchar(256),
	@RowID int
)
With Encryption
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
			Cast(Null As Int) As Fk_GlblRowID,
			Cast(Null As varchar(256)) As DeploymentGUID,
			Cast(Null As smallint) As Fk_MstrPrefID,
			Cast(Null As varchar(200)) As [Name],
			Cast(Null As Bit) As [IgnoreEntry],
			Cast(Null As Bit) As [IgnoreEntryForAwhile],
			Cast(Null As datetime) As IgnoreFrom,
			Cast(Null As datetime) As IgnoreTill;
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

	If Not Exists (Select * from bwp.GlblDeploymentsInfo Where RowID=@RowID)
	Begin
		Set @rc = 66119; -- this nbr represents users is not logged in.
		Exec [di].[getI18NMsg] @Nbr=@rc, @Lang='en_us', @Msg=@Mesg output;
		Raiserror(@Mesg,16,1,@RowID);
		Return @rc;
	End

	/*
	** always attempt to load any missing PrefMstr rec(s) into the ignore table.
	** WHy? because we don't want the ignore rec(s) to become out of sync with the
	** master preference table...in the event we add more 'element' events!!!
	** NOTE: This should return nothing until a new rec is added to the PrefsMstr table.
	*/
	Insert Into bwp.IgnorePublications(Fk_GlblDeployID,Fk_MstrPrefID,IgnoreEntry,IgnoreEntryForAwhile,IgnoreFrom,IgnoreTill)
	Select
		@RowID,P.RowID,0,0,0,0
	From di.vw_DeploymentPrefsMstr As P
	Left Join bwp.IgnorePublications As I On (I.fk_GlblDeployID=@RowID And I.Fk_MstrPrefID = P.RowID)
	Left Join bwp.GlblDeploymentsInfo As G On (I.Fk_GlblDeployID = G.RowID)
	Where (I.Fk_MstrPrefID IS NULL And P.RowID > 0 And P.Domain = 'element');

	Select 
		I.RowID,
		I.Fk_GlblDeployID As Fk_GlblRowID,
		G.DeploymentGUID,
		P.RowID As Fk_MstrPrefID,
		P.Name,
		ISNULL(I.IgnoreEntry,0) As IgnoreEntry,
		ISNULL(I.IgnoreEntryForAwhile,0) As IgnoreEntryForAwhile,
		ISNULL(I.IgnoreFrom,0) As IgnoreFrom,
		ISNULL(I.IgnoreTill,0) As IgnoreTill
	From bwp.IgnorePublications As I 
	Inner Join bwp.GlblDeploymentsInfo G On (I.Fk_GlblDeployID = G.RowID)
	Inner Join di.vw_DeploymentPrefsMstr P On (P.RowID = I.Fk_MstrPrefID)
	Where G.RowID=@RowID And P.Manditory = 0;

	Return @@ERROR;
End
go
Print 'Proc:: bwp.GetSubscriptionIgnoreRecs created...';
go


--Grant Select on di.SessionMstr to [bwp-cli];
Grant Execute on di.fn_ISTRUE to [bwp-cli];
Print 'permissions applied...';
go

Select permission_name, OBJECT_SCHEMA_NAME(major_id, db_id(db_name())), object_name(major_id) 
from sys.database_permissions where grantee_principal_id=DATABASE_PRINCIPAL_ID('bwp-cli')
go

checkpoint
go