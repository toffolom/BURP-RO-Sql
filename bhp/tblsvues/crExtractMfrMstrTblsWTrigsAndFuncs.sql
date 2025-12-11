USE [BHP1-RO]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [FK_ExtractManufs_VolDiscUOM]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [FK_ExtractManuf_Fk_Country]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [DF_ExtractManuf_Lang]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [DF__ExtractMa__EnteredBy]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [DF__ExtractMa__EnteredOn]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [DF__ExtractManu__W3C]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [DF__ExtractMa__MinOrder]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [DF__ExtractMa_VolDiscSz]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[ExtractManufacturers]') AND type in (N'U'))
ALTER TABLE [bhp].[ExtractManufacturers] DROP CONSTRAINT IF EXISTS [DF__ExtractMa__fk_VolDisc]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_ExtractMstr_BitterUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[ExtractMstr]'))
ALTER TABLE [bhp].[ExtractMstr] DROP CONSTRAINT [FK_ExtractMstr_BitterUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_ExtractMstr_ColorUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[ExtractMstr]'))
ALTER TABLE [bhp].[ExtractMstr] DROP CONSTRAINT [FK_ExtractMstr_ColorUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_ExtractMstr_HopUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[ExtractMstr]'))
ALTER TABLE [bhp].[ExtractMstr] DROP CONSTRAINT [FK_ExtractMstr_HopUOM]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_ExtractMstr_MfrID]') AND parent_object_id = OBJECT_ID(N'[bhp].[ExtractMstr]'))
ALTER TABLE [bhp].[ExtractMstr] DROP CONSTRAINT [FK_ExtractMstr_MfrID]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[bhp].[FK_ExtractMstr_SolidUOM]') AND parent_object_id = OBJECT_ID(N'[bhp].[ExtractMstr]'))
ALTER TABLE [bhp].[ExtractMstr] DROP CONSTRAINT [FK_ExtractMstr_SolidUOM]
GO


begin try
	drop table [bhp].[ExtractManufacturers];
	print 'table:[[bhp].ExtractManufacturers] dropped...';
end try
begin catch
	print 'table:[[bhp].ExtractManufacturers] doesn''t exist...no problem...';
end catch
go

begin try
	drop table [bhp].[ExtractMstr];
	print 'table:[[bhp].ExtractMstr] dropped...';
end try
begin catch
	print 'table:[[bhp].ExtractMstr] doesn''t exist...no problem...';
end catch
go


/****** Object:  UserDefinedFunction [bhp].[fn_GetExtractMfrName]    Script Date: 04/08/2011 13:31:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bhp].[fn_GetExtractMfrName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
Begin
DROP FUNCTION [bhp].[fn_GetExtractMfrName]
Print 'Function:[[bhp].fn_GetExtractMfrNm] dropped...';
End
GO



CREATE TABLE [bhp].[ExtractManufacturers](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](300) NOT NULL,
	[fk_VolDiscUOM] [int] NULL,
	VolDiscUOM as [bhp].fn_getUOM(fk_VolDiscUOM),
	[VolDiscSz] [numeric](18, 4) NULL,
	[MinOrderQty] [numeric](18, 4) NULL,
	[W3C] [nvarchar](2000) NULL,
	[EnteredOn] [datetime] NULL,
	[EnteredBy] [sysname] NULL,
	Comments nvarchar(4000) null,
	fk_Country int not null,
	[Lang] nvarchar(20) null
Constraint [PK_ExtractManuf_RowID] PRIMARY KEY NONCLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = OFF, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [bhp].[ExtractManufacturers] ADD  CONSTRAINT [DF__ExtractMa__fk_VolDisc]  DEFAULT ([bhp].[fn_GetUOMIdByNm('lb')]) FOR [fk_VolDiscUOM]
GO

ALTER TABLE [bhp].[ExtractManufacturers] ADD  CONSTRAINT [DF__ExtractMa_VolDiscSz]  DEFAULT ((0)) FOR [VolDiscSz]
GO

ALTER TABLE [bhp].[ExtractManufacturers] ADD  CONSTRAINT [DF__ExtractMa__MinOrder]  DEFAULT ((0.0)) FOR [MinOrderQty]
GO

ALTER TABLE [bhp].[ExtractManufacturers] ADD  CONSTRAINT [DF__ExtractManu__W3C]  DEFAULT (N'http://www.somewebsite.com') FOR [W3C]
GO

ALTER TABLE [bhp].[ExtractManufacturers] ADD  CONSTRAINT [DF__ExtractMa__EnteredOn]  DEFAULT (getdate()) FOR [EnteredOn]
GO

ALTER TABLE [bhp].[ExtractManufacturers] ADD  CONSTRAINT [DF__ExtractMa__EnteredBy]  DEFAULT (CURRENT_USER) FOR [EnteredBy]
GO

ALTER TABLE [bhp].[ExtractManufacturers] ADD  CONSTRAINT [DF_ExtractManuf_Lang]  DEFAULT ('en_us') FOR [Lang]
GO

Alter Table [bhp].[Extractmanufacturers] Add Constraint [DF_ExtractManuf_Fk_Country] Default(0) for [fk_Country];
go

ALTER TABLE [bhp].[ExtractManufacturers]  WITH CHECK ADD  
CONSTRAINT [FK_ExtractManufs_VolDiscUOM] FOREIGN KEY([fk_VolDiscUOM]) REFERENCES [bhp].[UOMTypes] ([RowID]);
GO

ALTER TABLE [bhp].[ExtractManufacturers]  WITH CHECK ADD  
CONSTRAINT [FK_ExtractManuf_Fk_Country] FOREIGN KEY(fk_Country) REFERENCES [di].Countries ([RowID]);
GO

set identity_insert [bhp].ExtractManufacturers on;
insert into [bhp].ExtractManufacturers (RowID, Name, Comments, fk_Country) values (0,N'pls select...',N'DO NOT REMOVE!!!',0);
set identity_insert [bhp].ExtractManufacturers off;
go

create trigger ExtractManufacturers_Trig_Del_99 on [bhp].ExtractManufacturers 
with encryption
for delete
as
begin
	Set Nocount on;
	if Exists (Select * from deleted where (RowID = 0))
	Begin
		Raiserror('Extract Manuf ''zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

create trigger ExtractManufacturers_Trig_Ins_01 on [bhp].ExtractManufacturers
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where ([fk_VolDiscUOM] > 0)
		And ([fk_VolDiscUOM] Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Volumn Discount(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go


create function [bhp].[fn_GetExtractMfrName](@id int)
returns nvarchar(300)
as
begin
	Declare @rtrnVal nvarchar(300);
	If Not Exists (Select * from [bhp].ExtractManufacturers Where (RowID = @ID))
		Select @rtrnVal = [Name] FROM [bhp].ExtractManufacturers With (NoLock) Where (RowID = 0);
	Else
		Select @rtrnVal = [Name] From [bhp].ExtractManufacturers With (NoLock) Where (RowID=@id);
	Return Isnull(@rtrnVal,N'unknwn');
end
GO


insert into [bhp].ExtractManufacturers (Name, Comments, W3C, fk_Country)
select N'Muntons',N'pretty standard stuff here...',N'http://www.muntons.com', 2
union
select N'Briess Malt & Ingredients',N'pretty standard mfr',N'http://www.brewingwithbriess.com', 1
go 

create table [bhp].ExtractMstr (
	RowID int identity(1,1) not null,
	Name nvarchar(256) not null,
	KnownAs1 nvarchar(245) null,
	KnownAs2 nvarchar(245) null,
	KnownAs3 nvarchar(245) null,
	fk_ExtractMfrID int not null default(0),
	ExtractMfrNm as [bhp].fn_GetExtractMfrName(fk_ExtractMfrID),
	NbrOfRecipesUsedIn int null default(0),
	fk_SolidUOM int not null default(0),
	SolidUOM as [bhp].fn_GetUOM(fk_SolidUOM),
	BegSolidsAmt numeric(5,2) null default(80.0),
	EndSolidsAmt numeric(5,2) null default(80.0),
	fk_ColorUOM int not null default(0),
	ColorUOM as [bhp].fn_GetUOM(fk_ColorUOM),
	BegColorAmt numeric(6,2) not null default(0),
	EndColorAmt numeric(6,2) not null default(0),
	fk_BitternessUOM int not null default(0),
	BitternessUOM as [bhp].fn_GetUOM(fk_BitternessUOM),
	BegBitternessAmt numeric(6,2) not null default(0),
	EndBitternessAmt numeric(6,2) not null default(0),
	IsHopped bit null default(0),
	fk_HopUOM int not null default(0),
	HopUOM as [bhp].fn_GetUOM(fk_HopUOM),
	HopAmt numeric(6,2) not null default(0),
	IsDiastatic bit null default(0),
	EnteredOn datetime null default(getdate()),
	EnteredBy sysname null default(suser_sname()),
	Comment nvarchar(4000) null,
	Constraint [PK_ExtractMstr_RowID] primary key nonclustered (RowID)
)
go

alter table [bhp].ExtractMstr with check add
constraint FK_ExtractMstr_MfrID foreign key (fk_ExtractMfrID) references [bhp].ExtractManufacturers (RowID),
constraint FK_ExtractMstr_SolidUOM foreign key (fk_SolidUOM) references [bhp].UOMTypes (RowID),
constraint FK_ExtractMstr_ColorUOM foreign key (fk_ColorUOM) references [bhp].UOMTypes (RowID),
constraint FK_ExtractMstr_BitterUOM foreign key (fk_BitternessUOM) references [bhp].UOMTypes (RowID),
constraint FK_ExtractMstr_HopUOM foreign key (fk_HopUOM) references [bhp].UOMTypes (RowID);
go

set identity_insert [bhp].ExtractMstr on;
insert into [bhp].ExtractMstr (RowID, Name, Comment, fk_SolidUOM, fk_ColorUOM, fk_BitternessUOM, fk_HopUOM) 
select
	0,
	N'pls select...',
	N'DO NOT REMOVE!!!',
	[bhp].[fn_GetUOMIdByNm]('%'),
	[bhp].[fn_GetUOMIdByNm]('EBC'),
	[bhp].[fn_GetUOMIdByNm]('IBU'),
	[bhp].[fn_GetUOMIdByNm]('%');
set identity_insert [bhp].ExtractMstr off;
go


create trigger ExtractMstr_Trig_Del_99 on [bhp].ExtractMstr 
with encryption
for delete
as
begin
	Set Nocount on;
	if Exists (Select * from deleted where (RowID = 0))
	Begin
		Raiserror('Extract Master record ''zero'' cannot be removed...aborting!!!',16,1);
		Rollback Transaction;
	End
end
go

create trigger ExtractMstr_Trig_Ins_01 on [bhp].ExtractMstr
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_SolidUOM > 0)
		And (fk_SolidUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Solid Amount(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

create trigger ExtractMstr_Trig_Ins_02 on [bhp].ExtractMstr
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_ColorUOM > 0)
		And (fk_ColorUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsColorMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsColorMeasure = 1);
		Raiserror('Color Amount(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

create trigger ExtractMstr_Trig_Ins_03 on [bhp].ExtractMstr
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_BitternessUOM > 0)
		And (fk_BitternessUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsBitterMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsBitterMeasure = 1);
		Raiserror('Bitterness Amount(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

create trigger ExtractMstr_Trig_Ins_04 on [bhp].ExtractMstr
with encryption
for insert
as
begin
	If Exists (Select * from Inserted I Where (fk_HopUOM > 0)
		And (fk_HopUOM Not In (Select RowID from [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1))))
	Begin
		Declare @buff varchar(2000);
		Select @buff = isnull(@buff + ',','') + [Name] From [bhp].UOMTypes Where (AllowedAsVolumnMeasure = 1);
		Raiserror('Hop Amount(s) can only be registered in:[%s] value(s)...aborting!!!',16,1,@buff);
		Rollback transaction;
	End
end
go

checkpoint
go