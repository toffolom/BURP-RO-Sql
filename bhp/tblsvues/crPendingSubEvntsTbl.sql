use [BHP1-RO]
go

if object_id(N'bhp.vw_SubscriptionEvntPostings',N'V') is not null
begin
	print 'vue:: [bhp].[vw_SubscriptionEvntPostings] dropped!!!';
	drop view [bhp].[vw_SubscriptionEvntPostings];
end
go

if object_id(N'bhp.vw_SubEvntPostingStatsByDeploy',N'V') is not null
begin
	print 'vue:: [bhp].[vw_SubEvntPostingStatsByDeploy] dropped!!!';
	drop view [bhp].vw_SubEvntPostingStatsByDeploy;
end
go

if object_id(N'bhp.vw_SubEvntPostingStatusStats',N'V') is not null
begin
	print 'vue:: [bhp].[vw_SubEvntPostingStatusStats] dropped!!!';
	drop view [bhp].vw_SubEvntPostingStatusStats;
end
go

if object_id(N'bhp.SubscriptionEvntPostings',N'U') is not null
begin
	print 'table:: [bhp].[SubscriptionEvntPostings] dropped!!!';
	drop table [bhp].[SubscriptionEvntPostings];
end
go



Create Table [bhp].[SubscriptionEvntPostings] (
	[RowID] bigint not null identity(1,1),
	[Doc] nvarchar(4000) not null,
	[Fk_PrefsMstrID] smallint not null,
	[PrefName] as (di.fn_GetPrefName([Fk_PrefsMstrID])), -- subscription event type
	[Action] varchar(30) not null, -- one of 'add','chg'. never recv 'del' actions!!!
	[Status] varchar(50) not null,
	[RecvdOn] datetime null,
	[PickedOn] datetime null,
	[CommitedOn] datetime null,
	[Comment] nvarchar(1000) null,
	[DeploymentSource] varchar(200) not null,
	[DeploymentGUID] varchar(256) not null 
		constraint DF_SubscriptionEvntPostings_DeployGUID default('11111111-1111-1111-1111-111111111111'),
	[ProcessAttemptCount] int null,
	Fk_GlblDeployRowID int not null
		Constraint DF_bhpSubscriptionEvntPostings_Fk_GlblDeployRowID default(-1),
	Constraint FK_bhpSubscriptionEvntPostings_Fk_GlblDeployRowID Foreign Key (Fk_GlblDeployRowID)
		REferences bwp.GlblDeploymentsInfo (RowID)
		On Delete Cascade,
	Constraint PK_bhp_SubscriptionEvntPostings_RowID Primary Key NonClustered(RowID),
	Constraint FK_bhp_SubscriptionEvntPostings_PrefsMstrID Foreign Key (Fk_PrefsMstrID)
		References di.DeploymentPrefsMstr (RowID)
);
go

alter table [bhp].[SubscriptionEvntPostings] add
constraint DF_SubscriptionEvntPostings_RecvOn default(getdate()) for [RecvdOn],
constraint DF_SubscriptionEvntPostings_PickedOn default(0) for [PickedOn],
constraint DF_SubscriptionEvntPostings_CommitedOn default(0) for [CommitedOn],
constraint CHK_SubscriptionEvntPostings_Status check([Status] in ('pending','in process','processed','failed','undef','rejected','accepted','ignored')),
constraint DF_SubscriptionEvntPostings_Comment default(N'no comment given...') for [Comment],
constraint DF_SubscriptionEvntPostings_ProcessingCount default(0) for [ProcessAttemptCount],
constraint DF_SubscriptionEvntPostings_Status default('Pending') for [Status],
--constraint CHK_SubscriptionEvntPosting_PrefName check([di].[fn_ChkPrefMstrByName](PrefName) = 1),
Constraint DF_SubscriptionEvntPostings_Fk_PrefsMstrID default(0) for [Fk_PrefsMstrID];
go

create index IDX_SubscriptionEvntPostings_RecvdOn on [bhp].[SubscriptionEvntPostings] ( RecvdOn );
go

Create view bhp.vw_SubscriptionEvntPostings (
	[RowID]
	,[Doc]
	,[Fk_PrefMstrID]
	,[PrefName]
	,[Action]
	,[Status]
	,[RecvdOn]
	,[PickedOn]
	,[CommitedOn]
	,[Comment]
	,[Fk_GlblDeployRowID]
	,[DeploymentSource]
	,[DeploymentGUID]
	,[ProcessAttemptCount]
)
with encryption
as
	--select XX.* from (
		select top 100 percent
			[RowID]
			,[Doc]
			,[Fk_PrefsMstrID]
			,[PrefName]
			,[Action]
			,[Status]
			,[RecvdOn]
			,[PickedOn]
			,[CommitedOn]
			,[Comment]
			,[Fk_GlblDeployRowID]
			,[DeploymentSource]
			,[DeploymentGUID]
			,[ProcessAttemptCount]
		from [bhp].[SubscriptionEvntPostings]
		order by RecvdOn
	--) As XX;

go

Create View bhp.vw_SubEvntPostingStatusStats
as
	Select Top 100 Percent
		[Status], 
		Count(*) As TotalEvnts
	From bhp.SubscriptionEvntPostings
	Group By [Status]
	Order By [Status];
go

Create View bhp.vw_SubEvntPostingStatsByDeploy
as
	Select Top 100 Percent
		[Fk_GlblDeployRowID],
		[DeploymentSource],
		[Status], 
		Count(*) As TotalEvnts
	From bhp.SubscriptionEvntPostings
	Group By [fk_GlblDeployRowID],[DeploymentSource], [Status]
	Order By [fk_GlblDeployRowID];
go

checkpoint
go