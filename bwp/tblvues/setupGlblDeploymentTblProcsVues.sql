use [BHP1-RO]
go

if object_id(N'bwp.vw_IgnorePublications',N'V') is not null
Begin
	Print 'Vue:: bwp.vw_IgnorePublications dropped!!!';
	Drop View bwp.vw_IgnorePublications;
End
go

if object_id(N'bwp.vw_GlblDeploymentsInfo',N'V') is not null
Begin
	Print 'View:: bwp.vw_GlblDeploymentsInfo dropped!!!';
	Drop View bwp.vw_GlblDeploymentsInfo;
End
go

if object_id(N'bwp.IgnorePublications',N'U') is not null
Begin
	Print 'Table:: bwp.IgnorePublications dropped!!!';
	Drop Table bwp.IgnorePublications;
End
go

if object_id(N'bwp.GlblDeploymentsInfo',N'U') is not null
Begin
	Print 'Table:: bwp.GlblDeploymentsInfo dropped!!!';
	Drop Table bwp.GlblDeploymentsInfo;
End
go



/*
** holds a list of all known deployments. This is useful to fitering out
** subscribed events by deployment. E.G.: I'd like to not be bothered processing
** recv'd events from deployment 'foo'... this will 
*/
Create Table bwp.GlblDeploymentsInfo (
	RowID int identity(1,1) not null,
	DeploymentGUID uniqueidentifier not null,
	[Name] varchar(200),
	[IgnoreAll] bit not null Constraint DF_bwpGlblDeploymentsInfo_IgnoreAll Default(0),
	SyncTimestamp datetime null Constraint DF_bwpGlblDeploymentsSyncTS default(Getdate()),
Constraint PK_bwpGlblDeploymentsInfo_RowID Primary Key NonClustered(RowID)
);
go

Create Unique Clustered Index IDX_bwpGlblDeployInfo_GUID on bwp.GlblDeploymentsInfo (
	[Name],
	DeploymentGUID
);
go


Set Identity_Insert bwp.GlblDeploymentsInfo On;
Insert into bwp.GlblDeploymentsInfo(RowID,DeploymentGUID,[Name],IgnoreAll,SyncTimestamp)
Values(-1,'11111111-1111-1111-1111-111111111111','Unknown',1,0)
Set Identity_Insert bwp.GlblDeploymentsInfo Off;
go

Create Trigger bwp.GlblDeploymentsInfo_Del_99 on bwp.GlblDeploymentsInfo
With Encryption
For Delete
As
Begin
	If Exists (Select * from deleted where RowID = 0)
	Begin
		Raiserror(N'row zero CANNOT be removed!!! Request aborted...',16,1);
		Rollback Transaction;
	End
End
go

Create Table bwp.IgnorePublications (
	RowId int identity(1,1),
	Fk_GlblDeployID int not null,
	Fk_MstrPrefID smallint not null,
	IgnoreEntry bit not null
		Constraint DF_bwpIgnorePubs_IgnoreEntry Default(0),
	IgnoreEntryForAwhile bit not null
		Constraint DF_bwpIgnorePubs_TimeBaseIgnore Default(0),
	IgnoreFrom datetime not null Constraint DF_bwpIgnorePubs_IgnoreFrom default(0),
	IgnoreTill datetime null Constraint DF_bwpIgnorePubs_IgnoreTill default(0),
Constraint PK_bwpIgnorePubs_RowID Primary Key NonClustered(RowID),
Constraint FK_bwpIgnorePubs_Fk_GlblDeployID Foreign Key (Fk_GlblDeployID)
	References bwp.GlblDeploymentsInfo (RowID) On Delete Cascade,
Constraint FK_bwpIgnorePubs_Fk_PrefID Foreign Key (Fk_MstrPrefID)
	References di.DeploymentPrefsMstr (RowID) On Delete Cascade
);
go

Create View bwp.vw_IgnorePublications (
	RowID, GlblDeployRowID, DeploymentGUID, DeploymentName, IgnoreAll,
	PreferenceRowID, PreferenceName, Domain, 
	IgnoreEntry, IgnoreEntryForAwhile, IgnoreFrom, IgnoreTill
)
with encryption
as
	Select 
		[I].RowID,
		[I].Fk_GlblDeployID,
		G.DeploymentGUID,
		G.Name,
		G.IgnoreAll,
		P.RowID,
		P.Name,
		P.Domain,
		ISNULL(I.IgnoreEntry,0),
		ISNULL(I.IgnoreEntryForAwhile,0),
		ISNULL(I.IgnoreFrom,0),
		ISNULL(I.IgnoreTill,0)
	From bwp.IgnorePublications As [I]
	Inner Join bwp.GlblDeploymentsInfo As G On ([I].Fk_GlblDeployID = G.RowID)
	Inner Join di.vw_DeploymentPrefsMstr As P On ([I].Fk_MstrPrefID = P.RowID And P.Manditory = 0);
go

Create View bwp.vw_GlblDeploymentsInfo
with encryption
as
	Select
		RowID, DeploymentGUID, [Name], IgnoreAll, SyncTimestamp
	From bwp.GlblDeploymentsInfo;
go

grant select on di.DeploymentPrefsMstr to [bwp-cli];
print 'permissions applied...';
go