USE [HUB]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Table [di].[Languages]    Script Date: 2/18/2020 2:31:44 PM ******/
CREATE TABLE [di].[Languages](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Lang] [nvarchar](20) NOT NULL,
	[Notes] [nvarchar](2000) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Languages_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [di].[Languages] ADD  CONSTRAINT [DF_Languages_Notes]  DEFAULT (N'<Notes><Note nbr=''0''>No comments given...</Note></Notes>') FOR [Notes]
GO

ALTER TABLE [di].[Languages] ADD  CONSTRAINT [DF_Languages_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO

set identity_insert [di].Languages on;
insert into [di].Languages(RowID, Lang, IsActive, Notes) Values (0, 'pls select', 0, N'<Notes><Note nbr=''1''>DO NOT DELETE!!!</Note></Notes>');
set identity_insert [di].Languages off;
go

insert into [di].Languages(Lang,IsActive,Notes) 
Values ('en_us',1,N'<Notes><Note nbr=''1''>this is the default lang for now!!!</Note></Notes>'),
('en_ca',0,N'<Notes><Note nbr=''1''>canadian english</Note></Notes>'),
('en_gb',0,N'<Notes><Note nbr=''1''>great britian english</Note></Notes>'),
('fr_fr',0,N'<Notes><Note nbr=''1''>std french</Note></Notes>'),
('de_de',0,N'<Notes><Note nbr=''1''>std german</Note></Notes>');
go

create trigger Languages_Del_99 on [di].Languages 
with encryption
for delete
as
begin
	if exists (select * from deleted where RowID = 0)
	begin
		Raiserror(N'Row ''zero'' cannot be deleted...aborting!!!',16,1);
		Rollback Transaction;
	end
end
go

/****** Object:  UserDefinedFunction [di].[fn_GetLang]    Script Date: 2/18/2020 4:10:23 PM ******/
Create function [di].[fn_GetLang](@id int)
returns varchar(50)
with encryption, execute as 'sticky'
as
begin
	Declare @rtrnVal varchar(50);
	Select @rtrnVal = [Lang] From [di].Languages With (NoLock) Where (RowID=@id);
	Return Isnull(@rtrnVal,'en_us');
end
GO



CREATE TABLE [di].[RoleMstr](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[BitVal] [int] NOT NULL,
	[Notes] [nvarchar](2000) NOT NULL,
	[RequiresAuthToEnable] [bit] NOT NULL,
 CONSTRAINT [PK_RoleMstr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IDX_RoleMstr_BitVal] ON [di].[RoleMstr]
(
	[BitVal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

set identity_insert [di].RoleMstr on;
insert into di.RoleMstr(RowID, Name, BitVal, Notes, RequiresAuthToEnable)
values (0,'undefined',0,N'<Notes><Note nbr=''1''>this is an undefined role!!!!</Note></Notes>',0);
set identity_insert [di].RoleMstr off;
go

insert into [di].RoleMstr (Name, BitVal, Notes, RequiresAuthToEnable)
values 
('EndUser',1,N'<Note><Notes nbr=''1''>this is a customer/end user of system lowest permission level</Note></Notes>',0),
('Recipe Creator',4,N'<Notes><Note nbr=''1''>set when a user creates billing information for their account</Note></Notes>',1),
('Auctioneer',16,N'<Note><Notes nbr=''1''>this is a auctioneer role</Note></Notes>',1),
('Admin',32,N'<Note><Notes nbr=''1''>this is an administrator role</Note></Notes>',1),
('Brewer',64,N'<Note><Notes nbr=''1''>this is a brewer/operator role</Note></Notes>',1),
('Supplier',256,N'<Note><Notes nbr=''1''>this is a supplier role</Note></Notes>',1),
('Recipe Reviewer',512,N'<Notes><Note nbr=''1''>this person reviews recipes posted into production requesting they be moved into production!!!</Note></Notes>',1);
go

ALTER TABLE [di].[RoleMstr] ADD  CONSTRAINT [DF__RoleMstr_Notes]  DEFAULT ('<Notes/>') FOR [Notes]
GO

CREATE trigger [di].[RoleMstr_Del_99] on [di].[RoleMstr] 
with encryption
for delete
as
begin
	Raiserror('Role(s) cannot be deleted from system...aborting request!!!',16,1);
	Rollback Transaction;
end
GO

create function [di].[fn_ShowRoleBitMaskAsStr] (@mask int)
returns varchar(200)
with encryption, execute as 'sticky'
as
begin
	Declare @i int;
	Declare @str varchar(400);
	Declare @nm varchar(25);
	Set @i = 0;
	While Exists (Select 1 from [di].RoleMstr Where (BitVal > @i))
	Begin
		Select Top (1) @i = BitVal, @nm = [name]
		From [di].RoleMstr 
		Where (BitVal > @i) Order by BitVal;
		
		If ((@mask & @i) = @i)
			set @str = coalesce(@str + ',','') + @nm;
	End
	Return Coalesce(@str,(select [name] from [di].RoleMstr where RowID = 0));
end
GO

CREATE View [di].[vw_Roles]
--with encryption
as
	Select
		[RowID]
		,[Name]
		,[BitVal]
		,[Notes]
		,ISNULL(RequiresAuthToEnable,0) As RequiresAuthToEnable
	FROM [di].[RoleMstr];
GO



/****** Object:  Table [di].[OwnerTypes]    Script Date: 2/18/2020 2:31:44 PM ******/
CREATE TABLE [di].[OwnerTypes](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[BitVal] [tinyint] NULL,
	[Descr] [nvarchar](200) NULL,
	[Notes] [nvarchar](4000) NULL,
 CONSTRAINT [PK_OwnerTypes_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

set identity_Insert [di].OwnerTypes on;
insert into [di].OwnerTypes (RowID, BitVal, [Descr])
values (0, 0, 'not set'),
(1, 1, 'Person'),
(2, 2, 'Business'),
(3, 4, 'Charity'), 
(4,8,'Goverment');
set identity_Insert [di].OwnerTypes off;
go

CREATE TABLE [di].[OwnerInfo](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NULL,
	[Ph] [varchar](50) NULL,
	[EMail] [varchar](200) NULL,
	[Notes] [nvarchar](4000) NULL,
 CONSTRAINT [PK_OwnerInfo_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];
go


alter table [di].OwnerInfo add constraint DF_OwnerInfo_Notes Default(N'<Notes><Note nbr=''1''>pls provide a comment...</Note></Notes>') for [Notes];
go

set Identity_Insert [di].OwnerInfo on;
insert [di].OwnerInfo (RowID, Name, Ph, EMail, [Notes])
values(0,'dummy','(000)000-0000','foo@bar.com',N'<Notes><Note nbr=''1''>DO NOT REMOVE!!!</Note></Notes>');
set Identity_Insert [di].OwnerInfo off;
go

Create trigger [di].Trig_OwnerInfo_Del_99 on [di].OwnerInfo
with encryption
for delete
as
begin
	If Exists (Select * from deleted Where RowID = 0)
	Begin
		Raiserror(N'Row ''zero'' cannot be removed!!!',16,1);
		Rollback Transaction;
	End
end
go

CREATE TABLE [di].[Environment](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[VarNm] [nvarchar](200) NOT NULL,
	[VarVal] [nvarchar](4000) NOT NULL,
	[Notes] [nvarchar](4000) NULL,
 CONSTRAINT [PK_Environment_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE UNIQUE CLUSTERED INDEX [di_IDX_Environment_VarNm] ON [di].[Environment]
(
	[VarNm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [di].[Environment] ADD  CONSTRAINT [di_DF_Environment_Notes]  DEFAULT ('<Notes><Note nbr=''0''/></Notes>') FOR [Notes];
GO


set identity_insert [di].Environment on;
insert [di].Environment(RowID, VarNm, VarVal, Notes)
values (0,'dummy','dummy','<Notes><Note nbr=''1''>here for referiential integrity purposes...</Note></Notes>');
set identity_insert [di].Environment off;
go

insert into di.Environment(VarNm,VarVal,Notes)
values ('Admin UID','<REPLACE THIS with di.CustMstr.RowID!!!>',N'<Notes><Note nbr=''1''>corresponds to di.CustMstr row id</Note></Notes>'),
('default subscription owner type value (int)','1',N'<Notes><Note nbr=''1''>nbr is found in [di].OwnerTypes</Note><Note nbr=''2''>represents a person...the default owner of a deployment!!!</Note></Notes>'),
('default subscription type value (int)','2',N'<Notes><Note nbr=''1''>this nbr is found in the billing methods tbl</Note><Note nbr=''2''>this should default to the ''monthly'' subscription!!!</Note></Notes>'),
('Domain Name','deployment',N'<Notes><Note nbr=''1''>identifier for this domain</Note><Note nbr=''2''>DO NOT REMOVE!!!</Note></Notes>'),
('idle session timeout (minutes)','5',N'<Notes><Note nbr=''1''>how long a session can sit idle before it is no longer valid to us</Note></Notes>'),
('idle session timeout errno','66060',N'<Notes><Note nbr=''1''>corresponds to I18n mesg cat nbr to use to indicate a stale session...</Note></Notes>'),
('publish i18n catalog changes mode','no',N'<Notes><Note nbr=''1''>triggers on the dbo.I18NMessageCatV2 table publish SSB messages</Note></Note nbr=''2''>this mode controls if we send them out or not!!</Note></Notes>');
go


/****** Object:  Table [di].[Contacts]    Script Date: 2/18/2020 2:31:44 PM ******/

CREATE TABLE [di].[Contacts](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Fk_OwnerInfoID] [int] NOT NULL,
	[Name] [varchar](200) NULL,
	[Email] [varchar](200) NULL,
	[Ph] [varchar](50) NULL,
	[IsPrimary] [bit] NULL,
	[Notes] [nvarchar](4000) NULL,
 CONSTRAINT [PK_Contacts_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];
GO

ALTER TABLE [di].[Contacts]  WITH CHECK ADD  CONSTRAINT [FK_Contacts_OwnerInfo] FOREIGN KEY([Fk_OwnerInfoID])
REFERENCES [di].[OwnerInfo] ([RowID]);
go

ALTER TABLE [di].[Contacts] ADD  CONSTRAINT [DF_Contacts_IsPrimary]  DEFAULT ((0)) FOR [IsPrimary]
GO

ALTER TABLE [di].[Contacts] ADD  CONSTRAINT [DF_Contacts_Notes]  DEFAULT (N'<Notes><Note nbr=''1''>pls provide a comment...</Note></Notes>') FOR [Notes]
GO


/****** Object:  Table [di].[DayWeights]    Script Date: 2/18/2020 2:31:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[di].[DayWeights]') AND type in (N'U'))
BEGIN
CREATE TABLE [di].[DayWeights](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](20) NOT NULL,
	[BitVal] [tinyint] NOT NULL,
	[Abbr] [char](4) NOT NULL
) ON [PRIMARY]
END
GO

insert into [di].[DayWeights] ([Name], BitVal, Abbr)
values ('Sunday',1,'sun'),
('Monday',2,'mon'),
('Tuesday',4,'tues'),
('Wednesday',8,'weds'),
('Thursday',16,'thur'),
('Friday',32,'fri'),
('Saturday',64,'sat');
go

Create Function [di].fn_CookTimeRange(@range varchar(8))
returns char(8)
with encryption
as
begin
	Declare @cooked char(8);
	Declare @buf varchar(16);
	Set @buf = Replace(@range,':','.');

	Set @cooked = FORMATMESSAGE('%02d:%02d:%02d', 
			ISNULL(convert(int,parsename(@buf,3)),0), 
			ISNULL(convert(int,parsename(@buf,2)),0), 
			ISNULL(convert(int,parsename(@buf,1)),0)
		);

	Return @cooked;
end
go

Create Function di.fn_DaysToMask (@days varchar(100))
returns int
with encryption
as
begin
	Declare @mask int;

	if (Left(@days,1) = 'a') -- you can pass in 'all' to represent all days!!!
	Begin
		Select @mask = SUM(BitVal) from [di].DayWeights;
	End
	Else
	Begin
		Select @mask = SUM(C.BitVal)
		From [di].DayWeights C
		Inner Join split_string(@days,',') T On (LEft(C.Abbr,2) = Left(T.[Value],2));
	End

	Return Coalesce(@mask,0);

end
go

Create Function [di].fn_DayMaskToDays(@mask int)
returns varchar(100)
with encryption
as
begin
	Declare @lst varchar(100);
	Select @lst = coalesce(@lst + ',','') + RTRIM(LTRIM(Abbr))
	From [di].DayWeights
	Where ((BitVal & @mask) = BitVal);

	Return Coalesce(@lst,'error');
end
go

/*
** pass in the event timestamp and verify that it is within the day range constraint mask...
** (1) - yes, (0) - nope!!!
*/
Create Function [di].fn_IsEventTSWithinDayRangeCon(@ts datetime, @day_constraint_mask int)
returns bit
with encryption
as
begin
	Declare @b bit;
	Set @b=0;
	Select @b=1 From [di].DayWeights 
	Where Left(DATENAME(dw,@ts),2) = Left(Abbr,2)
	And ((BitVal & @day_constraint_mask) = BitVal)
	Return @b;
end
go

/*
** this lil func will take an event timestamp and verify that the timestamp is between the two
** time values (eg: beg -> '02:00:01'). These are appended to a current date value 1st then the
** between is run.
*/
Create Function [di].fn_IsEventTSWithinTimeRangeCon(@ts datetime, @beg varchar(8), @end varchar(8))
returns bit
with encryption
as
begin
	Declare @b bit;
	Declare @begTS datetime;
	Declare @endTS datetime;
	Declare @sec char(2);
	Declare @min char(2);
	Declare @hr char(2);
	Declare @now varchar(40);

	Set @now = Convert(varchar, GetDate(), 1); -- only want mm/dd/yy portion...
	Set @beg = REPLACE(@beg,':','.'); -- so parsename below will work!!!
	Set @end = REPLACE(@end,':','.');
	Set @b=0;

	Set @sec = RIGHT('00' + COALESCE(PARSENAME(@beg,1),''),2);
	Set @min = RIGHT('00' + COALESCE(PARSENAME(@beg,2),''),2);
	Set @hr = RIGHT('00' + COALESCE(PARSENAME(@beg,3),''),2);
	Set @begTS = convert(datetime, FORMATMESSAGE('%s %s:%s:%s',@now,@hr,@min,@sec));

	Set @sec = RIGHT('00' + COALESCE(PARSENAME(@end,1),''),2);
	Set @min = RIGHT('00' + COALESCE(PARSENAME(@end,2),''),2);
	Set @hr = RIGHT('00' + COALESCE(PARSENAME(@end,3),''),2);
	Set @endTS = convert(datetime, FORMATMESSAGE('%s %s:%s:%s',@now,@hr,@min,@sec));

	Select @b=1 Where @ts between @begTS and @endTS;

	Return @b;
end
go

Create Table [di].BillingMethods (
	RowID int identity(1,1) Not Null,
	BitVal smallint,
	Descr nvarchar(200) null,
	Notes nvarchar(4000) null,
	Constraint PK_BillingMethods_RowID Primary Key NonClustered(RowID)
);
go

set identity_insert [di].BillingMethods on;
insert into [di].BillingMethods (RowID, BitVal, Descr)
values (0,0,'not set'),
(1,1,'Yearly'),
(2,2,'Monthly'),
(3,4,'Weekly'),
(4,8,'As Used'),
(5,16,'Volume'),
(6,32,'Custom'),
(9999,32767,'All');
set identity_insert [di].BillingMethods off;
go

/****** Object:  Table [di].[DeploymentDomains]    Script Date: 2/18/2020 2:31:44 PM ******/
CREATE TABLE [di].[DeploymentDomains](
	[BitVal] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Descr] [nvarchar](1000) NULL
) ON [PRIMARY]
GO

Create Unique Index IDX_DeploymentDomains_BitVal on di.DeploymentDomains(BitVal);
go

Create Unique Index IDX_DeploymentDomains_Name on di.DeploymentDomains(Name);
go

Insert into di.DeploymentDomains(BitVal,Name,Descr)
values (0,'unknwn','unknown domain...wtf!!!'),
(1,'products','in general refers to the BHP1 dbms..aka: products'),
--(2,'operations','refers to the BHOPS1 dbms...where operational info is held!!!'),
(4,'deployment','refers to the DI schema...where localized deployment information is held.');
--(8,'analytics','refers to the reporting dbms...aka: BHRpts. Where all reporting/analytics.'),
--(16,'meta','refers to any type of event that may/might be publishing some type of meta information.');
go

Create Table [di].DeploymentTypes (
	RowID int identity(1,1) Not Null,
	BitVal smallint,
	Descr nvarchar(200) null,
	Notes nvarchar(4000) null,
	Constraint PK_DeploymentTypes_RowID Primary Key NonClustered(RowID)
);
go

set identity_insert [di].DeploymentTypes on;
insert into [di].DeploymentTypes (RowID, BitVal, Descr)
values (0,0,'not set'),
(1,1,'Builder'),
(2,2,'Operations'),
(3,4,'Reporting'),
(4,8,'Social'),
(5,16,'Planning'),
(6,32,'Analytics'),
(7,64,'POS'),
(8,128,'Cellaring'),
(9999,32767,'All');
set identity_insert [di].DeploymentTypes off;
go

Create function [di].[fn_DeploymentTypeToCSV] (@mask int)
returns varchar(200)
with encryption
as
begin
	Declare @currbit smallint;
	Declare @str varchar(200);
	Declare @nm varchar(40);
	Set @currbit = 0;

	-- check if mask is equal to all deployments...then return the 'all' record.
	-- i assume it's the highest bit value!!!
	If (@mask >= (select MAX(BitVal) from [di].DeploymentTypes))
	begin
		select Top (1) @str = Descr from [di].DeploymentTypes Order by BitVal Desc;
		return @str;
	end

	While Exists (Select 1 from [di].DeploymentTypes Where (BitVal > @currbit))
	Begin
		Select Top (1) @currbit = BitVal, @nm = Descr
		From [di].DeploymentTypes 
		Where (BitVal > @currbit) Order by BitVal;
		
		If ((@mask & @currbit) = @currbit)
			set @str = coalesce(@str + ',','') + @nm;
	End
	Return Coalesce(@str,(select descr from [di].DeploymentTypes where BitVal = 0));
end
go

/****** Object:  Table [di].[Deployments]    Script Date: 2/18/2020 2:31:44 PM ******/
CREATE TABLE [di].[Deployments](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Fk_DeploymentType] [int] NULL,
	[DeploymentTypeAsCSV]  AS ([di].[fn_DeploymentTypeToCSV]([Fk_DeploymentType])),
	[Name] [varchar](200) NULL,
	[Descr] [nvarchar](4000) NULL,
	[DeployedOn] [datetime] NULL,
	[DeploymentID] [uniqueidentifier] NOT NULL,
	[Fk_OwnerInfoID] [int] NULL,
	[Notes] [nvarchar](4000) NULL,
	[LatestPayLdType] [varchar](40) NULL,
	[LatestPayLdUID] [uniqueidentifier] NULL,
	[Verified] [bit] NULL,
	[fk_ContainerType] int not null,
	[LinkServerName] sysname null,
 CONSTRAINT [PK_Deployments_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

set identity_insert [di].Deployments on;
insert into [di].[Deployments](RowID, Fk_DeploymentType, Name, Descr, DeployedOn, DeploymentID, Fk_OwnerInfoID, Verified)
values (-1, 0, 'unknown','unknown deployment!!!',getdate(), '11111111-1111-1111-1111-111111111111',0,0),
(0, 32767, '<set to deployment name!!!>','local deployment!!!',getdate(), NEWID(),0,1);
set identity_insert [di].Deployments off;
go

declare @did varchar(256);
select @did = DeploymentID from [di].[Deployments] where RowID = 0;
Raiserror(N'New Deployment id:[''%s''] created. Set deployment name!!!',0,1,@did);
go

ALTER TABLE [di].[Deployments]  WITH CHECK ADD  CONSTRAINT [FK_Deployments_OwnerInfo] FOREIGN KEY([Fk_OwnerInfoID])
REFERENCES [di].[OwnerInfo] ([RowID])
GO
ALTER TABLE [di].[Deployments] ADD  CONSTRAINT [DF_Deployments_Fk_Owner]  DEFAULT ((0)) FOR [Fk_OwnerInfoID]
GO

ALTER TABLE [di].[Deployments] ADD  CONSTRAINT [DF_Deployments_Fk_Type]  DEFAULT ((0)) FOR [Fk_DeploymentType]
GO

ALTER TABLE [di].[Deployments] ADD  CONSTRAINT [DF_Deployments_Descr]  DEFAULT (N'no description provided...') FOR [Descr]
GO

ALTER TABLE [di].[Deployments] ADD  CONSTRAINT [DF_Deployments_DeployedOn]  DEFAULT (getdate()) FOR [DeployedOn]
GO

ALTER TABLE [di].[Deployments] ADD  CONSTRAINT [DF_Deployments_Notes]  DEFAULT (N'<Notes><Note nbr=''1''>pls provide a comment...</Note></Notes>') FOR [Notes]
GO

ALTER TABLE [di].[Deployments] ADD  CONSTRAINT [DF_Deployments_LatestPayLdType]  DEFAULT ('n/a') FOR [LatestPayLdType]
GO

ALTER TABLE [di].[Deployments] ADD  CONSTRAINT [DF_Deployments_LatestPayLdUID]  DEFAULT ('11111111-1111-1111-1111-111111111111') FOR [LatestPayLdUID]
GO

ALTER TABLE [di].[Deployments] ADD  CONSTRAINT [DF_Deployments_Verified]  DEFAULT ((0)) FOR [Verified]
GO

Alter Table [di].[Deployments] Add CONSTRAINT [DF_Deployments_Fk_ContainerType]  DEFAULT ((0)) FOR [fk_ContainerType];
go

CREATE TRIGGER Trig_Deployments_Del_99 ON [di].Deployments 
with encryption
for Delete
AS 
BEGIN

    If Exists (Select * from Deleted Where RowID <= 0)
	Begin
		Raiserror(N'Deployment Record(s) ''0'' and ''-1'' cannot be removed!!!',16,1);
		Rollback Transaction;
	End
End
go

create function [di].fn_GetDeployName(@id int)
returns varchar(200)
with encryption, execute as 'sticky'
as
begin
	declare @nm varchar(200);
	select @nm=[Name] from [di].Deployments Where [RowID] = @id;
	return ISNULL(@nm, (select [name] from [di].Deployments Where RowID=-1));
end
go

/****** Object:  Table [di].[CustMstr]    Script Date: 2/18/2020 2:31:44 PM ******/
CREATE TABLE [di].[CustMstr](
	[RowID] [bigint] IDENTITY(1000,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[BHPUid] [nvarchar](256) NOT NULL,
	[BHPPwd] [nvarchar](50) NOT NULL,
	[Hint] [nvarchar](2000) NULL,
	[TotBlogs] [int] NULL,
	[TotRecipes] [int] NULL,
	[RoleBitMask] [int] NULL,
	[RoleBitMaskAsStr]  AS ([di].[fn_ShowRoleBitMaskAsStr]([RoleBitMask])),
	[AllowMultiSession] [bit] NULL,
	[AllowLogin] [bit] NULL,
	[fk_LangID] [int] NULL,
	[DfltLang]  AS ([di].[fn_GetLang]([fk_LangID])),
	[fk_LastBeerDrank] [int] NULL,
	[DisplayAs] [nvarchar](200) NULL,
	[EnteredOn] [datetime] NULL,
	[Verified] [bit] NULL,
	[Pic] [image] NULL,
	[fk_DeployInfo] [int] NOT NULL,
	[AllowNotices] [bit] NULL,
	[DenyBroadcast] [bit] NULL,
	[EncPswd] [varbinary](100) Not Null,
 CONSTRAINT [PK__CustMstr_RowID_Fk_DeployInfo] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC,
	[fk_DeployInfo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IDX_CustMstr_Name] ON [di].[CustMstr]
(
	[fk_DeployInfo] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [di].[CustMstr]  WITH CHECK ADD  CONSTRAINT [FK_LangID_CustMstr] FOREIGN KEY([fk_LangID])
REFERENCES [di].[Languages] ([RowID])
GO

ALTER TABLE [di].[CustMstr]  WITH CHECK ADD  CONSTRAINT [fk_CustMstr_DeployInfo] FOREIGN KEY([fk_DeployInfo])
REFERENCES [di].[Deployments] ([RowID])
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF__CustMstr__TotBlogs]  DEFAULT ((0)) FOR [TotBlogs]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF__CustMstr__TotRecipes]  DEFAULT ((0)) FOR [TotRecipes]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF_CustMstr_Role]  DEFAULT ((0)) FOR [RoleBitMask]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF_CustMstr_AllowMultiSession]  DEFAULT ((0)) FOR [AllowMultiSession]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF__CustMstr__AllowLogin]  DEFAULT ((1)) FOR [AllowLogin]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF_CustMstr_fk_LastBeerDrank]  DEFAULT ((0)) FOR [fk_LastBeerDrank]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF_CustMstr_DisplayAs]  DEFAULT ('n/a') FOR [DisplayAs]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF__CustMstr__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF__CustMstr_Verified]  DEFAULT ((0)) FOR [Verified]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF_CustMstr_AllowNotice]  DEFAULT ((1)) FOR [AllowNotices]
GO

ALTER TABLE [di].[CustMstr] ADD  CONSTRAINT [DF_CustMstr_DenyBroadcast]  DEFAULT ((0)) FOR [DenyBroadcast]
GO

Alter table [di].[CustMstr] add constraint DF_CustMstr_EncPswd default(hashbytes('SHA1',N'changeit')) For [EncPswd];
go

set identity_insert [di].[CustMstr] on;
insert [di].[CustMstr] (RowID, Name, BHPUid, BHPPwd, Hint, RoleBitMask, AllowLogin, AllowMultiSession, AllowNotices, fk_LangID, DisplayAs, fk_DeployInfo)
values (0, 'pls select...','pls select...',N'changeit','for dropdwn menus',32767, 0, 1, 0, 1, 'pls select...',0);
set identity_insert [di].[CustMstr] off;
go

create trigger [di].[CustMstr_Del_99] on [di].[CustMstr]
with encryption
for delete
as
begin
	If Exists (Select * from deleted where RowID = 0)
	Begin
		Raiserror('RowID:[%d] cannot be removed from Customer Master table...aborting!!!',16,1,0);
		Rollback Transaction;
	End
end
GO



/****** Object:  Table [di].[SessionMstr]    Script Date: 2/18/2020 2:31:44 PM ******/
CREATE TABLE [di].[SessionMstr](
	[RowID] [bigint] IDENTITY(1,1) NOT NULL,
	[SessID] [uniqueidentifier] NOT NULL,
	[fk_CustID] [bigint] NOT NULL,
	[Lang] [nvarchar](20) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ClosedOn] [datetime] NOT NULL,
	[LastActiveOn] [datetime] NULL,
	[fk_DeployInfo] [int] NOT NULL,
 CONSTRAINT [PK_SessionMstr_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

set identity_insert [di].SessionMstr on;
insert into [di].SessionMstr(RowID, SessID, CreatedOn, ClosedOn, fk_CustID, [Lang], fk_DeployInfo)
values (0,'00000000-0000-0000-0000-000000000000',GetDate(),0,0,N'en_us', 0);
set identity_insert [di].SessionMstr off;
go

create trigger [di].SessionMstr_Del_99 on [di].SessionMstr 
with encryption
for delete
as
begin
	if exists (Select * from deleted where RowID = 0)
	begin
		raiserror('Session ''zero'' cannot be removed...aborting!!!',16,1);
		rollback transaction;
	end
end
go

create trigger SessionMstr_Upd_00 on [di].SessionMstr 
with encryption
for update
as
begin
	if exists (select * from inserted where (RowID = 0) And UPDATE(SessID))
	begin
		Raiserror('Row ''zero'' cannot be modified in any way...aborting!!!',16,1);
		If (XACT_STATE() = 1) Rollback Transaction;
	end
end
go

ALTER TABLE [di].[SessionMstr]  WITH CHECK ADD  CONSTRAINT [FK_SessMstr_DeploymentInfo] FOREIGN KEY([fk_DeployInfo])
REFERENCES [di].[Deployments] ([RowID])
GO

ALTER TABLE [di].[SessionMstr] ADD  CONSTRAINT [DF_SessionMstr_CustID]  DEFAULT ((0)) FOR [fk_CustID]
GO

ALTER TABLE [di].[SessionMstr]  WITH CHECK ADD  CONSTRAINT [FK_SessionMstr_CustMstr] FOREIGN KEY([fk_CustID])
REFERENCES [di].[CustMstr] ([RowID])
On Delete Cascade;
GO

ALTER TABLE [di].[SessionMstr] ADD  CONSTRAINT [DF_SessionMstr_Lang]  DEFAULT ('en_us') FOR [Lang]
GO

ALTER TABLE [di].[SessionMstr] ADD  CONSTRAINT [DF_SessionMstr_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO

ALTER TABLE [di].[SessionMstr] ADD  CONSTRAINT [DF_SessionMstr_ClosedOn]  DEFAULT ((0)) FOR [ClosedOn]
GO

ALTER TABLE [di].[SessionMstr] ADD  CONSTRAINT [DF_SessionMstr_LastActiveOn]  DEFAULT ((0)) FOR [LastActiveOn]
GO

/****** Object:  Index [IDX_SessionMstr_SessID]    Script Date: 2/18/2020 2:31:44 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IDX_SessionMstr_SessID] ON [di].[SessionMstr]
(
	[SessID] ASC,
	[fk_CustID] ASC,
	[fk_DeployInfo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

Create view [di].[vw_SessionInfo] (
	RowID, SessionID, CustomerNbr, CustName, 
	[LangID], Lang, CreatedOn, ClosedOn, LastActivityTS, EmailAddr, 
	RoleBitMask, Roles, DeploymentID, DeploymentName, DeploymentRowID, AllowBroadcast, AllowNotices
)
with encryption
as
	Select 
		S.RowID, 
		S.SessID, 
		S.fk_CustID, 
		ISNULL(C.Name, 'n/a'),
		ISNULL(C.fk_LangID,(select top (1) RowID from [di].Languages Where Lang='en_us')),
		ISNULL(C.DfltLang,'en_us'), 
		Case S.RowID When 0 Then convert(datetime,0,0) Else ISNULL(S.CreatedOn, 0) End, 
		Case S.RowID When 0 Then convert(datetime,0,0) Else ISNULL(S.ClosedOn, 0) End,  
		Case S.RowID When 0 Then convert(datetime,0,0) Else ISNULL(S.LastActiveOn, 0) End, 
		Case S.RowID WHen 0 Then 'adm@bhp.biz' Else C.BHPUid End,
		Case S.RowID WHen 0 Then (Select SUM(BitVal) from [di].RoleMstr) Else C.RoleBitMask End, 
		Case S.RowID When 0 THen (Select [di].[fn_ShowRoleBitMaskAsStr](SUM(BitVal)) from [di].RoleMstr) Else C.RoleBitMaskAsStr End,
		Case D.DeploymentID 
			When Null Then (Select DeploymentID from [di].Deployments Where RowID=0) 
			Else D.DeploymentID 
		End As DeploymentID,
		Case D.[Name]
			When Null Then (Select [Name] from [di].Deployments Where (RowID=0))
			Else D.[Name]
		End As DeploymentName,
		Coalesce(S.fk_DeployInfo, D.RowID, 0) As DeploymentRowID,
		Case ISNULL(C.DenyBroadcast,0) WHen 0 THen 1 Else 0 End,
		ISNULL(C.AllowNotices,1)
	From [di].SessionMstr S 
	Inner Join [di].CustMstr C On (S.fk_CustID = C.RowID)
	Left Join [di].Languages L on (C.fk_LangID = L.RowID)
	Left Join [di].Deployments D On (S.fk_DeployInfo = D.RowID);
	--Where (S.RowID > 0);
GO




checkpoint
go


