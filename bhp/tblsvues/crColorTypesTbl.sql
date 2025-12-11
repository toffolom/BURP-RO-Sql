use [BHP1-RO];
go

begin try
	drop table [bhp].ColorStyle;
	print 'table::[bhp].[ColorStyle] dropped!!!';
end try
begin catch
	print 'table::[bhp].[ColorStyle] doesn''t exist...';
end catch
go

create table [bhp].ColorStyle (
	RowID int identity(1,1) not null,
	Name nvarchar(200) not null,
	RedVal int null,
	GreenVal int null,
	BlueVal int null,
	Gif image null,
	EnteredOn datetime null,
	Constraint [PK_ColorStyle_RowID] primary key nonclustered (RowID)
)
go

print 'table::[bhp].[ColorStyle] created...'
go

ALTER TABLE [bhp].[ColorStyle] ADD  
CONSTRAINT [DF_ColorStyle_BlueVal_Zero]  DEFAULT ((0)) FOR [BlueVal],
CONSTRAINT [DF_ColorStyle_RedVal_Zero]  DEFAULT ((0)) FOR [RedVal],
CONSTRAINT [DF_ColorStyle_GreenVal_Zero]  DEFAULT ((0)) FOR [GreenVal],
Constraint [DF_ColorStyle_EnteredOn] Default(getdate()) for [EnteredOn];
GO

create trigger [bhp].[Trig_ColorStyle_Del_1] on [bhp].[ColorStyle] 
with encryption
for delete
as
begin
	If Exists (Select * from deleted where rowid = 0)
	Begin
		Raiserror('Row:[0] cannot be deleted...aborted!!!',16,1);
		Rollback Transaction;
	End
end 
GO


create unique clustered index IDX_ColorStyle_Name on [bhp].ColorStyle ([Name])
go

set identity_insert [bhp].ColorStyle on;
insert into [bhp].ColorStyle(RowID,Name) values (0,'not set');
set identity_insert [bhp].ColorStyle off;
go

insert into [bhp].ColorStyle(Name)
select 'Amber'
union
select 'Golden'
union
select 'Golden -to- Copper'
union
select 'Golden -to- Deep Copper -to- Light Brown'
union
select 'Golden -to- Deep Copper'
union
select 'Light Copper'
union
select 'Light Cloudy'
union
select 'Dark Brown'
union
select 'Amber -to- Dark Brown'
union
select 'Golden -to- Deep Amber'
union
select 'Deep Amber'
union
select 'Tawny Copper'
union
select 'Tawny Copper -to- Dark Brown'
union
select 'Deep Copper -to- Light Brown'
union
select 'Deep Copper -to- Brown'
union
select 'Dark Amber'
union
select 'Light Red-Amber-Copper -to- Light Brown'
union
select 'Pale Gold -to- Deep Copper'
union
select 'Golden -to- Light Copper'
union
select 'Straw -to- Light Amber'
union
select 'Dark Copper -to- Very Black'
union
select 'Black'
union
select 'Very Pale'
union
select 'Reddish Brown'
union
select 'Copper Brown -to- Dark Brown'
go

checkpoint
go