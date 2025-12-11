use [BHP1-RO]
go

if object_id(N'[di].vw_CustTargetInfo',N'V') is not null
begin
	drop view [di].vw_CustTargetInfo;
	Print 'view:: [di].vw_CustTargetInfo dropped!!!';
end
go

if object_id(N'[di].CustTargetInfo',N'U') is not null
begin
	drop table [di].CustTargetInfo;
	Print 'table:: [di].CustTargetInfo dropped!!!';
end
go

Create Table [di].CustTargetInfo (
	RowID int identity(1,1),
	Fk_CustID bigint not null,
	Fk_DeployInfo int not null,
	TargetType varchar(8) not null,
	[Target] varchar(200) not null,
	IsPreferred bit null,
	IsVerified bit null,
Constraint PK_CustTargetInfo_RowID Primary Key NonClustered(RowID),
Constraint FK_CustTargetInfo_DeployCust Foreign Key (Fk_CustID)
	References [di].CustMstr(RowID)
	On Delete Cascade
);
go

alter table [di].CustTargetInfo add
constraint CHK_CustTargetINfo_TargetType Check(TargetType in ('email','sms','login')),
constraint DF_CustTargetInfo_TargetType Default('email') For [TargetType],
constraint DF_CustTargetInfo_IsPreferred Default(0) for IsPreferred,
Constraint DF_CustTargetInfo_IsVerified Default(0) for IsVerified;
go

Create Trigger [di].Trig_CustTargetInfo_Trig_INS on [di].CustTargetInfo
with encryption
AFter Insert
as
begin
	If ((Select SUM(convert(int,C.IsPreferred))
		From [di].CustTargetInfo C 
		Inner Join Inserted I On (C.RowID = I.RowID)) > 1
	)
	Begin
		Raiserror(N'Customer Target can ONLY HAVE ONE Preferred ''Target''!!!',16,1);
		Rollback Transaction;
	End

end
go

Create Unique Clustered Index IDX_CustTargetInfo_CustTargets on [di].CustTargetInfo (
	fk_CustID,
	fk_DeployInfo,
	TargetType,
	[Target]
);
go

set identity_Insert [di].CustTargetInfo On;
insert into [di].CustTargetInfo (RowID, Fk_CustID, Fk_DeployInfo, TargetType, Target, IsPreferred)
values (0,0,0,'email','noemail@somesite.com',0);
set identity_Insert [di].CustTargetInfo Off;
go

Create View [di].vw_CustTargetInfo (
	CustID, Name, BHPUid, DeploymentID, DeploymentName, DeploymentGUID, TargetType, [Target], IsPreferred, IsDerived, IsVerified
)
--with schemabinding, encryption
as
	Select 
		C.RowID, C.Name, C.BHPUid,
		D.RowID, D.Name, D.DeploymentID,
		ISNULL(T.TargetType,'email'),
		Case ISNULL(T.TargetType,'email')
		When 'login' THen C.BHPUid
		WHen 'email' THen ISNULL(T.[Target], C.BHPUid)
		When 'sms' THen T.[Target]
		End As [Target],
		ISNULL(T.IsPreferred,0) As IsPreferred,
		Case When T.RowID IS NULL Then cast(1 as bit) Else cast(0 as bit) End As IsDerived,
		ISNull(T.IsVerified,C.Verified) As IsVerified
	From [di].CustMstr C
	Inner Join [di].Deployments D On (C.Fk_DeployInfo = D.RowID)
	Left Join [di].CustTargetInfo T On (T.Fk_CustID = C.RowID And T.Fk_DeployInfo = C.fk_DeployInfo)
	WHere C.AllowNotices = 1 And C.Verified = 1 And C.RowID > 0;

go

